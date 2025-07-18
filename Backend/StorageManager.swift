import Foundation
import UIKit
import Supabase

class StorageManager: ObservableObject {
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func uploadFile(_ data: Data, filename: String, mimeType: String) async throws -> String {
        let bucket = supabase.storage.from("uploads")
        let path = "\(UUID().uuidString)-\(filename)"
        
        _ = try await bucket.upload(
            path,
            data: data,
            options: FileOptions(contentType: mimeType)
        )
        
        return path
    }
    
    func uploadText(_ text: String) async throws {
        _ = try await supabase
            .from("texts")
            .insert(["content": text])
            .execute()
    }
    
    func uploadImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "StorageManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG data"])
        }
        
        let filename = "photo-\(UUID().uuidString).jpg"
        return try await uploadFile(imageData, filename: filename, mimeType: "image/jpeg")
    }
    
    func uploadAudio(_ audioData: Data) async throws -> String {
        let filename = "audio-\(UUID().uuidString).m4a"
        return try await uploadFile(audioData, filename: filename, mimeType: "audio/m4a")
    }
}