//
//  CreditCardView.swift
//  Money
//
//  Created by Vladimir Fibe on 07.01.2022.
//

import SwiftUI

struct CreditCardView: View {
  let card: Card
  init(card: Card) {
    self.card = card
    fetchRequest = FetchRequest<CardTransaction>(
      entity: CardTransaction.entity(),
      sortDescriptors: [.init(key: "timestamp", ascending: false)],
      predicate: .init(format: "card == %@", self.card))
    
  }
  @Environment(\.managedObjectContext) private var viewContext
  var fetchRequest: FetchRequest<CardTransaction>
  @State private var shouldShowActionSheet = false
  @State private var shouldShowEditForm = false
  @State private var refreshID = UUID()
  var balance: Float {
    fetchRequest.wrappedValue.reduce(0) { $0 + $1.amount}
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
        Text(card.cardname)
          .font(.system(size: 24, weight: .semibold))
        Spacer()
        Button {
          shouldShowActionSheet.toggle()
        } label: {
          Image(systemName: "ellipsis")
            .font(.system(size: 24, weight: .bold))
        }
        .actionSheet(isPresented: $shouldShowActionSheet) {
          .init(title: Text(card.cardname), message: Text("Options"), buttons: [
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
        Text(String(format: "Balance: $%0.2f", balance))
          .font(.system(size: 18, weight: .semibold))
      }
      Text(card.cardnumber)
      HStack {
        Text(String(format: "Credit Limit: $%0.0f", Float(card.limit) - balance))
        Spacer()
        VStack(alignment: .trailing) {
          Text("Valid Thru")
          Text(String(format: "%02d/", card.month)) +
          Text(String(card.year % 2000))
        }
      }
    }
    .foregroundColor(.white)
    .padding()
    .background(RoundedRectangle(cornerRadius: 8).fill(
      LinearGradient(colors: [card.cardcolor.opacity(0.6), card.cardcolor],
                     startPoint: .center, endPoint: .bottom)
    ))
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

struct CreditCardView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
      .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
  }
}
