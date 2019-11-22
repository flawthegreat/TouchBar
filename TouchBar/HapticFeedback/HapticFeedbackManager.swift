import IOKit

class HapticFeedbackManager {

    static let shared = HapticFeedbackManager()

    private let possibleDeviceIDs: [UInt64] = [
        0x200000001000000,
        0x300000080500000,
    ]
    private var deviceID: UInt64?
    private var actuator: CFTypeRef?


    private init() { updateActuator() }


    public func performHapticFeedback(ofStrength strength: Int) {
        guard deviceID != nil, actuator != nil else { return }
        let strength = max(1, min(6, Int32(strength)))

        var result: IOReturn

        result = MTActuatorOpen(actuator!)
        guard result == kIOReturnSuccess else {
            updateActuator()
            return
        }

        result = MTActuatorActuate(actuator!, strength, 0, 0, 0)
        guard result == kIOReturnSuccess else { return }

        MTActuatorClose(actuator!)
    }

    private func updateActuator() {
        if let actuatorReference = actuator {
            MTActuatorClose(actuatorReference)
            actuator = nil
        }

        if let correctDeviceID = deviceID {
            actuator = MTActuatorCreateFromDeviceID(correctDeviceID).takeRetainedValue()
        } else {
            possibleDeviceIDs.forEach { deviceID in
                guard self.deviceID == nil else { return }

                actuator = MTActuatorCreateFromDeviceID(deviceID).takeRetainedValue()
                if actuator != nil {
                    self.deviceID = deviceID
                    return
                }
            }
        }
    }
}
