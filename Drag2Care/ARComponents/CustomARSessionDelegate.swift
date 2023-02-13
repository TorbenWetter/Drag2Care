import ARKit
import RealityKit

class CustomARSessionDelegate: NSObject, ARSessionDelegate {
    var arView: ARView

    init(arView: ARView) {
        self.arView = arView
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

                arView.scene.addAnchor(imageAnchorEntity)
            }

            if let planeAnchor = anchor as? ARPlaneAnchor {
                let floorSphere = MeshResource.generateSphere(radius: 0.1)
                let floorSphereMaterial = SimpleMaterial(color: .orange, isMetallic: false)
                let floorSphereEntity = ModelEntity(mesh: floorSphere, materials: [floorSphereMaterial])

                let planeAnchorEntity = AnchorEntity(anchor: planeAnchor)

                planeAnchorEntity.addChild(floorSphereEntity)

                arView.scene.addAnchor(planeAnchorEntity)
            }
        }
    }
}
