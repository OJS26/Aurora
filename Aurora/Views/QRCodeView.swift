import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let alarm: Alarm
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    Text("Your QR Code")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Text("Print this and stick it somewhere that gets you out of bed — vitamins, bathroom mirror, kitchen")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    if let qrImage = generateQRCode(from: alarm.qrCodeValue) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .padding(16)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Text("This code is unique to your alarm.\nOnly this code will dismiss it.")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    ShareLink(item: Image(uiImage: generateQRCode(from: alarm.qrCodeValue) ?? UIImage()),
                              preview: SharePreview("Aurora QR Code", image: Image(uiImage: generateQRCode(from: alarm.qrCodeValue) ?? UIImage()))) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share / Print QR Code")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                        .frame(height: 32)
                }
            }
            .navigationTitle("QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.orange)
                }
            }
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "H"
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}
