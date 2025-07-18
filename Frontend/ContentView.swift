import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import Supabase

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var storageManager: StorageManager?
    
    @State private var isRecording = false
    @State private var showTextInput = false
    @State private var textInput = ""
    @State private var showFilePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isUploading = false
    @State private var uploadStatus = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Button(action: toggleRecording) {
                    Text(isRecording ? "Stop Recording" : "Record Audio")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isRecording ? Color.red : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isUploading)
                .accessibilityIdentifier("recordAudioButton")
                
                Button(action: { showTextInput.toggle() }) {
                    Text("Text Input")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isUploading)
                .accessibilityIdentifier("textInputButton")
            
            if showTextInput {
                VStack {
                    TextEditor(text: $textInput)
                        .frame(height: 150)
                        .padding(4)
                        .background(Color(UIColor.secondarySystemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.separator), lineWidth: 1)
                        )
                        .cornerRadius(8)
                        .accessibilityIdentifier("textInputEditor")
                    
                    Button(action: sendText) {
                        Text("Send")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(textInput.isEmpty || isUploading)
                    .accessibilityIdentifier("sendTextButton")
                }
                .padding(.horizontal)
            }
            
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Text("Select Photo")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isUploading)
            .accessibilityIdentifier("selectPhotoButton")
            
            Button(action: { showFilePicker = true }) {
                Text("Upload File")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isUploading)
            .accessibilityIdentifier("uploadFileButton")
            
            if isUploading {
                ProgressView("Uploading...")
                    .padding()
                    .accessibilityIdentifier("uploadingIndicator")
            }
            
            if !uploadStatus.isEmpty {
                Text(uploadStatus)
                    .foregroundColor(uploadStatus.contains("successfully") ? .green : .red)
                    .padding()
            }
            
                Spacer()
            }
            .padding()
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    uploadFile(url: url)
                }
            case .failure(let error):
                uploadStatus = "Failed to select file: \(error.localizedDescription)"
                showAlert = true
                alertMessage = "Failed to select file: \(error.localizedDescription)"
            }
        }
        .alert("Upload Result", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            Task {
                if let item = newValue {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        uploadImage(image)
                    }
                }
            }
        }
        .onAppear {
            storageManager = StorageManager(supabase: appState.supabase)
        }
    }
    
    func toggleRecording() {
        if isRecording {
            audioRecorder.stopRecording()
            isRecording = false
            if let audioURL = audioRecorder.audioFileURL {
                uploadAudio(url: audioURL)
            }
        } else {
            audioRecorder.requestPermission { granted in
                if granted {
                    audioRecorder.startRecording()
                    isRecording = true
                } else {
                    uploadStatus = "Microphone permission denied"
                }
            }
        }
    }
    
    func sendText() {
        guard let storageManager = storageManager else { return }
        
        isUploading = true
        uploadStatus = ""
        
        Task {
            do {
                try await storageManager.uploadText(textInput)
                await MainActor.run {
                    isUploading = false
                    uploadStatus = "Text saved successfully"
                    textInput = ""
                    showTextInput = false
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    uploadStatus = "Failed to save text: \(error.localizedDescription)"
                }
            }
        }
    }
    
    
    func uploadAudio(url: URL) {
        guard let storageManager = storageManager else { return }
        
        isUploading = true
        uploadStatus = ""
        
        Task {
            do {
                let data = try Data(contentsOf: url)
                let key = try await storageManager.uploadAudio(data)
                await MainActor.run {
                    isUploading = false
                    uploadStatus = "Audio uploaded successfully"
                    showAlert = true
                    alertMessage = "Audio uploaded successfully to: \(key)"
                    print("Stored at:", key)
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    uploadStatus = "Failed to upload audio: \(error.localizedDescription)"
                    showAlert = true
                    alertMessage = "Failed to upload audio: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func uploadImage(_ image: UIImage) {
        guard let storageManager = storageManager else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            uploadStatus = "Failed to convert image to JPEG data"
            return
        }
        
        isUploading = true
        uploadStatus = ""
        
        Task {
            do {
                let key = try await storageManager.uploadImage(imageData)
                await MainActor.run {
                    isUploading = false
                    uploadStatus = "Photo uploaded successfully"
                    selectedImage = nil
                    selectedPhotoItem = nil
                    showAlert = true
                    alertMessage = "Photo uploaded successfully to: \(key)"
                    print("Stored at:", key)
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    uploadStatus = "Failed to upload photo: \(error.localizedDescription)"
                    selectedPhotoItem = nil
                    showAlert = true
                    alertMessage = "Failed to upload photo: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func uploadFile(url: URL) {
        guard let storageManager = storageManager else { return }
        
        isUploading = true
        uploadStatus = ""
        
        Task {
            do {
                let data = try Data(contentsOf: url)
                let mimeType = getMimeType(for: url)
                let key = try await storageManager.uploadFile(data, filename: url.lastPathComponent, mimeType: mimeType)
                await MainActor.run {
                    isUploading = false
                    uploadStatus = "File uploaded successfully"
                    showAlert = true
                    alertMessage = "File uploaded successfully to: \(key)"
                    print("Stored at:", key)
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    uploadStatus = "Failed to upload file: \(error.localizedDescription)"
                    showAlert = true
                    alertMessage = "Failed to upload file: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func getMimeType(for url: URL) -> String {
        if let uti = UTType(filenameExtension: url.pathExtension) {
            return uti.preferredMIMEType ?? "application/octet-stream"
        }
        return "application/octet-stream"
    }
}



#Preview {
    ContentView()
}