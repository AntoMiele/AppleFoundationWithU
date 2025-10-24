//
//  AppDelegate.swift
//  Map_iOS
//
//  Created by san-12 on 23/10/25.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        // Passa il completion handler al dispatcher: lo chiameremo quando la sessione ha finito.
        /*SOSDispatcher.shared.setBackgroundCompletionHandler(completionHandler)
         */}
}
