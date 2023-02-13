import ARKit
import RealityKit
import SwiftUI

class CustomARView: ARView, ARSessionDelegate {
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
    }

    @available(*, unavailable)
    dynamic required init?(coder _: NSCoder) {
        fatalError("This view does not support being initialized using init(coder:). Use init() instead.")
    }

    convenience init() {
        self.init(frame: UIScreen.main.bounds)

        let configuration = ARWorldTrackingConfiguration()

        if let detectionImages = ARReferenceImage.referenceImages(inGroupNamed: "Posters", bundle: Bundle.main) {
            configuration.detectionImages = detectionImages
        }

        session.run(configuration)

        session.delegate = self
    }

    func session(_: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                let image = imageAnchor.referenceImage

                let imageAnchorEntity = AnchorEntity(.image(group: "Posters", name: image.name!))

                let imagePlane = MeshResource.generatePlane(width: Float(image.physicalSize.width), height: Float(image.physicalSize.height))
                let imagePlaneMaterial = SimpleMaterial(color: .red, isMetallic: false)
                let imagePlaneEntity = ModelEntity(mesh: imagePlane, materials: [imagePlaneMaterial])

                imagePlaneEntity.transform = Transform(pitch: .pi / 2, yaw: .pi, roll: 0)

                imageAnchorEntity.addChild(imagePlaneEntity)

                scene.addAnchor(imageAnchorEntity)
            }
        }
    }
}
