//
//  ContentView.swift
//  TesteIOS
//
//  Created by Gabriel Ferrari on 07/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = FirestoreDemoViewModel()
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section("Quickstart") {
                    Button("Run Smoke Test") {
                        vm.smokeTest()
                    }

                    Button("Delete users & cities") {
                        vm.deleteButtonTapped()
                    }
                }

                Section("Queries") {
                    Button("Simple queries") {
                        FirestoreService.shared.simpleQueries()
                        vm.statusMessage = "🔎 Query executada com sucesso!"
                    }

                    Button("Order & limit") {
                        FirestoreService.shared.orderAndLimit()
                        vm.statusMessage = "📊 Order & Limit executado"
                    }
                }

                Section("Offline") {
                    Button("Listen to Offline") {
                        FirestoreService.shared.listenToOffline()
                        vm.statusMessage = "📡 Escutando alterações offline"
                    }
                    Button("Toggle Offline") {
                        FirestoreService.shared.toggleOffline()
                        vm.statusMessage = "🌐 Estado da rede alternado"
                    }
                }
            }
            .navigationTitle("Firestore Demo")
        }
        .alert(item: Binding(
            get: {
                vm.statusMessage == nil ? nil : Message(text: vm.statusMessage!)
            },
            set: { _ in vm.statusMessage = nil }
        )) { message in
            Alert(
                title: Text("Firestore"),
                message: Text(message.text),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
}
