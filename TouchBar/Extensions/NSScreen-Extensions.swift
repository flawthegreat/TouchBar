import Foundation

public extension NSScreen {
    static var displayBrightness: Double {
        get { return CoreDisplay_Display_GetUserBrightness(0) }
        set { CoreDisplay_Display_SetUserBrightness(0, max(0, min(1, newValue))) }
    }
}
