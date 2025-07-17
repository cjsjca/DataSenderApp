import Foundation
import DotEnv

public class SecretsManager {
    private static let shared = SecretsManager()
    private var env: DotEnv?
    
    private init() {
        loadEnvironment()
    }
    
    private func loadEnvironment() {
        let envPath = Bundle.main.path(forResource: ".env", ofType: nil) ?? ".env"
        do {
            env = try DotEnv.read(path: envPath)
        } catch {
            print("Warning: Could not load .env file. Using system environment variables.")
        }
    }
    
    private static func getValue(for key: String) -> String {
        // First try DotEnv, then fall back to ProcessInfo
        if let value = shared.env?[key], !value.isEmpty {
            return value
        }
        
        if let value = ProcessInfo.processInfo.environment[key], !value.isEmpty {
            return value
        }
        
        fatalError("Missing \(key) in environment. Please check your .env file or environment variables.")
    }
    
    // MARK: - Supabase
    static var supabaseUrl: String {
        getValue(for: "SUPABASE_URL")
    }
    
    static var supabaseKey: String {
        getValue(for: "SUPABASE_KEY")
    }
    
    static var supabaseProjectRef: String {
        getValue(for: "SUPABASE_PROJECT_REF")
    }
    
    static var supabaseAccessToken: String {
        getValue(for: "SUPABASE_ACCESS_TOKEN")
    }
    
    // MARK: - OpenAI
    static var openAIApiKey: String {
        getValue(for: "OPENAI_API_KEY")
    }
    
    static var openAIOrgId: String? {
        try? getValue(for: "OPENAI_ORG_ID")
    }
    
    // MARK: - AWS
    static var awsAccessKeyId: String {
        getValue(for: "AWS_ACCESS_KEY_ID")
    }
    
    static var awsSecretAccessKey: String {
        getValue(for: "AWS_SECRET_ACCESS_KEY")
    }
    
    static var awsRegion: String {
        getValue(for: "AWS_REGION")
    }
    
    static var awsS3Bucket: String? {
        try? getValue(for: "AWS_S3_BUCKET")
    }
    
    // MARK: - Google Cloud
    static var googleCloudProjectId: String {
        getValue(for: "GOOGLE_CLOUD_PROJECT_ID")
    }
    
    static var googleCloudApiKey: String {
        getValue(for: "GOOGLE_CLOUD_API_KEY")
    }
    
    // MARK: - Firebase
    static var firebaseApiKey: String {
        getValue(for: "FIREBASE_API_KEY")
    }
    
    static var firebaseProjectId: String {
        getValue(for: "FIREBASE_PROJECT_ID")
    }
    
    static var firebaseAuthDomain: String {
        getValue(for: "FIREBASE_AUTH_DOMAIN")
    }
    
    // MARK: - Stripe
    static var stripePublishableKey: String {
        getValue(for: "STRIPE_PUBLISHABLE_KEY")
    }
    
    static var stripeSecretKey: String {
        getValue(for: "STRIPE_SECRET_KEY")
    }
    
    // MARK: - Twilio
    static var twilioAccountSid: String {
        getValue(for: "TWILIO_ACCOUNT_SID")
    }
    
    static var twilioAuthToken: String {
        getValue(for: "TWILIO_AUTH_TOKEN")
    }
    
    static var twilioPhoneNumber: String {
        getValue(for: "TWILIO_PHONE_NUMBER")
    }
    
    // MARK: - SendGrid
    static var sendGridApiKey: String {
        getValue(for: "SENDGRID_API_KEY")
    }
    
    // MARK: - Slack
    static var slackBotToken: String {
        getValue(for: "SLACK_BOT_TOKEN")
    }
    
    static var slackSigningSecret: String {
        getValue(for: "SLACK_SIGNING_SECRET")
    }
    
    // MARK: - GitHub
    static var githubAccessToken: String {
        getValue(for: "GITHUB_ACCESS_TOKEN")
    }
    
    static var githubToken: String {
        getValue(for: "GITHUB_TOKEN")
    }
    
    // MARK: - Custom API
    static var apiBaseUrl: String {
        getValue(for: "API_BASE_URL")
    }
    
    static var apiKey: String {
        getValue(for: "API_KEY")
    }
    
    // MARK: - App Configuration
    static var environment: String {
        getValue(for: "ENVIRONMENT")
    }
    
    static var debugMode: Bool {
        (try? getValue(for: "DEBUG_MODE").lowercased()) == "true"
    }
}

// MARK: - Optional Extensions
extension SecretsManager {
    private static func getValue(for key: String) throws -> String {
        if let value = shared.env?[key], !value.isEmpty {
            return value
        }
        
        if let value = ProcessInfo.processInfo.environment[key], !value.isEmpty {
            return value
        }
        
        throw SecretsError.missingKey(key)
    }
}

enum SecretsError: LocalizedError {
    case missingKey(String)
    
    var errorDescription: String? {
        switch self {
        case .missingKey(let key):
            return "Missing environment variable: \(key)"
        }
    }
}