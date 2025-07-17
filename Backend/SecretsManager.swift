import Foundation
import DotEnv

public class SecretsManager {
    
    static let shared: SecretsManager = {
        // Load environment variables at startup
        do {
            try DotEnv.load()
        } catch {
            print("Warning: Could not load .env file. Using system environment variables.")
        }
        return SecretsManager()
    }()
    
    private init() {
        // Force initialization on app startup
    }
    
    // MARK: - Supabase Configuration
    
    static var supabaseUrl: String {
        guard let value = ProcessInfo.processInfo.environment["SUPABASE_URL"] else {
            fatalError("Missing SUPABASE_URL in environment. Please check your .env file or environment variables.")
        }
        return value
    }
    
    static var supabaseKey: String {
        guard let value = ProcessInfo.processInfo.environment["SUPABASE_KEY"] else {
            fatalError("Missing SUPABASE_KEY in environment. Please check your .env file or environment variables.")
        }
        return value
    }
    
    static var supabaseProjectRef: String {
        guard let value = ProcessInfo.processInfo.environment["SUPABASE_PROJECT_REF"] else {
            fatalError("Missing SUPABASE_PROJECT_REF in environment. Please check your .env file or environment variables.")
        }
        return value
    }
    
    static var supabaseAccessToken: String {
        guard let value = ProcessInfo.processInfo.environment["SUPABASE_ACCESS_TOKEN"] else {
            fatalError("Missing SUPABASE_ACCESS_TOKEN in environment. Please check your .env file or environment variables.")
        }
        return value
    }
    
    // MARK: - GitHub Configuration
    
    static var githubToken: String {
        guard let value = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] else {
            fatalError("Missing GITHUB_TOKEN in environment. Please check your .env file or environment variables.")
        }
        return value
    }
}