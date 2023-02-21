import Foundation

class TimeLimitedFunction {
    private var lastCallTime: Date = .init(timeIntervalSince1970: 0)
    private let minTimeInterval: TimeInterval
    private let action: () -> Void

    init(minTimeInterval: TimeInterval, action: @escaping (() -> Void)) {
        self.minTimeInterval = minTimeInterval
        self.action = action
    }

    func callAsFunction() {
        let currentTime = Date()
        let timeSinceLastCall = currentTime.timeIntervalSince(lastCallTime)

        if timeSinceLastCall > minTimeInterval {
            action()
            lastCallTime = currentTime
        }
    }
}
