//
//  ContentView.swift
//  TesteIOS
//
//  Created by Gabriel Ferrari on 07/10/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

/// Tela inicial: autentica anonimamente, reserva um username único e entra numa sala.
@MainActor
struct ContentView: View {

    // MARK: - UI State
    @State private var myUid: String? = Auth.auth().currentUser?.uid
    @State private var username: String = ""
    @State private var roomCode: String = ""
    @State private var errorMessage: String?
    @State private var showChat: Bool = false

    // MARK: - Firebase
    private let db = Firestore.firestore()

    // MARK: - View
    var body: some View {
        NavigationStack {
            Form {
                identificationSection
                roomSection
                errorSection
            }
            .navigationTitle("Chat")
            .navigationDestination(isPresented: $showChat) {
                if let myUid {
                    ChatView(roomCode: roomCode, myUid: myUid)
                }
            }
        }
    }

    // MARK: - Sections
    private var identificationSection: some View {
        Section("Identificação") {
            if let uid = myUid {
                Label("Logado como \(displayName)", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(.green)

                Text("UID: \(uid)")
                    .font(.footnote)
                    .textSelection(.enabled)

                // Botão de sair
                Button(role: .destructive) {
                    handleSignOut()
                } label: {
                    Text("Sair")
                }

            } else {
                TextField("Escolha um username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                Button("Entrar") {
                    Task { await handleLoginAndUsername() }
                }
                .disabled(sanitizedUsername.isEmpty)
            }
        }
    }

    private var roomSection: some View {
        Section("Sala (chave compartilhada)") {
            TextField("Ex.: sala123", text: $roomCode)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            Button("Entrar na conversa") {
                showChat = true
            }
            .disabled(myUid == nil || sanitizedRoomCode.isEmpty)
        }
    }

    private var errorSection: some View {
        Group {
            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
    }

    // MARK: - Intent
    /// Fluxo: login anônimo + reserva de username único via transação.
    private func handleLoginAndUsername() async {
        errorMessage = nil
        let uname = sanitizedUsername
        guard !uname.isEmpty else {
            errorMessage = "Informe um username."
            return
        }

        do {
            let authResult = try await Auth.auth().signInAnonymously()
            let uid = authResult.user.uid
            try await reserveUsernameTransaction(username: uname, uid: uid)
            myUid = uid
        } catch {
            let e = error as NSError
            print("FIREBASE ERROR: domain=\(e.domain) code=\(e.code) userInfo=\(e.userInfo)")
            errorMessage = e.localizedDescription
        }
    }

    /// Faz logout do Firebase (teste).
    private func handleSignOut() {
        do {
            try Auth.auth().signOut()
            myUid = nil
            username = ""
            roomCode = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Firestore
    /// Reserva o username em `/usernames/{username}` garantindo exclusividade.
    private func reserveUsernameTransaction(username: String, uid: String) async throws {
        let ref = db.collection("usernames").document(username)

        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                do {
                    let snap = try transaction.getDocument(ref)
                    if snap.exists {
                        errorPointer?.pointee = NSError(
                            domain: "App",
                            code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Username já em uso"]
                        )
                        return nil
                    }
                    transaction.setData(["uid": uid], forDocument: ref)
                    return true
                } catch let e as NSError {
                    errorPointer?.pointee = e
                    return nil
                }
            }, completion: { _, error in
                if let error {
                    cont.resume(throwing: error)
                } else {
                    cont.resume(returning: ())
                }
            })
        }
    }

    // MARK: - Helpers
    private var sanitizedUsername: String {
        username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private var sanitizedRoomCode: String {
        roomCode.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var displayName: String {
        sanitizedUsername.isEmpty ? "(sem nome)" : sanitizedUsername
    }
}
