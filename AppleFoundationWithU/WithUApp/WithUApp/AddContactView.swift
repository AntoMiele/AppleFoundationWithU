//
//  AddContactView.swift
//  Map_iOS
//
//  Created by san-12 on 19/10/25.
//

import SwiftUI

struct AddContactView: View {
    
    
    //@Environment chiude lo sheet e torna alla vista precedente
    @Environment(\.dismiss) private var dismiss
    let onSave: (Contatto) -> Void
    
    @State var nome: String = ""
    @State var telefono: String = ""
    @FocusState var focusField: Field?
    
    enum Field {
        case nome
        case telefono
    }
    
    var telefonoSoloCifre: String {
        telefono.filter(\.isNumber)
    }
    
    //verifica che telefono e nome sono validi
    //il telefono con [6, 20]
    //il nome se non va a capo
    private var isValidTel: Bool {
        let digits = telefonoSoloCifre
        return (6...20).contains(digits.count)
    }
    
    
    private var isValidName: Bool {
        !nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isFormValid: Bool {
        isValidName && isValidTel
    }
    
    var body: some View {
        NavigationStack {
            Form{
                Section("Dati contatto")
                {   //testo del nome
                    TextField("Nome", text: $nome)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .submitLabel(.next)
                        .focused($focusField, equals: .nome)
                        .onSubmit {
                            focusField = .telefono
                        }
                    //testo del telefono
                    TextField("Cell", text: $telefono)
                        .keyboardType(.numberPad)
                        .focused($focusField, equals: .telefono)
                        .onChange(of: telefonoSoloCifre, initial: false) {_, new in
                            let filtrato = new.filter(\.isNumber)
                            if filtrato != new {
                                telefono = filtrato
                            }
                            
                            
                        }
                    //parametri di come deve essere il telefono
                    if !telefono.isEmpty && !isValidTel {
                        Text("Registrare un numero tra 6 e 20 cifre.").font(.footnote)
                            .foregroundStyle(Color(.red))
                    }
                }
            }
            .navigationTitle(Text("Nuovo contatto"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        let c = Contatto(nome: nome.trimmingCharacters(in: .whitespacesAndNewlines),
                            telefono: telefonoSoloCifre)
                        onSave(c)
                        dismiss()
                    }
                    .disabled(!isFormValid)
                    
                }
                
                ToolbarItemGroup(placement: .keyboard){
                    Spacer()
                    Button("Fine"){
                        
                        //---- DEVE RIMANDARE ALLA PROSSIMA SCHERMATA, QUELLA DELLA MAPPA----
                        focusField = nil}
                }
                
            }.onAppear {focusField = .nome}
        }
        .presentationDetents([.medium, .large])
    }
}
