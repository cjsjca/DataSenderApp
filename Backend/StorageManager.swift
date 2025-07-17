import Foundation
import Supabase

class StorageManager: ObservableObject {
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func uploadFile(_ data: Data, filename: String, mimeType: String) async throws -> String {
        let bucket = supabase.storage.from("uploads")
        let path = "\(UUID().uuidString)-\(filename)"
        
        let uploadResponse = try await bucket.upload(
            path: path,
            file: data,
            options: FileOptions(contentType: mimeType)
        )
        
        return path
    }
    
    func uploadText(_ text: String) async throws {
        _ = try await supabase.database
            .from("texts")
            .insert(["content": text])
            .execute()
    }
}