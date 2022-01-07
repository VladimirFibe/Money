//
//  MainView.swift
//  Money
//
//  Created by Vladimir Fibe on 04.01.2022.
//

import SwiftUI
import CoreData

struct MainView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @State private var shouldPresentAddCardForm = false
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
    animation: .default)
  private var cards: FetchedResults<Card>
  
  @State private var selection = -1
  var body: some View {
    NavigationView {
      ScrollView {
        if cards.isEmpty {
          emptyPromptMessage
        } else {
          tabView
          if let firstIndex = cards.firstIndex(where: { $0.hash == selection }) {
            let card = self.cards[firstIndex]
            TransactionList(card: card)
          }
        }
        Spacer()
          .fullScreenCover(isPresented: $shouldPresentAddCardForm, onDismiss: nil) {
            AddCardForm(card: nil) { selection = $0.hash }
          }
      }
      .navigationTitle("Credit Cards")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) { addButton }
        ToolbarItem(placement: .navigationBarLeading) { tempButtons }
      }
      .accentColor(Color(.label))
    }
  }
  var emptyPromptMessage: some View {
    VStack {
      Text("You currently have no cards in the system.")
        .padding(48)
        .multilineTextAlignment(.center)
      Button {
        shouldPresentAddCardForm.toggle()
      } label: {
        Text("+ Add Your Fist Card")
          .foregroundColor(Color(.systemBackground))
      }
      .buttonStyle(.borderedProminent)
    }
  }
  var tabView: some View {
    TabView(selection: $selection) {
      ForEach(cards) { card in
        CreditCardView(card: card)
          .padding(.bottom, 50)
          .tag(card.hash)
      }
    }
    .frame(height: 280)
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    .indexViewStyle(.page(backgroundDisplayMode: .always))
    .onAppear {
      selection = cards.first?.hash ?? -1
    }
  }
  var addButton: some View {
    Button {
      selection = cards.last?.hash ?? -1
      shouldPresentAddCardForm.toggle()
    } label: {
      Text("+ Card")
        .foregroundColor(Color(.systemBackground))
    }
    .buttonStyle(.borderedProminent)
  }
  var tempButtons: some View {
    HStack {
      Button {
        withAnimation {
          let newCard = Card(context: viewContext)
          newCard.name = "Card"
          newCard.timestamp = Date()
          do {
            try viewContext.save()
          } catch {
            print(error.localizedDescription)
          }
        }
      } label: {
        Text("Add Item")
      }
      Button {
        cards.forEach { viewContext.delete($0) }
        do {
          try viewContext.save()
        } catch {
          print(error.localizedDescription)
        }
      } label: {
        Text("Delete")
      }
    }
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      MainView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
      MainView()
        .preferredColorScheme(.dark)
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
  }
}
