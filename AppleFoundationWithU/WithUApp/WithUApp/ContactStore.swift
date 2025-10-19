//
//  ContactStore.swift
//  Map_iOS
//
//  Created by san-12 on 19/10/25.
//

import Foundation
import SwiftUI
internal import Combine

struct Contatto: Identifiable, Equatable, Codable {
    var id: UUID = .init()
    let nome: String
    let telefono: String
    
}

@MainActor
class ContactStore: ObservableObject {
    @Published var contatti: [Contatto] = []
    let nMaxContact: Int?
    
    //definisco il numero massimo di contatti
    init(maxContact: Int? = 4) {
        self.nMaxContact = maxContact
    }
    
    //variabile per verificare se UserDefault è piena
    var isFull: Bool {
        if let max = nMaxContact {
            return contatti.count >= max
        }
        else
            {return false}
    }
    
    //aggiuingi contatto
    func addContact(c contatto: Contatto) {
        guard !isFull else {return}
        contatti.append(contatto)
    }
    
    //rimuovi contatto
    func removeContact(at offsets: IndexSet) {
        contatti.remove(atOffsets: offsets)
    }
}
