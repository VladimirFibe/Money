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
  struct CreditCardView: View {
    let card: Card
    @State private var shouldShowActionSheet = false
    @State private var shouldShowEditForm = false
    @State private var refreshID = UUID()
    var cardname: String {
      card.name ?? ""
    }
    private func handleDelete() {
      let viewContext = PersistenceController.shared.container.viewContext
      viewContext.delete(card)
      do {
        try viewContext.save()
      } catch {
        print("DEBUG: \(error.localizedDescription)")
      }
    }
    var body: some View {
      VStack(alignment: .leading, spacing: 16.0) {
        HStack {
          Text(cardname)
            .font(.system(size: 24, weight: .semibold))
          Spacer()
          Button {
            shouldShowActionSheet.toggle()
          } label: {
            Image(systemName: "ellipsis")
              .font(.system(size: 24, weight: .bold))
          }
          .actionSheet(isPresented: $shouldShowActionSheet) {
            .init(title: Text(cardname), message: Text("Options"), buttons: [
              .default(Text("Edit"), action: {
                shouldShowEditForm.toggle()
              }),
              .destructive(Text("Delete Card"), action: handleDelete),
              .cancel()])
          }
          
        }
        HStack {
          Image(card.cardtype.lowercased())
            .resizable()
            .scaledToFit()
            .frame(height: 44)
          Spacer()
          Text("Balance: $\(50000)")
            .font(.system(size: 18, weight: .semibold))
        }
        Text(card.cardnumber)
        Text("Credit Limit: $\(card.limit)")
      }
      .foregroundColor(.white)
      .padding()
      .background(
        VStack {
          if let colorData = card.color,
             let uiColor = UIColor.color(data: colorData),
             let actualColor = Color(uiColor: uiColor) {
            LinearGradient(colors: [actualColor.opacity(0.6), actualColor], startPoint: .center, endPoint: .bottom)
          } else {
            Color.purple
          }
        }
      )
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(.black.opacity(0.5), lineWidth: 1)
      )
      .cornerRadius(8)
      .shadow(radius: 5)
      .padding(.horizontal)
      .padding(.top, 8)
      .fullScreenCover(isPresented: $shouldShowEditForm) {
        AddCardForm(card: card)
      }
    }
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
    MainView()
      .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
  }
}
