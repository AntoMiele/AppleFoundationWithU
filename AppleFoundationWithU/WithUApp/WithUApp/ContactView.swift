

import SwiftUI

struct ContactsView: View {
    @StateObject var store = ContactStore(maxContact: 4)
    @State var showingAdd = false
    @State var goToMap = false
    @State var showAlert = false
    
    var body: some View {
       
            
            NavigationStack {
                
                ZStack {
                    Color.cobaltblue.ignoresSafeArea()
                
                Group {
                    
                    //Visualizza messaggio nessun contatto
                    if store.contatti.isEmpty {
                        
                        ContentUnavailableView(
                            "Nessun contatto",
                            systemImage: "person.crop.circle.badge.exclam",
                            description: Text("Aggiungi un contatto per continuare")
                        )
                    } else {
                        
                        //Visualizzazione lista contatti
                        List {
                            ForEach(store.contatti) { c in
                                HStack(spacing: 12) {
                                    Image(systemName: "person.crop.circle").font(.title2)
                                        .foregroundStyle(Color(.white))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(c.nome)
                                            .font(.headline)
                                        Text(c.telefono).font(.subheadline).foregroundStyle(.secondary)
                                    }.foregroundStyle(.white)
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
                .navigationTitle("Contatti")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination: MapView(), isActive: $goToMap)
                        {
                            Button("Start")
                            {
                                if !store.contatti.isEmpty {
                                    goToMap = true
                                }
                                else
                                {goToMap = false}
                            }
                        }
                    }
                
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingAdd = true
                        } label: {
                            Label("+ADD", systemImage: "plus.circle.fill")
                            
                        }
                        .disabled(store.isFull)
                        .opacity(store.isFull ? 0.5 : 1)
                        .help(store.isFull ? "Limite di contatti raggiunto" : "Aggiungi un contatto")
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
                        Text("Hai raggiunto il limite massimo di contatti")
                    }
                    .font(.footnote)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(.yellow.opacity(0.2))
                }
                
            }
        }
        
    }
}

#Preview {
    ContactsView()
}






