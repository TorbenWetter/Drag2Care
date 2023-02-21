import ARKit
import RealityKit

class CustomARSessionDelegate: NSObject, ARSessionDelegate {
    var arView: ARView

    var imageAnchor: ARImageAnchor?
    var floorAnchors: [ARPlaneAnchor] = []
    var largestFloorAnchor: ARPlaneAnchor?

    var timeLimitedFloorUpdate: TimeLimitedFunction?

    var anchorEntitiesByAnchor: [ARAnchor: AnchorEntity] = [:]

    let blueMaterial = SimpleMaterial(color: .blue, isMetallic: false)
    let orangeMaterial = SimpleMaterial(color: .orange, isMetallic: false)

    init(arView: ARView) {
        self.arView = arView
        super.init()

        timeLimitedFloorUpdate = TimeLimitedFunction(minTimeInterval: 0.5) { [weak self] in
            self?.updateLargestFloorAnchor()
        }
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
                floorAnchors.append(floorAnchor)

                // If the new floor anchor is larger or there hasn't been one, update the largest floor anchor and its corresponding anchor entity.
                if largestFloorAnchor == nil || floorAnchor.planeExtent.width * floorAnchor.planeExtent.height > largestFloorAnchor!.planeExtent.width * largestFloorAnchor!.planeExtent.height {
                    updateLargestFloorAnchor()
                }
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
            // In case the anchor is a plane anchor and it is classified as a floor.
            case let floorAnchor as ARPlaneAnchor where floorAnchor.classification == .floor:
                // Update the largest floor anchor and its corresponding anchor entity to notice changes in the plane extents.
                if let updateLargestFloorAnchor = timeLimitedFloorUpdate {
                    updateLargestFloorAnchor()
                }
            default:
                continue
            }
        }
    }

    func session(_: ARSession, didRemove anchors: [ARAnchor]) {
        for anchor in anchors {
            switch anchor {
            // In case the anchor is an image anchor and it is the same as the current image anchor.
            case let imageAnchor as ARImageAnchor where imageAnchor == self.imageAnchor:
                // Remove the anchor entity from the scene and set the image anchor variable to nil.
                removeEntityByAnchor(anchor: imageAnchor)
                self.imageAnchor = nil
            // In case the anchor is a plane anchor and it is classified as a floor.
            case let floorAnchor as ARPlaneAnchor where floorAnchor.classification == .floor:
                floorAnchors.removeAll { $0 == floorAnchor }

                // If the floor anchor was the largest one, update the largest floor anchor and its corresponding anchor entity.
                if floorAnchor == largestFloorAnchor {
                    updateLargestFloorAnchor()
                }
            default:
                continue
            }
        }
    }

    func updateLargestFloorAnchor() {
        // Retrieve the largest floor anchor by comparing the area of the plane extents.
        let largestFloorAnchor = floorAnchors.max { anchor1, anchor2 -> Bool in
            anchor1.planeExtent.width * anchor1.planeExtent.height < anchor2.planeExtent.width * anchor2.planeExtent.height
        }

        // Ensure that the largest floor anchor has changed.
        guard largestFloorAnchor != self.largestFloorAnchor else { return }

        // If a floor has been recognized before, remove its anchor entity from the scene.
        if let currentLargestFloorAnchor = self.largestFloorAnchor {
            removeEntityByAnchor(anchor: currentLargestFloorAnchor)
        }

        // Keep track of the new largest floor anchor which can also be nil.
        self.largestFloorAnchor = largestFloorAnchor

        // Ensure that the largest floor anchor is set.
        guard let largestFloorAnchor = largestFloorAnchor else { return }

        // Create an anchor entity for the largest floor anchor.
        let anchorEntity = AnchorEntity(anchor: largestFloorAnchor)

        // Add the the cabbage entity as child to the anchor entity.
        let cabbageEntity = buildCabbageEntity()
        anchorEntity.addChild(cabbageEntity)

        // Add the anchor entity to the scene.
        addAnchorEntity(anchor: largestFloorAnchor, anchorEntity: anchorEntity)
    }

    func addEntitiesToImageAnchor(imageAnchor: ARImageAnchor, anchorEntity: AnchorEntity) {
        let posterEntity = buildPosterEntity(imageAnchor: imageAnchor)
        anchorEntity.addChild(posterEntity)
    }

    func buildPosterEntity(imageAnchor: ARImageAnchor) -> ModelEntity {
        let image = imageAnchor.referenceImage
        let posterPlane = MeshResource.generatePlane(width: Float(image.physicalSize.width), height: Float(image.physicalSize.height))

        let posterEntity = ModelEntity(mesh: posterPlane, materials: [blueMaterial])
        posterEntity.transform = Transform(pitch: .pi / 2, yaw: .pi, roll: 0)
        return posterEntity
    }

    func buildCabbageEntity() -> ModelEntity {
        let cabbageEntity = try! ModelEntity.loadModel(named: "Cabbage")
        return cabbageEntity
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
