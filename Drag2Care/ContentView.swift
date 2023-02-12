import ARKit
import RealityKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        ARSCNViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARSCNViewContainer: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)

        arView.delegate = context.coordinator

        let configuration = ARWorldTrackingConfiguration()

        if let detectionImages = ARReferenceImage.referenceImages(inGroupNamed: "Posters", bundle: Bundle.main) {
            configuration.detectionImages = detectionImages
        }

        arView.session.run(configuration)

        return arView
    }

    func updateUIView(_: ARSCNView, context _: Context) {}

    final class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARSCNViewContainer

        init(_ parent: ARSCNViewContainer) {
            self.parent = parent
        }

        func renderer(_: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            guard let imageAnchor = anchor as? ARImageAnchor else { return nil }

            let node = SCNNode()

            let imageSize = imageAnchor.referenceImage.physicalSize
            let imagePlane = SCNPlane(width: imageSize.width, height: imageSize.height)

            imagePlane.firstMaterial?.diffuse.contents = UIColor.red

            let imagePlaneNode = SCNNode(geometry: imagePlane)
            imagePlaneNode.eulerAngles.x = -.pi / 2

            node.addChildNode(imagePlaneNode)

            return node
        }
    }
}
