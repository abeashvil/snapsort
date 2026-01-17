//
//  ScanService.swift
//  SnapSort
//
//  Created by Abraham Ashvil on 1/13/26.
//

import Foundation
import UIKit

/// Scan Service (F-002)
/// Handles photo scanning logic using OpenAI GPT-4o mini vision
/// Future: Can be replaced with Core ML model for on-device scanning
struct ScanService {
    /// Scans a photo and returns detected items using GPT-4o mini vision
    /// - Parameter image: The image to scan
    /// - Returns: Array of detected items
    /// - Throws: ScanError if scanning fails
    static func scanPhoto(_ image: UIImage) async throws -> [ScanItem] {
        print("DEBUG: Starting photo scan with GPT-4o mini")
        
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("DEBUG: Failed to convert image to JPEG data")
            throw ScanError.invalidImage
        }
        let base64Image = imageData.base64EncodedString()
        
        // Create the prompt for GPT-4o mini
        let prompt = createScanningPrompt()
        
        // Create request body for OpenAI API
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": prompt
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 1000,
            "response_format": ["type": "json_object"] // Ensure JSON response
        ]
        
        // Make API request
        print("DEBUG: Checking for OpenAI API key...")
        let envValue = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "NOT_SET"
        print("DEBUG: OPENAI_API_KEY environment value exists: \(!envValue.isEmpty && envValue != "NOT_SET")")
        print("DEBUG: OPENAI_API_KEY value length: \(envValue.count)")
        print("DEBUG: OPENAI_API_KEY value preview: \(envValue.prefix(10))...")
        
        guard let apiKey = APIConfig.openAIAPIKey else {
            print("DEBUG: ERROR - OpenAI API key not configured. Please set OPENAI_API_KEY environment variable in Xcode scheme settings.")
            print("DEBUG: Environment variables with 'OPENAI' or 'API': \(ProcessInfo.processInfo.environment.keys.filter { $0.contains("OPENAI") || $0.contains("API") })")
            print("DEBUG: Raw environment value: '\(envValue)'")
            throw ScanError.apiError("API key not configured. Please set OPENAI_API_KEY environment variable.")
        }
        print("DEBUG: OpenAI API key found (length: \(apiKey.count) characters)")
        
        guard let url = URL(string: APIConfig.openAIBaseURL) else {
            print("DEBUG: Invalid API URL")
            throw ScanError.networkError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60 // 60 second timeout
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("DEBUG: Sending request to OpenAI API")
        print("DEBUG: Request URL: \(url)")
        print("DEBUG: Request body size: \(request.httpBody?.count ?? 0) bytes")
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
            print("DEBUG: Received response from OpenAI API")
        } catch {
            print("DEBUG: Network request failed: \(error.localizedDescription)")
            print("DEBUG: Error details: \(error)")
            throw ScanError.networkError
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ScanError.networkError
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            print("DEBUG: API request failed with status: \(httpResponse.statusCode)")
            if let errorData = String(data: data, encoding: .utf8) {
                print("DEBUG: Error response: \(errorData)")
            }
            
            if httpResponse.statusCode == 401 {
                throw ScanError.apiError("Invalid API key. Please check your OpenAI API key.")
            } else if httpResponse.statusCode == 429 {
                throw ScanError.apiError("Rate limit exceeded. Please try again later.")
            } else if httpResponse.statusCode == 402 || httpResponse.statusCode == 403 {
                throw ScanError.apiError("Insufficient credits or billing issue. Check your OpenAI account.")
            }
            
            throw ScanError.scanFailed
        }
        
        // Parse response and convert to ScanItems
        let scanResults = try parseOpenAIResponse(data: data)
        print("DEBUG: Scan completed successfully, found \(scanResults.count) items")
        
        if scanResults.isEmpty {
            print("DEBUG: WARNING - No items detected in the image")
        }
        
        return scanResults
    }
    
    /// Creates the prompt for GPT-4o mini to identify trash items
    private static func createScanningPrompt() -> String {
        return """
        Analyze this image carefully and identify ALL trash, waste, or recyclable items that are visible. Look for any objects that could be thrown away.
        
        Include items such as:
        - Bottles (plastic, glass)
        - Cans (aluminum, tin, soda cans)
        - Food items (fruit, vegetables, leftovers)
        - Packaging (boxes, wrappers, bags)
        - Containers (jars, cups, bowls)
        - Paper products (newspapers, magazines, cardboard)
        - Electronics (phones, laptops, tablets)
        - Any other waste or recyclable materials
        
        For each item you find, provide:
        1. Name: Be specific (e.g., "Soda Can", "Plastic Water Bottle", "Banana Peel", "Pizza Box")
        2. Bin: "Recycle", "Compost", or "Trash"
        3. Confidence: "High", "Medium", or "Low"
        
        Bin rules:
        - Recycle: plastic bottles, metal cans, glass, paper, cardboard, containers
        - Compost: food waste, fruit peels, vegetables, organic matter, coffee grounds, eggshells
        - Trash: items that can't be recycled/composted (styrofoam, chip bags, candy wrappers, plastic bags)
        
        You MUST respond with ONLY valid JSON in this format (no markdown, no explanations):
        {
          "items": [
            {
              "name": "Soda Can",
              "bin": "Recycle",
              "confidence": "High"
            }
          ]
        }
        
        Look carefully at the entire image. Include ALL items you can identify. If you see an item but are unsure what to do with it, list it as "Trash" with a low confidence.
        Only return {"items": []} if the image contains absolutely NO trash, waste, or recyclable items.
        """
    }
    
    /// Parses OpenAI GPT-4o mini response and extracts scan items
    private static func parseOpenAIResponse(data: Data) throws -> [ScanItem] {
        // Parse the main response structure
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            print("DEBUG: Failed to parse OpenAI API response")
            throw ScanError.scanFailed
        }
        
        print("DEBUG: OpenAI response content: \(content)")
        
        // Parse the JSON content from the message
        // The content should be a JSON string, might be wrapped in markdown code blocks
        var jsonString = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code blocks if present
        if jsonString.hasPrefix("```json") {
            jsonString = String(jsonString.dropFirst(7))
        } else if jsonString.hasPrefix("```") {
            jsonString = String(jsonString.dropFirst(3))
        }
        if jsonString.hasSuffix("```") {
            jsonString = String(jsonString.dropLast(3))
        }
        jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let contentData = jsonString.data(using: .utf8) else {
            print("DEBUG: Failed to convert JSON string to data")
            print("DEBUG: Content string: \(jsonString)")
            throw ScanError.scanFailed
        }
        
        guard let responseJSON = try JSONSerialization.jsonObject(with: contentData) as? [String: Any] else {
            print("DEBUG: Failed to parse JSON object from content")
            print("DEBUG: Content string: \(jsonString)")
            throw ScanError.scanFailed
        }
        
        // Handle empty items array - this is valid (no items found)
        guard let itemsArray = responseJSON["items"] as? [[String: String]] else {
            print("DEBUG: Failed to parse items array from response")
            print("DEBUG: Response JSON: \(responseJSON)")
            print("DEBUG: Content string: \(jsonString)")
            // If items key exists but is empty array, that's okay
            if let items = responseJSON["items"] as? [Any], items.isEmpty {
                print("DEBUG: Items array is empty - no items detected")
                return []
            }
            throw ScanError.scanFailed
        }
        
        print("DEBUG: Parsed \(itemsArray.count) items from response")
        
        var scanItems: [ScanItem] = []
        
        // Process each item from the response
        for itemDict in itemsArray {
            guard let name = itemDict["name"],
                  let bin = itemDict["bin"],
                  let confidence = itemDict["confidence"] else {
                print("DEBUG: Skipping invalid item in response: \(itemDict)")
                continue
            }
            
            // Validate bin value
            guard ["Recycle", "Compost", "Trash"].contains(bin) else {
                print("DEBUG: Skipping item with invalid bin value: \(bin)")
                continue
            }
            
            // Validate confidence value
            guard ["High", "Medium", "Low"].contains(confidence) else {
                print("DEBUG: Skipping item with invalid confidence value: \(confidence)")
                continue
            }
            
            let scanItem = ScanItem(
                name: name,
                bin: bin,
                confidence: confidence
            )
            
            scanItems.append(scanItem)
        }
        
        // Return empty array if no items found (not an error - image might not contain trash)
        return scanItems
    }
}

/// Error types for scanning
enum ScanError: LocalizedError {
    case scanFailed
    case networkError
    case invalidImage
    case apiError(String) // New error type for API-specific errors
    
    var errorDescription: String? {
        switch self {
        case .scanFailed:
            return "Could not scan photo. Try again."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .invalidImage:
            return "Invalid image. Please try taking another photo."
        case .apiError(let message):
            return "API error: \(message)"
        }
    }
}

/// Scan result item (D-001)
/// Represents a detected item from a scanned photo
struct ScanItem: Identifiable {
    let id = UUID()
    let name: String // Object name (e.g., "Soda Can")
    let bin: String // Which bin to throw into (e.g., "Recycle", "Compost", "Trash")
    let confidence: String // Confidence level (e.g., "High", "Medium", "Low")
}

