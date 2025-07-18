import Foundation

public class SecretsManager {
    
    static let shared = SecretsManager()
    
    private init() {
        // No longer need to load .env files
        // Secrets are now baked into the build via xcconfig
    }
    
    // MARK: - Supabase Configuration
    
    static var supabaseUrl: String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              !value.isEmpty,
              value != "$(SUPABASE_URL)" else {
            #if DEBUG
            return "https://example.supabase.co"  // Placeholder for development
            #else
            fatalError("Missing SUPABASE_URL in Info.plist. Please check your Config/Secrets.xcconfig file.")
            #endif
        }
        return value
    }
    
    static var supabaseKey: String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String,
              !value.isEmpty,
              value != "$(SUPABASE_KEY)" else {
            #if DEBUG
            return "placeholder-key"  // Placeholder for development
            #else
            fatalError("Missing SUPABASE_KEY in Info.plist. Please check your Config/Secrets.xcconfig file.")
            #endif
        }
        return value
    }
    
    // MARK: - Optional Properties (still from environment for CI/CD)
    
    static var supabaseProjectRef: String {
        // This can remain as environment variable for CI/CD purposes
        guard let value = ProcessInfo.processInfo.environment["SUPABASE_PROJECT_REF"] else {
            #if DEBUG
            return "placeholder-ref"  // Placeholder for development
            #else
            return ""  // Optional for device builds
            #endif
        }
        return value
    }
    
    static var supabaseAccessToken: String {
        // This can remain as environment variable for CI/CD purposes
        guard let value = ProcessInfo.processInfo.environment["SUPABASE_ACCESS_TOKEN"] else {
            #if DEBUG
            return "placeholder-token"  // Placeholder for development
            #else
            return ""  // Optional for device builds
            #endif
        }
        return value
    }
    
    // MARK: - GitHub Configuration
    
    static var githubToken: String {
        // This can remain as environment variable for CI/CD purposes
        guard let value = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] else {
            #if DEBUG
            return "placeholder-github-token"  // Placeholder for development
            #else
            return ""  // Optional for device builds
            #endif
        }
        return value
    }
}