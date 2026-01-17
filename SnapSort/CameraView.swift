//
//  CameraView.swift
//  SnapSort
//
//  Created by Abraham Ashvil on 1/13/26.
//

import SwiftUI
import UIKit
import AVFoundation

/// Custom Camera View matching the design
/// Uses AVFoundation for full UI control
struct CameraView: View {
    @Binding var capturedImage: UIImage?
    @Binding var isPresented: Bool
    var onBack: (() -> Void)? = nil // Optional callback for back button
    @State private var cameraManager = CameraManager()
    @State private var showPhotoLibrary = false
    
    var body: some View {
        ZStack {
            // Camera preview layer
            CameraPreviewView(session: cameraManager.session)
                .ignoresSafeArea()
            
            // Custom overlay UI - ensure it receives touch events
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    // Back button
                    Button(action: {
                        print("DEBUG: Back button tapped")
                        if let onBack = onBack {
                            print("DEBUG: Calling onBack callback")
                            onBack()
                        } else {
                            print("DEBUG: No onBack callback, setting isPresented to false")
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    // Settings icon
                    Button(action: {
                        print("DEBUG: Settings button tapped")
                        // TODO: Add settings functionality
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer()
                
                // Center instruction text
                Text("[put object in view]")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Spacer()
                
                // Bottom controls - floating buttons
                HStack {
                    // Gallery icon (bottom left) - opens photo library
                    Button(action: {
                        print("DEBUG: Gallery button tapped - opening photo library")
                        showPhotoLibrary = true
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 32)
                    
                    Spacer()
                    
                    // Capture button (bottom center)
                    Button(action: {
                        print("DEBUG: Capture button tapped")
                        cameraManager.capturePhoto { image in
                            if let image = image {
                                print("DEBUG: Photo captured, setting capturedImage")
                                capturedImage = image
                                // Don't dismiss camera here - let LandingPageView handle it via onChange
                            } else {
                                print("DEBUG: Photo capture returned nil")
                            }
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 60, height: 60)
                        }
                    }
                    
                    Spacer()
                    
                    // Spacer for alignment (bottom right)
                    Color.clear
                        .frame(width: 44, height: 44)
                        .padding(.trailing, 32)
                }
                .padding(.bottom, 50)
            }
            .ignoresSafeArea(edges: .bottom)
            
            // Dark overlay and scan box overlay - use same geometry reference
            // Make non-interactive so touches pass through to buttons
            GeometryReader { geometry in
                let screenHeight = geometry.size.height
                let screenWidth = geometry.size.width
                let boxHeight = screenHeight * 0.65 // 65% of screen height
                let boxWidth = screenWidth * 0.85
                let boxX = screenWidth / 2
                let boxY = screenHeight / 2
                
                ZStack {
                    // Dark overlay with cutout for scan area using custom shape
                    ScanAreaOverlayShape(
                        boxWidth: boxWidth,
                        boxHeight: boxHeight,
                        boxX: boxX,
                        boxY: boxY,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight
                    )
                    .fill(Color.black.opacity(0.5), style: FillStyle(eoFill: true))
                    .frame(width: screenWidth, height: screenHeight)
                    .position(x: screenWidth / 2, y: screenHeight / 2)
                    
                    // Scan box overlay (center) - aligned with cutout
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: boxWidth, height: boxHeight)
                        .position(x: boxX, y: boxY)
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false) // Allow touches to pass through to buttons
        }
        .onAppear {
            cameraManager.setupCamera()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .sheet(isPresented: $showPhotoLibrary) {
            PhotoLibraryPicker(selectedImage: $capturedImage, isPresented: $showPhotoLibrary)
        }
    }
}

/// Photo Library Picker using UIImagePickerController
/// Allows user to select a photo from their photo library
struct PhotoLibraryPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        print("DEBUG: Photo library picker created")
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoLibraryPicker
        
        init(_ parent: PhotoLibraryPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                print("DEBUG: Photo selected from library, size: \(image.size)")
                parent.selectedImage = image
            } else {
                print("DEBUG: Failed to extract image from picker")
            }
            // Dismiss the picker and then the SwiftUI sheet
            picker.dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.parent.isPresented = false
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("DEBUG: Photo library picker cancelled")
            // Dismiss the picker and then the SwiftUI sheet
            picker.dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.parent.isPresented = false
                }
            }
        }
    }
}

/// Camera Preview Layer using AVFoundation
struct CameraPreviewView: UIViewControllerRepresentable {
    let session: AVCaptureSession
    
    func makeUIViewController(context: Context) -> CameraPreviewViewController {
        let viewController = CameraPreviewViewController()
        viewController.captureSession = session
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: CameraPreviewViewController, context: Context) {
        // No updates needed
    }
}

/// Camera Preview View Controller
class CameraPreviewViewController: UIViewController {
    var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if previewLayer == nil, let session = captureSession {
            let layer = AVCaptureVideoPreviewLayer(session: session)
            layer.videoGravity = .resizeAspectFill
            layer.frame = view.bounds
            view.layer.insertSublayer(layer, at: 0)
            previewLayer = layer
        }
        
        previewLayer?.frame = view.bounds
    }
}

/// Camera Manager to handle AVFoundation camera session
@Observable
class CameraManager {
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "cameraSessionQueue")
    private var photoOutput: AVCapturePhotoOutput?
    
    init() {
    }
    
    func setupCamera() {
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    private func configureSession() {
        session.beginConfiguration()
        
        // Set session preset
        session.sessionPreset = .photo
        
        // Setup camera input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoDeviceInput) else {
            print("DEBUG: Failed to setup camera input")
            session.commitConfiguration()
            return
        }
        
        session.addInput(videoDeviceInput)
        
        // Setup photo output
        let photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            self.photoOutput = photoOutput
        }
        
        session.commitConfiguration()
        
        // Start session
        sessionQueue.async {
            self.session.startRunning()
            print("DEBUG: Camera session started")
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard let photoOutput = photoOutput else {
            print("DEBUG: Photo output not available")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        // Ensure we're on the session queue for capture
        sessionQueue.async {
            let settings = AVCapturePhotoSettings()
            
            // Retain the delegate - create a strong reference
            let photoCaptureDelegate = PhotoCaptureDelegate(completion: { image in
                DispatchQueue.main.async {
                    completion(image)
                }
            })
            
            // Capture photo on the session queue
            photoOutput.capturePhoto(with: settings, delegate: photoCaptureDelegate)
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
                print("DEBUG: Camera session stopped")
            }
        }
    }
}

/// Photo capture delegate
/// Retains itself until capture completes
class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void
    private var retainedSelf: PhotoCaptureDelegate?
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        super.init()
        // Retain self to prevent deallocation before capture completes
        self.retainedSelf = self
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        defer {
            // Release self after completion
            retainedSelf = nil
        }
        
        if let error = error {
            print("DEBUG: Photo capture error: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("DEBUG: Failed to convert photo to UIImage")
            completion(nil)
            return
        }
        
        print("DEBUG: Photo captured successfully, size: \(image.size)")
        completion(image)
    }
    
    // iOS 11+ method - use this if available
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("DEBUG: Photo capture finished with error: \(error.localizedDescription)")
        }
    }
}

/// Custom shape for dark overlay with cutout for scan area
struct ScanAreaOverlayShape: Shape {
    let boxWidth: CGFloat
    let boxHeight: CGFloat
    let boxX: CGFloat
    let boxY: CGFloat
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Create outer rectangle (full screen) - this will be filled
        path.addRect(CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        
        // Create inner rectangle (scan area) - this will be cut out
        let boxRect = CGRect(
            x: boxX - boxWidth / 2,
            y: boxY - boxHeight / 2,
            width: boxWidth,
            height: boxHeight
        )
        
        // Add the inner rectangle to create a cutout using even-odd fill rule
        var innerPath = Path()
        innerPath.addRoundedRect(in: boxRect, cornerSize: CGSize(width: 12, height: 12))
        path.addPath(innerPath)
        
        return path
    }
}
