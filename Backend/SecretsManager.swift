import Foundation
import DotEnv

public class SecretsManager {
    
    static let shared: SecretsManager = {
        // Load environment variables at startup
        let fileManager = FileManager.default
        let currentPath = fileManager.currentDirectoryPath
        let envPath = "\(currentPath)/.env"
        
        if fileManager.fileExists(atPath: envPath) {
            do {
                try DotEnv.load(path: envPath)
            } catch {
                print("Warning: Could not load .env file: \(error). Using system environment variables.")
            }
        } else {
            print("Notice: No .env file found at \(envPath). Using system environment variables.")
        }
        return SecretsManager()
    }()
    
    private init() {
        // Force initialization on app startup
    }
    
    // MARK: - Supabase Configuration
    
    static var supabaseUrl: String {
        guard let value = ProcessInfo.processInfo.environment["SUPABASE_URL"] else {
            #if DEBUG
            return "https://example.supabase.co"  // Placeholder for development
            #else
            fatalError("Missing SUPABASE_URL in environment. Please check your .env file or environment variables.")
            #endif
        }
        return value
    }
    
    static var supabaseKey: String {
        guard let value = ProcessInfo.processInfo.environment["SUPABASE_KEY"] else {
            #if DEBUG
            return "placeholder-key"  // Placeholder for development
            #else
            fatalError("Missing SUPABASE_KEY in environment. Please check your .env file or environment variables.")
            #endif
        }
        return value
    }
    
    static var supabaseProjectRef: String {
        guard let value = ProcessInfo.processInfo.environment["SUPABASE_PROJECT_REF"] else {
            #if DEBUG
            return "placeholder-ref"  // Placeholder for development
            #else
            fatalError("Missing SUPABASE_PROJECT_REF in environment. Please check your .env file or environment variables.")
            #endif
        }
        return value
    }
    
    static var supabaseAccessToken: String {
        guard let value = ProcessInfo.processInfo.environment["SUPABASE_ACCESS_TOKEN"] else {
            #if DEBUG
            return "placeholder-token"  // Placeholder for development
            #else
            fatalError("Missing SUPABASE_ACCESS_TOKEN in environment. Please check your .env file or environment variables.")
            #endif
        }
        return value
    }
    
    // MARK: - GitHub Configuration
    
    static var githubToken: String {
        guard let value = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] else {
            #if DEBUG
            return "placeholder-github-token"  // Placeholder for development
            #else
            fatalError("Missing GITHUB_TOKEN in environment. Please check your .env file or environment variables.")
            #endif
        }
        return value
    }
}