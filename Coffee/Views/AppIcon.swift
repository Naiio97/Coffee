import SwiftUI

struct AppIcon: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 10) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Coffee")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

struct AppIcon_Previews: PreviewProvider {
    static var previews: some View {
        AppIcon()
            .frame(width: 512, height: 512)
            .previewLayout(.fixed(width: 512, height: 512))
    }
} 