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
        guard let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
              !key.isEmpty,
              key != "YOUR_API_KEY_HERE" else {
            return nil
        }
        return key
    }
    
    static let openAIBaseURL = "https://api.openai.com/v1/chat/completions"
}

