//
//  ContentView.swift
//  TesteIOS
//
//  Created by Gabriel Ferrari on 07/10/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var myUid: String? = Auth.auth().currentUser?.uid
    @State private var roomCode: String = ""
    @State private var showChat = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Autenticação") {
                    if let uid = myUid {
                        Label("Logado anonimamente", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text("UID: \(uid)").font(.footnote).textSelection(.enabled)
                    } else {
                        Button("Entrar anonimamente") {
                            Task {
                                do {
                                    let result = try await Auth.auth().signInAnonymously()
                                    myUid = result.user.uid
                                } catch {
                                    print("Erro auth:", error)
                                }
                            }
                        }
                    }
                }

                Section("Sala (chave compartilhada)") {
                    TextField("Ex.: sala123", text: $roomCode)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button("Entrar na conversa") {
                        showChat = true
                    }
                    .disabled(myUid == nil || roomCode.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("Chat Criptografado (demo)")
            .navigationDestination(isPresented: $showChat) {
                if let myUid {
                    ChatView(roomCode: roomCode, myUid: myUid)
                }
            }
        }
    }
}
