//
//  ContactSettingsView.swift
//  Map_iOS
//
//  Created by san-12 on 22/10/25.
//



import SwiftUI

struct ContactSettingsView: View {
    @StateObject var store = ContactStore(maxContact: 4)
    @State var showingAdd = false
    
    @State var showAlert = false
    
    
    var body: some View {
       
            
            NavigationStack {
                
                ZStack {
                    Color.cobaltblue.ignoresSafeArea()
                
                Group {
                    
                    //Visualizza messaggio nessun contatto
                    if store.contatti.isEmpty {
                        
                        ContentUnavailableView(
                            "No Contacts",
                            systemImage: "person.crop.circle.badge.exclam",
                            description: Text("Add a contact to get started.")
                        )
                    } else {
                        
                        //Visualizzazione lista contatti
                        List {
                            ForEach(store.contatti) { c in
                                HStack(spacing: 12) {
                                    Image(systemName: "person.crop.circle").font(.title2)
                                        .foregroundStyle(Color(.black))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(c.nome)
                                            .font(.headline)
                                        Text(c.telefono).font(.subheadline).foregroundStyle(.secondary)
                                    }.foregroundStyle(.black)
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: store.removeContact)
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                        .background(Color.cobaltblue)
                    }
                }
                .navigationTitle("Contacts")
                .toolbar {
                    
                
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingAdd = true
                        } label: {
                            Label("+ADD", systemImage: "plus.circle.fill")
                            
                        }
                        .disabled(store.isFull)
                        .opacity(store.isFull ? 0.5 : 1)
                        .help(store.isFull ? "No one can be added" : "Add a new contact")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddContactView { nuovo in
                    store.addContact(c: nuovo)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if store.isFull {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Limit of contacts reached")
                    }
                    .font(.footnote)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(.yellow.opacity(0.2))
                }
                
            }
        }
        
    }
    private var isElement: Bool {
        return store.contatti.count > 0
    }
}

#Preview {
    ContactSettingsView()
}
