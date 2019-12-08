import Foundation

public extension Notification.Name {
    static let touchBarItemWidthDidChange = Self("touchBarItemWidthDidChange")
    static let touchBarApplicationViewDidChangeWidth = Self("touchBarApplicationViewDidChangeWidth")
    static let touchBarApplicationDidChangeWidth = Self("touchBarApplicationDidChangeWidth")

    static let touchBarApplicationDidTerminate = Self("touchBarApplicatioDidTerminate")
    static let touchBarApplicationWillTerminate = Self("touchBarApplicatioWillTerminate")

    static let defaultAudioOutputDeviceHasChanged = Self("defaultAudioOutputDeviceHasChanged")
    static let volumeLevelHasChanged = Self("volumeLevelHasChanged")
}
