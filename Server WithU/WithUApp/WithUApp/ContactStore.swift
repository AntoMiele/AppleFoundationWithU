//
//  ContactStore.swift
//  Map_iOS
//
//  Created by san-12 on 19/10/25.
//

import Foundation
import SwiftUI
internal import Combine
import Contacts

final class ContactPermissionManager {
    static let shared = ContactPermissionManager()
    private let store = CNContactStore()

    func requestAccess(completion: @escaping (Bool) -> Void) {
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}


struct Contatto: Identifiable, Equatable, Codable {
    var id: UUID = .init()
    let nome: String
    let telefono: String
}

@MainActor
class ContactStore: ObservableObject {
    @Published var contatti: [Contatto] = [] {
        didSet { salva() }
    }
    let nMaxContact: Int?
    private let key = "contacts"

    init(maxContact: Int? = 4) {
        self.nMaxContact = maxContact
        self.contatti = carica()
    }

    var isFull: Bool {
        if let max = nMaxContact { return contatti.count >= max }
        return false
    }

    func addContact(c contatto: Contatto) {
        guard !isFull else { return }
        contatti.append(contatto)
    }

    func removeContact(at offsets: IndexSet) {
        contatti.remove(atOffsets: offsets)
    }

    //Funzioni per il salvataggio dei contatti
    private func salva() {
        let data = try? JSONEncoder().encode(contatti)
        UserDefaults.standard.set(data, forKey: key)
    }

    private func carica() -> [Contatto] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Contatto].self, from: data)) ?? []
    }
}
