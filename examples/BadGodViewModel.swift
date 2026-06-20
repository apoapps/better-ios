import SwiftUI
import SwiftData
import Foundation

// MARK: - Bad: god coordinator mixing everything

// This is the anti-pattern. A single type imports SwiftUI, SwiftData, and
// Foundation, and owns persistence, network, runtime simulation, haptics,
// widget sync, and UI presentation state.

@MainActor
@Observable
final class PlantDashboardViewModel {
    // UI state
    var plants: [Plant] = []
    var selectedPlantID: String?
    var isLoading: Bool = false
    var isAddSheetPresented: Bool = false
    var isDetailSheetPresented: Bool = false

    // Persistence
    var modelContainer: ModelContainer?
    var context: ModelContext?

    // Network / runtime
    var moistureTimer: Timer?
    var lastSensorReading: Double?

    // Widget sync
    func syncWidgetPlants() {
        // Widget update logic here
    }

    // Haptics
    func hapticSuccess() {
        // UINotificationFeedbackGenerator logic here
    }

    func addPlant(name: String) {
        let plant = Plant(name: name)
        plants.append(plant)

        moistureTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.lastSensorReading = Double.random(in: 0...1)
            self.hapticSuccess()
            self.syncWidgetPlants()

            if let context {
                try? context.save()
            }
        }
    }

    func loadPlants() {
        guard let context else { return }
        // SwiftData fetch
    }

    func deletePlant(_ plant: Plant) {
        // SwiftData delete
    }
}

struct Plant: Identifiable {
    let id = UUID()
    var name: String
}
