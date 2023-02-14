import ARKit
import RealityKit

class CustomARSessionDelegate: NSObject, ARSessionDelegate {
    var arView: ARView

    var imageAnchor: ARImageAnchor?
    var floorAnchor: ARPlaneAnchor?

    var imageAnchorEntity: AnchorEntity?
    var floorAnchorEntity: AnchorEntity?

    init(arView: ARView) {
        self.arView = arView
    }

    func session(_: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            switch anchor {
            // In case the anchor is an image anchor and there is no image anchor yet.
            case let imageAnchor as ARImageAnchor where self.imageAnchor == nil:
                let image = imageAnchor.referenceImage

                let imageAnchorEntity = AnchorEntity(.image(group: "Posters", name: image.name!))

                // Create a plane entity with the same width and height as the image and add it to the image anchor entity.
                let planeEntity = generatePlaneEntity(width: Float(image.physicalSize.width), height: Float(image.physicalSize.height), color: .blue)
                imageAnchorEntity.addChild(planeEntity)

                // Keep track of the image anchor and its corresponding entity, and add the entity to the scene.
                self.imageAnchor = imageAnchor
                self.imageAnchorEntity = imageAnchorEntity
                arView.scene.addAnchor(imageAnchorEntity)
            // In case the anchor is a floor anchor and there is no floor anchor yet or the new floor anchor is larger than the current floor anchor.
            case let floorAnchor as ARPlaneAnchor where floorAnchor.classification == .floor && (self.floorAnchor == nil || floorAnchor.planeExtent.width * floorAnchor.planeExtent.height > self.floorAnchor!.planeExtent.width * self.floorAnchor!.planeExtent.height):
                if self.floorAnchor != nil {
                    // If there is already a floor anchor, remove it from the scene.
                    self.floorAnchorEntity?.removeFromParent()
                }

                let floorAnchorEntity = AnchorEntity(anchor: floorAnchor)

                // Create a sphere entity with a radius of 0.1 and add it to the floor anchor entity.
                let sphereEntity = generateSphereEntity(radius: 0.1, color: .orange)
                floorAnchorEntity.addChild(sphereEntity)

                // Keep track of the floor anchor and its corresponding entity, and add the entity to the scene.
                self.floorAnchor = floorAnchor
                self.floorAnchorEntity = floorAnchorEntity
                arView.scene.addAnchor(floorAnchorEntity)
            default:
                continue
            }
        }
    }

    func session(_: ARSession, didRemove anchors: [ARAnchor]) {
        // When the anchors are removed, remove the corresponding entities from the scene and set the anchor variables to nil.
        for anchor in anchors {
            switch anchor {
            case let imageAnchor as ARImageAnchor where imageAnchor == self.imageAnchor:
                imageAnchorEntity?.removeFromParent()
                imageAnchorEntity = nil
                self.imageAnchor = nil
            case let floorAnchor as ARPlaneAnchor where floorAnchor == self.floorAnchor:
                floorAnchorEntity?.removeFromParent()
                floorAnchorEntity = nil
                self.floorAnchor = nil
            default:
                continue
            }
        }
    }

    func generatePlaneEntity(width: Float, height: Float, color: UIColor) -> ModelEntity {
        // Create a plane entity with the specified width and height and a material with the specified color.
        let plane = MeshResource.generatePlane(width: width, height: height)
        let planeMaterial = SimpleMaterial(color: color, isMetallic: false)
        let planeEntity = ModelEntity(mesh: plane, materials: [planeMaterial])

        // Rotate the plane so it is perpendicular to the ground.
        planeEntity.transform = Transform(pitch: .pi / 2, yaw: .pi, roll: 0)

        return planeEntity
    }

    func generateSphereEntity(radius: Float, color: UIColor) -> ModelEntity {
        // Create a sphere entity with the specified radius and a material with the specified color.
        let sphere = MeshResource.generateSphere(radius: radius)
        let sphereMaterial = SimpleMaterial(color: color, isMetallic: false)
        let sphereEntity = ModelEntity(mesh: sphere, materials: [sphereMaterial])

        return sphereEntity
    }
}
