import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import CryptoKit

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var decrypted: [String: String] = [:]
    @Published var input: String = ""
    @Published var status: String = "Conectando…"

    let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    let roomId: String
    let myUid: String
    let myUsername: String                              // 🆕
    private let key: SymmetricKey

    // cache uid -> username
    @Published var usernames: [String: String] = [:]    // 🆕

    init(roomCode: String, myUid: String, myUsername: String) { // 🆕
        self.roomId = ChatViewModel.sanitize(roomCode)
        self.myUid = myUid
        self.myUsername = myUsername
        self.key = E2EE.deriveKey(fromRoomCode: roomCode)
        self.usernames[myUid] = myUsername              // 🆕 já sabemos o nosso
    }

    static func sanitize(_ s: String) -> String {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-")
        return String(trimmed.unicodeScalars.filter { allowed.contains($0) })
    }

    func start() async {
        status = "Conectado. Escutando mensagens…"
        listener = db.collection("rooms").document(roomId)
            .collection("messages")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err { self.status = "Erro: \(err.localizedDescription)"; return }
                let docs = snap?.documents ?? []
                self.messages = docs.compactMap { ChatMessage(doc: $0) }
                Task {
                    await self.decryptAll()
                    await self.resolveUsernamesForMessages()          // 🆕 busca nomes que faltam
                }
            }
    }

    func stop() {
        listener?.remove(); listener = nil
    }

    func send() async {
        guard !input.isEmpty else { return }
        do {
            let cipherB64 = try E2EE.encrypt(input, using: key)
            let data: [String: Any] = [
                "senderId": myUid,
                "cipher": cipherB64,
                "createdAt": FieldValue.serverTimestamp()
            ]
            try await db.collection("rooms").document(roomId)
                .collection("messages")
                .addDocument(data: data)
            input = ""
        } catch {
            status = "Falha ao enviar: \(error.localizedDescription)"
        }
    }

    private func decryptAll() async {
        var out: [String: String] = [:]
        for m in messages {
            if let text = try? E2EE.decrypt(m.cipherB64, using: key) {
                out[m.id] = text
            } else {
                out[m.id] = "⚠️ não foi possível decriptar"
            }
        }
        decrypted = out
    }

    // 🆕 carrega nomes de usuários para os senderIds que ainda não conhecemos
    private func resolveUsernamesForMessages() async {
        let unknown = Set(messages.map { $0.senderId })
            .subtracting(Set(usernames.keys))
        guard !unknown.isEmpty else { return }

        await withTaskGroup(of: (String, String?).self) { group in
            for uid in unknown {
                group.addTask { [uid] in
                    do {
                        let snap = try await self.db.collection("users").document(uid).getDocument()
                        let name = snap.get("username") as? String
                        return (uid, name)
                    } catch {
                        return (uid, nil)
                    }
                }
            }
            var newMap = usernames
            for await (uid, name) in group {
                if let name { newMap[uid] = name }
            }
            usernames = newMap
        }
    }
}
