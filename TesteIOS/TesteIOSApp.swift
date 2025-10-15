//
//  TesteIOSApp.swift
//  TesteIOS
//
//  Created by Gabriel Ferrari on 07/10/25.
//

import SwiftUI

@main // define o ponto de entrada do ciclo de vida do IOS
struct TesteIOSApp: App {
    // acopla o AppDelegate (que inicia o firestore)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
