//
//  FirestoreDemoViewModel.swift
//  TesteIOS
//
//  Created by Gabriel Ferrari on 15/10/25.
//

import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
final class FirestoreDemoViewModel: ObservableObject {
    private let svc = FirestoreService.shared
    private var usersListener: ListenerRegistration?

    @Published var statusMessage: String?    // 🆕 feedback visual

    func smokeTest() {
        Task {
            await svc.addAdaLovelace()
            statusMessage = "✅ Ada Lovelace adicionada ao Firestore"

            await svc.addAlanTuring()
            statusMessage = "✅ Alan Turing adicionado ao Firestore"

            await svc.getUsersCollection()
            statusMessage = "📄 Dados de usuários carregados"

            usersListener = svc.listenForUsersBornBefore1900()
        }

        Task {
            await svc.setCityLA()
            statusMessage = "🏙️ Cidade LA salva!"

            await svc.dataTypesOne()
            statusMessage = "📦 DataTypes salvos!"

            await svc.addCityTokyo()
            statusMessage = "🌸 Cidade Tokyo adicionada!"

            await svc.updateCityDC()
            statusMessage = "🏛️ DC atualizada!"

            await svc.deleteCityDC()
            statusMessage = "🗑️ DC deletada!"
        }
    }

    func deleteButtonTapped() {
        svc.deleteCollection(named: "users")
        svc.deleteCollection(named: "cities")
        statusMessage = "🧹 Coleções 'users' e 'cities' foram apagadas"
    }

    deinit { usersListener?.remove() }
}
