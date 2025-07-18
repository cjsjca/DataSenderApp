import SwiftUI
import AVFoundation
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
    @State private var showCamera = false
    @State private var showFilePicker = false
    @State private var showImagePicker = false
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
            
            Button(action: takePhoto) {
                Text("Take Photo")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isUploading)
            .accessibilityIdentifier("takePhotoButton")
            
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
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showFilePicker) {
            DocumentPicker(completion: uploadFile)
        }
        .alert("Upload Result", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onChange(of: selectedImage) { oldValue, newValue in
            if let image = newValue {
                uploadImage(image)
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
    
    func takePhoto() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    showCamera = true
                } else {
                    uploadStatus = "Camera permission denied"
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
        
        isUploading = true
        uploadStatus = ""
        
        Task {
            do {
                let key = try await storageManager.uploadImage(image)
                await MainActor.run {
                    isUploading = false
                    uploadStatus = "Photo uploaded successfully"
                    selectedImage = nil
                    showCamera = false  // Dismiss the camera picker
                    showAlert = true
                    alertMessage = "Photo uploaded successfully to: \(key)"
                    print("Stored at:", key)
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    uploadStatus = "Failed to upload photo: \(error.localizedDescription)"
                    showCamera = false  // Dismiss the camera picker
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

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let completion: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let completion: (URL) -> Void
        
        init(completion: @escaping (URL) -> Void) {
            self.completion = completion
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                completion(url)
            }
        }
    }
}

#Preview {
    ContentView()
}