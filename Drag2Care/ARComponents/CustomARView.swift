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

        // Create an instance of CustomARSessionDelegate to handle ARSessionDelegate callbacks.
        sessionDelegate = CustomARSessionDelegate(arView: self)
        session.delegate = sessionDelegate

        // Configure image and plane tracking using the ARWorldTrackingConfiguration and run the session.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        if let detectionImages = ARReferenceImage.referenceImages(inGroupNamed: "Posters", bundle: Bundle.main) {
            configuration.detectionImages = detectionImages
        }
        configuration.environmentTexturing = .automatic
        session.run(configuration)

        // Add a coaching overlay to the view to prompt the user to find a horizontal plane.
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(coachingOverlay)
    }
}
