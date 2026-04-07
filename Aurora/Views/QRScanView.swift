import SwiftUI
import AVFoundation

struct QRScanView: View {
    let alarm: Alarm
    let onComplete: () -> Void
    
    @State private var showSuccess = false
    @State private var scanLineOffset: CGFloat = -140
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("Scan Your QR Code")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Text("Point the camera at your Aurora QR label")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Camera preview with scan line
                ZStack {
                    QRScannerPreview(expectedValue: alarm.qrCodeValue) {
                        showSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onComplete()
                        }
                    }
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    
                    // Corner brackets
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.orange, lineWidth: 2)
                        .frame(height: 300)
                    
                    // Scan line animation
                    if !showSuccess {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .orange.opacity(0.8), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 2)
                            .offset(y: scanLineOffset)
                            .animation(
                                .easeInOut(duration: 2).repeatForever(autoreverses: true),
                                value: scanLineOffset
                            )
                    }
                }
                .padding(.horizontal, 24)
                
                if showSuccess {
                    VStack(spacing: 8) {
                        Text("✅")
                            .font(.system(size: 48))
                        Text("You're up! Let's go!")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                    }
                } else {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 8, height: 8)
                            .scaleEffect(isAnimating ? 1.3 : 0.7)
                            .animation(.easeInOut(duration: 0.6).repeatForever(), value: isAnimating)
                        Text("Scanning...")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                }
                
                Spacer()
                    .frame(height: 32)
            }
        }
        .onAppear {
            isAnimating = true
            scanLineOffset = 140
        }
    }
}

// MARK: - Camera Preview
struct QRScannerPreview: UIViewRepresentable {
    let expectedValue: String
    let onScanSuccess: () -> Void
    
    func makeUIView(context: Context) -> QRScannerView {
        let view = QRScannerView()
        view.expectedValue = expectedValue
        view.onScanSuccess = onScanSuccess
        view.startScanning()
        return view
    }
    
    func updateUIView(_ uiView: QRScannerView, context: Context) {}
}

// MARK: - UIKit Scanner
class QRScannerView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    var expectedValue: String = ""
    var onScanSuccess: (() -> Void)?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    func startScanning() {
        captureSession = AVCaptureSession()
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("No camera device found")
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            print("Could not create camera input")
            return
        }
        
        guard let session = captureSession else { return }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCaptureMetadataOutput()
        
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr]
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = bounds
        
        if let preview = previewLayer {
            layer.addSublayer(preview)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
            print("QR scanner started, looking for: \(self.expectedValue)")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            return
        }
        
        print("QR scanned: \(object.stringValue ?? "nil")")
        print("Expected: \(expectedValue)")
        
        guard object.stringValue == expectedValue else {
            print("QR code doesn't match!")
            return
        }
        
        captureSession?.stopRunning()
        onScanSuccess?()
    }
}
