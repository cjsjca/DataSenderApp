import SwiftUI

class AppState: ObservableObject {
    // Remove Supabase dependency completely for now
    init() {
        print("AppState init - Testing credentials loading...")
        print("Supabase URL from Bundle: \(SecretsManager.supabaseUrl)")
        print("Supabase Key prefix: \(SecretsManager.supabaseKey.prefix(20))...")
    }
}

@main
struct DataSenderApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.none) // Follows system setting
        }
    }
}
