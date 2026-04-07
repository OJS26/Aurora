import SwiftUI
import AVFoundation

struct QRScanView: View {
    let alarm: Alarm
    let onComplete: () -> Void
    
    @State private var showSuccess = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("Scan Your QR Code")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Text("Find the label you placed and scan it to dismiss the alarm")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Camera preview
                QRScannerPreview(expectedValue: alarm.qrCodeValue) {
                    showSuccess = true
                    onComplete()
                }
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 24)
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.orange, lineWidth: 2)
                        .padding(.horizontal, 24)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }
                
                Spacer()
                
                if showSuccess {
                    Text("✅ You're up! Let's go!")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                }
                
                Spacer()
                    .frame(height: 32)
            }
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
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              let session = captureSession else { return }
        
        session.addInput(input)
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = bounds
        
        if let preview = previewLayer {
            layer.addSublayer(preview)
        }
        
        DispatchQueue.global(qos: .background).async {
            session.startRunning()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              object.stringValue == expectedValue else { return }
        
        captureSession?.stopRunning()
        onScanSuccess?()
    }
}
