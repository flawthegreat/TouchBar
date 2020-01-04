extension Notification.Name {
    static let touchBarItemWillChangeWidth = Self("touchBarItemWillChangeWidth")
    static let touchBarApplicationViewDidChangeWidth = Self("touchBarApplicationViewDidChangeWidth")
    static let touchBarApplicationDidChangeWidth = Self("touchBarApplicationDidChangeWidth")

    static let touchBarApplicationWillTerminate = Self("touchBarApplicatioWillTerminate")
    static let touchBarApplicationDidTerminate = Self("touchBarApplicatioDidTerminate")

    static let defaultAudioOutputDeviceHasChanged = Self("defaultAudioOutputDeviceHasChanged")
    static let volumeLevelHasChanged = Self("volumeLevelHasChanged")
}
