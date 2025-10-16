//
//  ChatView.swift
//  TesteIOS
//

import SwiftUI

struct ChatView: View {
    @StateObject private var vm: ChatViewModel

    init(roomCode: String, myUid: String, myUsername: String) {       // 🆕
        _vm = StateObject(wrappedValue: ChatViewModel(
            roomCode: roomCode, myUid: myUid, myUsername: myUsername  // 🆕
        ))
    }

    var body: some View {
        VStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.status).font(.footnote).foregroundStyle(.secondary)
                Text("Sala: \(vm.roomId) • Meu UID: \(vm.myUid.prefix(8))…")
                    .font(.caption2).foregroundStyle(.secondary)
            }
            .padding(.top, 8)

            List(vm.messages) { msg in
                let isMe = (msg.senderId == vm.myUid)
                let name = isMe ? "Você (\(vm.myUsername))" : (vm.usernames[msg.senderId] ?? "Contato") // 🆕
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.caption).foregroundStyle(.secondary)
                    Text(vm.decrypted[msg.id] ?? "…")
                }
                .frame(maxWidth: .infinity,
                       alignment: isMe ? .trailing : .leading)
            }

            HStack {
                TextField("Mensagem…", text: $vm.input)
                    .textFieldStyle(.roundedBorder)
                Button("Enviar") { Task { await vm.send() } }
                    .disabled(vm.input.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .navigationTitle("Conversa segura")
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .task { await vm.start() }
        .onDisappear { vm.stop() }
    }
}
