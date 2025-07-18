import Foundation
import SwiftUI

class StorageManager: ObservableObject {
    // No longer need Supabase client since we're using REST API directly
    
    init() {
        // No initialization needed
    }
    
    func uploadFile(_ data: Data, filename: String, mimeType: String) async throws -> String {
        let path = "\(UUID().uuidString)-\(filename)"
        let url = URL(string: "\(SecretsManager.supabaseUrl)/storage/v1/object/uploads/\(path)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(mimeType, forHTTPHeaderField: "Content-Type")
        request.setValue(SecretsManager.supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SecretsManager.supabaseKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = data
        
        let (_, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 200 {
            return path
        } else {
            throw NSError(domain: "StorageManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload file"])
        }
    }
    
    func uploadText(_ text: String) async throws {
        print("📤 Attempting to upload text: \(text)")
        print("🔑 Using Supabase URL: \(SecretsManager.supabaseUrl)")
        print("🔑 Using API Key prefix: \(SecretsManager.supabaseKey.prefix(20))...")
        
        // Use direct REST API call to bypass any auth issues
        let url = URL(string: "\(SecretsManager.supabaseUrl)/rest/v1/texts")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SecretsManager.supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SecretsManager.supabaseKey)", forHTTPHeaderField: "Authorization")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.timeoutInterval = 10 // 10 second timeout
        
        let body = ["content": text]
        let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
        
        print("📝 Request body: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
        print("🌐 Request URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("📨 Response status: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 201 {
                    print("✅ Upload successful!")
                } else {
                    let responseString = String(data: data, encoding: .utf8) ?? "No response"
                    print("❌ Upload failed with status \(httpResponse.statusCode): \(responseString)")
                    throw NSError(domain: "StorageManager", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: responseString])
                }
            }
        } catch {
            print("❌ Upload failed with error: \(error.localizedDescription)")
            print("🔍 Full error: \(error)")
            throw error
        }
    }
    
    func uploadImage(_ imageData: Data) async throws -> String {
        let filename = "photo-\(UUID().uuidString).jpg"
        return try await uploadFile(imageData, filename: filename, mimeType: "image/jpeg")
    }
    
    func uploadAudio(_ audioData: Data) async throws -> String {
        let filename = "audio-\(UUID().uuidString).m4a"
        return try await uploadFile(audioData, filename: filename, mimeType: "audio/m4a")
    }
}