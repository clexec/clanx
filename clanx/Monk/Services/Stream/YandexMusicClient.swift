import Foundation
import YMAPI

final class YandexMusicClient {
    static let shared = YandexMusicClient()
    let client: YMClient?

    private init() {
        guard !PlaybackConfig.yandexToken.isEmpty else {
            client = nil
            return
        }
        let device = YMDevice.generateWebMimicDevice(uuid: PlaybackConfig.yandexDeviceUUID)
        client = YMClient.initialize(device: device, lang: .ru, uid: PlaybackConfig.yandexUserID, token: PlaybackConfig.yandexToken, xToken: PlaybackConfig.yandexXToken)
    }
}
