import SwiftUI

struct CustomARViewRepresentable: UIViewRepresentable {
    func makeUIView(context _: Context) -> CustomARView {
        return CustomARView()
    }

    func updateUIView(_: CustomARView, context _: Context) {}
}
