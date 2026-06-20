import SwiftUI

// MARK: - Good: thin coordinator + actor service + AsyncStream

// Example: a plant-watering tracker that fetches moisture readings.

enum MoistureEvent: Sendable {
    case reading(Double)
    case stable
    case error(String)
}

actor MoistureService {
    func monitor(sensorID: String) -> AsyncStream<MoistureEvent> {
        AsyncStream { continuation in
            let task = Task {
                for value in [0.2, 0.4, 0.6, 0.65] {
                    try? await Task.sleep(for: .milliseconds(100))
                    continuation.yield(.reading(value))
                }
                continuation.yield(.stable)
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

@MainActor
@Observable
final class PlantCoordinator {
    private let service: MoistureService
    var currentMoisture: Double?
    var status: String = "Waiting..."
    var isMonitoring: Bool = false

    init(service: MoistureService) {
        self.service = service
    }

    func startMonitoring(sensorID: String) {
        guard !isMonitoring else { return }
        isMonitoring = true

        Task {
            let stream = await service.monitor(sensorID: sensorID)
            for await event in stream {
                switch event {
                case .reading(let value):
                    currentMoisture = value
                    status = "Moisture: \(Int(value * 100))%"
                case .stable:
                    status = "Stable"
                    isMonitoring = false
                case .error(let message):
                    status = "Error: \(message)"
                    isMonitoring = false
                }
            }
        }
    }
}
