//
//  ChatView.swift
//  TesteIOS
//

import SwiftUI

struct ChatView: View {
    // isso é uma struct que me retorna uma view, necessariamente tenho que ter um var body dentro dele
    @StateObject private var vm: ChatViewModel

    init(roomCode: String, myUid: String) {
        _vm = StateObject(wrappedValue: ChatViewModel(roomCode: roomCode, myUid: myUid))
    }

    var body: some View {
        VStack(spacing: 8) {
            // Status e info
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.status).font(.footnote).foregroundStyle(.secondary)
                Text("Sala: \(vm.roomId) • Meu UID: \(vm.myUid.prefix(8))…")
                    .font(.caption2).foregroundStyle(.secondary)
            }
            .padding(.top, 8)

            // Mensagens
            List(vm.messages) { msg in
                VStack(alignment: .leading, spacing: 2) {
                    Text(msg.senderId == vm.myUid ? "Você" : "Contato")
                        .font(.caption).foregroundStyle(.secondary)
                    Text(vm.decrypted[msg.id] ?? "…")
                }
                .frame(maxWidth: .infinity,
                       alignment: msg.senderId == vm.myUid ? .trailing : .leading)
            }

            // Composer
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
