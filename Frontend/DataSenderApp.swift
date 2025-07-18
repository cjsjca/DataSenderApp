import SwiftUI
import Supabase

class AppState: ObservableObject {
    let supabase: SupabaseClient
    
    init() {
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: SecretsManager.supabaseUrl)!,
            supabaseKey: SecretsManager.supabaseKey
        )
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