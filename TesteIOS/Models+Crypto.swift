//
//  Models+Crypto.swift
//  TesteIOS
//
//  Created by Gabriel Ferrari on 08/10/25.
//

import Foundation
import FirebaseFirestore
import CryptoKit

// MARK: - Modelo de mensagem (Firestore)
struct ChatMessage: Identifiable {
    let id: String
    let senderId: String
    let cipherB64: String
    let createdAt: Date

    init?(doc: QueryDocumentSnapshot) {
        let data = doc.data()
        guard let sender = data["senderId"] as? String,
              let cipher = data["cipher"] as? String else { return nil }

        self.id = doc.documentID
        self.senderId = sender
        self.cipherB64 = cipher

        if let ts = data["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = Date()
        }
    }
}

// MARK: - Criptografia (simples p/ demo)
enum E2EE {
    /// Gera uma chave simétrica a partir do "código da sala".
    static func deriveKey(fromRoomCode code: String) -> SymmetricKey {
        // salt fixo só para demo (em produção use um salt aleatório por sala)
        let salt = "roomchat-v1".data(using: .utf8)!
        var hasher = SHA256()
        hasher.update(data: salt)
        hasher.update(data: code.data(using: .utf8)!)
        let digest = hasher.finalize()
        return SymmetricKey(data: Data(digest))
    }

    /// Criptografa um texto e retorna base64 do `combined` (nonce+cipher+tag).
    static func encrypt(_ plaintext: String, using key: SymmetricKey) throws -> String {
        let plain = Data(plaintext.utf8)
        let sealed = try ChaChaPoly.seal(plain, using: key) // nonce randômico
        return sealed.combined.base64EncodedString()
    }

    /// Decriptografa a partir do base64 do `combined`.
    static func decrypt(_ combinedB64: String, using key: SymmetricKey) throws -> String {
        guard let data = Data(base64Encoded: combinedB64) else {
            throw NSError(domain: "E2EE", code: -1, userInfo: [NSLocalizedDescriptionKey: "base64 inválido"])
        }
        let box = try ChaChaPoly.SealedBox(combined: data)
        let clear = try ChaChaPoly.open(box, using: key)
        return String(decoding: clear, as: UTF8.self)
    }
}


