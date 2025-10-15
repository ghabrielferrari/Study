//
//  AppDelegate.swift
//  TesteIOS
//
//  Created by Gabriel Ferrari on 07/10/25.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

// UIResponder = recebe certos eventos globais, como mudancas de estados, notificacoes
// UIApplicationDelegate = responde esses certos eventos globais
class AppDelegate: UIResponder , UIApplicationDelegate {
        
    // didFinishLaunchingWithOptions = assim que o app termina de iniciar
    // UIApplication = seria o "maestro" que gerencia todos todo o ciclo de vida e eventos do app
    // launchOptions informa ao app como ele foi iniciado (se tocou no icone do app, se entrou pelas notificacoes..)
    // o metodo application, é o crucial do App, ele abre a possibilidade de configurar o app na sua inicializacao a partir do didFinishLaunchingWithOptions
    func application(
        _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // inicia o firebase por default
        FirebaseApp.configure()
        
        // ponto de entrada para configuracoes globais do firestore
        let settings = FirestoreSettings() // manter essa variavel apenas se for usa-la depois para personalizar e/ou aplicar configs no firestore
        Firestore.firestore().settings = settings
                
        return true
    }
    
    // quando o app vai sair do foco (ex: ao abrir uma ligacao)
    func applicationWillResignActive(_ application: UIApplication) {
        }
    
    // quando o app vai sair para o segundo plano
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    // quando o app esta voltando para a frente
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    // quando o app fica ativo (apos abrir ou voltar)
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    // antes do app fechar por completo
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
}
