//
//  AppDelegate.swift
//  TesteIOS
//
//  Created by Gabriel Ferrari on 07/10/25.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        // evita confusao de cache para testes
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        Firestore.firestore().settings = settings

        return true
    }
}
