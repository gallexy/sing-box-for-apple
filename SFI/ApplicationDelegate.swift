import ApplicationLibrary
import Foundation
import Library
import UIKit

class ApplicationDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        NSLog("Here I stand")
        ServiceNotification.register()
        Task.detached {
            do {
                try await UIProfileUpdateTask.setup()
                NSLog("setup background task success")
            } catch {
                NSLog("setup background task error: \(error.localizedDescription)")
            }
        }
        Task.detached {
            await self.requestNetworkPermission()
        }
        return true
    }

    private func requestNetworkPermission() {
        if UIDevice.current.userInterfaceIdiom != .phone {
            return
        }
        if SharedPreferences.networkPermissionRequested {
            return
        }
        if !DeviceCensorship.isChinaDevice() {
            SharedPreferences.networkPermissionRequested = true
            return
        }
        URLSession.shared.dataTask(with: URL(string: "http://captive.apple.com")!) { _, response, _ in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    SharedPreferences.networkPermissionRequested = true
                }
            }
        }.resume()
    }
}