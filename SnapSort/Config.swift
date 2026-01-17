//
//  Config.swift
//  SnapSort
//
//  API Configuration for external services
//

import Foundation

struct APIConfig {
    /// OpenAI API Key for GPT-4o mini vision
    /// Get your API key from: https://platform.openai.com/api-keys
    /// IMPORTANT: Never commit API keys to git!
    /// 
    /// Set up the environment variable in Xcode:
    /// Product > Scheme > Edit Scheme > Run > Arguments > Environment Variables
    /// Name: OPENAI_API_KEY
    /// Value: your-api-key-here
    static var openAIAPIKey: String? {
        guard let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            print("DEBUG: Config - OPENAI_API_KEY environment variable not found")
            return nil
        }
        
        guard !key.isEmpty else {
            print("DEBUG: Config - OPENAI_API_KEY is empty")
            return nil
        }
        
        guard key != "YOUR_API_KEY_HERE" else {
            print("DEBUG: Config - OPENAI_API_KEY is still set to placeholder value")
            return nil
        }
        
        print("DEBUG: Config - OpenAI API key found and valid (length: \(key.count))")
        return key
    }
    
    static let openAIBaseURL = "https://api.openai.com/v1/chat/completions"
}

