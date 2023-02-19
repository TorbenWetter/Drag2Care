import ARKit
import RealityKit

class CustomARSessionDelegate: NSObject, ARSessionDelegate {
    var arView: ARView

    var imageAnchor: ARImageAnchor?
    var floorAnchor: ARPlaneAnchor?

    var anchorEntitiesByAnchor: [ARAnchor: AnchorEntity] = [:]

    let blueMaterial = SimpleMaterial(color: .blue, isMetallic: false)
    let orangeMaterial = SimpleMaterial(color: .orange, isMetallic: false)

    init(arView: ARView) {
        self.arView = arView
    }

    func session(_: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            switch anchor {
            // In case the anchor is an image anchor and there is no image anchor yet.
            case let imageAnchor as ARImageAnchor where self.imageAnchor == nil:
                self.imageAnchor = imageAnchor

                // Create an anchor entity for the image anchor, add model entities as children and add the anchor entity to the scene.
                guard let imageName = imageAnchor.referenceImage.name else { return }
                let anchorEntity = AnchorEntity(.image(group: "Posters", name: imageName))
                addEntitiesToImageAnchor(imageAnchor: imageAnchor, anchorEntity: anchorEntity)
                addAnchorEntity(anchor: imageAnchor, anchorEntity: anchorEntity)
            // In case the anchor is a plane anchor and it is classified as a floor.
            case let floorAnchor as ARPlaneAnchor where floorAnchor.classification == .floor:
                // Ensure that there is no floor anchor yet or the newly recognized floor is larger than the current floor.
                guard self.floorAnchor == nil || floorAnchor.planeExtent.width * floorAnchor.planeExtent.height > self.floorAnchor!.planeExtent.width * self.floorAnchor!.planeExtent.height else { return }

                // If the floor has been recognized before, remove its anchor entity from the scene.
                if self.floorAnchor != nil {
                    removeEntityByAnchor(anchor: self.floorAnchor!)
                }

                self.floorAnchor = floorAnchor

                // Create an anchor entity for the floor anchor, add model entities as children and add the anchor entity to the scene.
                let anchorEntity = AnchorEntity(anchor: floorAnchor)
                addEntitiesToFloorAnchor(floorAnchor: floorAnchor, anchorEntity: anchorEntity)
                addAnchorEntity(anchor: floorAnchor, anchorEntity: anchorEntity)
            default:
                continue
            }
        }
    }

    func session(_: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            switch anchor {
            // In case the anchor is an image anchor and it is the same as the current image anchor.
            case let imageAnchor as ARImageAnchor where imageAnchor == self.imageAnchor:
                // Ensure that the old poster entity exists.
                guard let anchorEntity = anchorEntitiesByAnchor[imageAnchor] else { return }

                // Remove the old model entities and add new ones as children to the anchor entity.
                anchorEntity.children.removeAll()
                addEntitiesToImageAnchor(imageAnchor: imageAnchor, anchorEntity: anchorEntity)
            // In case the anchor is a plane anchor and it is the same as the current floor anchor.
            case let floorAnchor as ARPlaneAnchor where floorAnchor == self.floorAnchor:
                // Ensure that the old floor entity exists.
                guard let anchorEntity = anchorEntitiesByAnchor[floorAnchor] else { return }

                // Remove the old model entities and add new ones as children to the anchor entity.
                anchorEntity.children.removeAll()
                addEntitiesToFloorAnchor(floorAnchor: floorAnchor, anchorEntity: anchorEntity)
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
                removeEntityByAnchor(anchor: imageAnchor)
                self.imageAnchor = nil
            case let floorAnchor as ARPlaneAnchor where floorAnchor == self.floorAnchor:
                removeEntityByAnchor(anchor: floorAnchor)
                self.floorAnchor = nil
            default:
                continue
            }
        }
    }

    func addEntitiesToImageAnchor(imageAnchor: ARImageAnchor, anchorEntity: AnchorEntity) {
        let posterEntity = buildPosterEntity(imageAnchor: imageAnchor)
        anchorEntity.addChild(posterEntity)
    }

    func addEntitiesToFloorAnchor(floorAnchor: ARPlaneAnchor, anchorEntity: AnchorEntity) {
        let floorEntity = buildFloorEntity(floorAnchor: floorAnchor)
        anchorEntity.addChild(floorEntity)

        let cabbageEntity = try! ModelEntity.loadModel(named: "Cabbage")
        anchorEntity.addChild(cabbageEntity)
    }

    func buildPosterEntity(imageAnchor: ARImageAnchor) -> ModelEntity {
        let image = imageAnchor.referenceImage
        let posterPlane = MeshResource.generatePlane(width: Float(image.physicalSize.width), height: Float(image.physicalSize.height))

        let posterEntity = ModelEntity(mesh: posterPlane, materials: [blueMaterial])
        posterEntity.transform = Transform(pitch: .pi / 2, yaw: .pi, roll: 0)
        return posterEntity
    }

    func buildFloorEntity(floorAnchor: ARPlaneAnchor) -> ModelEntity {
        let floorGeometry = floorAnchor.geometry

        var floorDescriptor = MeshDescriptor()
        floorDescriptor.positions = MeshBuffer(floorGeometry.vertices)
        floorDescriptor.primitives = .triangles(floorGeometry.triangleIndices.map { UInt32($0) })
        floorDescriptor.textureCoordinates = MeshBuffer(floorGeometry.textureCoordinates)

        return ModelEntity(mesh: try! .generate(from: [floorDescriptor]), materials: [orangeMaterial])
    }

    func addAnchorEntity(anchor: ARAnchor, anchorEntity: AnchorEntity) {
        anchorEntitiesByAnchor[anchor] = anchorEntity
        arView.scene.addAnchor(anchorEntity)
    }

    func removeEntityByAnchor(anchor: ARAnchor) {
        guard let anchorEntity = anchorEntitiesByAnchor[anchor] else { return }

        arView.scene.removeAnchor(anchorEntity)
        anchorEntitiesByAnchor.removeValue(forKey: anchor)
    }
}
