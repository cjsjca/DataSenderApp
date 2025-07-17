import SwiftUI
import Supabase

@main
struct DataSenderApp: App {
    let supabase = SupabaseClient(
        supabaseURL: URL(string: SecretsManager.supabaseUrl)!,
        supabaseKey: SecretsManager.supabaseKey
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(supabase)
        }
    }
}