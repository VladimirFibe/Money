//
//  TransactionList.swift
//  Money
//
//  Created by Vladimir Fibe on 05.01.2022.
//

import SwiftUI

struct TransactionList: View {
  let card: Card
  init(card: Card) {
    self.card = card
    fetchRequest = FetchRequest<CardTransaction>(
      entity: CardTransaction.entity(),
      sortDescriptors: [.init(key: "timestamp", ascending: false)],
      predicate: .init(format: "card == %@", self.card))
  }
  @Environment(\.managedObjectContext) private var viewContext
  @State private var shouldShowAddTransactionForm = false
  var fetchRequest: FetchRequest<CardTransaction>
  
  var body: some View {
    VStack {
      Text("Get started bu adding your first transaction")
      
      addTransaction
      
      ForEach(fetchRequest.wrappedValue) { transaction in
        TransactionView(transaction: transaction)
      }
    }
  }
  var addTransaction: some View {
    Button {
      shouldShowAddTransactionForm.toggle()
    } label: {
      Text("+ Transaction")
        .font(.headline)
        .foregroundColor(Color(.systemBackground))
    }
    .buttonStyle(.borderedProminent)
    .fullScreenCover(isPresented: $shouldShowAddTransactionForm) {
      AddTransactionForm(card: card)
    }
  }
}

struct TransactionList_Previews: PreviewProvider {
  static let card: Card? = {
    let context = PersistenceController.shared.container.viewContext
    let request = Card.fetchRequest()
    request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
    return try? context.fetch(request).first
  }()
  static var previews: some View {
    let context = PersistenceController.shared.container.viewContext
    ScrollView {
      if let card = card {
        TransactionList(card: card)
      }
    }
    .environment(\.managedObjectContext, context)
  }
}
