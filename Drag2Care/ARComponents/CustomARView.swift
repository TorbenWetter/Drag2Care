import ARKit
import RealityKit

class CustomARView: ARView {
    var sessionDelegate: CustomARSessionDelegate?

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

        sessionDelegate = CustomARSessionDelegate(arView: self)
        session.delegate = sessionDelegate
    }
}
