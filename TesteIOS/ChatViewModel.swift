//
//  ChatViewModel.swift
//  TesteIOS
//

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
    private let key: SymmetricKey

    init(roomCode: String, myUid: String) {
        self.roomId = ChatViewModel.sanitize(roomCode)
        self.myUid = myUid
        self.key = E2EE.deriveKey(fromRoomCode: roomCode)
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
                Task { await self.decryptAll() }
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
}
