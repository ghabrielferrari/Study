//
//  TesteIOSApp.swift
//  TesteIOS
//
//  Created by Gabriel Ferrari on 07/10/25.
//

import SwiftUI

@main
struct TesteIOSApp: App {
    // acopla o AppDelegate (que inicia o firebase)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
