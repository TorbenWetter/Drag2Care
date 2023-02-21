import Combine
import RealityKit
import UIKit

class Model {
    var modelEntity: ModelEntity?

    private var cancellable: AnyCancellable?

    init(named: String) {
        cancellable = ModelEntity.loadModelAsync(named: named)
            .sink(receiveCompletion: { loadCompletion in
                if case let .failure(error) = loadCompletion {
                    print("Unable to load modelEntity for modelName \(named): \(error.localizedDescription)")
                }
            }, receiveValue: { modelEntity in
                self.modelEntity = modelEntity
            })
    }
}
