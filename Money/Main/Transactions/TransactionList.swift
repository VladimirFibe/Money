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
  @State private var shouldShowFilterSheet = false
  @State private var selectedCategories = Set<TransactionCategory>()
  var fetchRequest: FetchRequest<CardTransaction>
  var filteredTransaction: [CardTransaction] {
    if selectedCategories.isEmpty {
      return Array(fetchRequest.wrappedValue)
    } else {
      return fetchRequest.wrappedValue.filter { transaction in
        var shouldKeep = false
        if let categories = transaction.categories as? Set<TransactionCategory> {
          categories.forEach { if selectedCategories.contains($0) { shouldKeep = true}}
        }
        return shouldKeep
      }
    }
  }
  var body: some View {
    VStack {
      if fetchRequest.wrappedValue.isEmpty {
        Text("Get started by adding your first transaction")
        addTransaction
      } else {
        HStack {
          Spacer()
          addTransaction
          filterButton
        }
        .padding(.trailing)
        ForEach(filteredTransaction) { transaction in
          TransactionView(transaction: transaction)
        }
        .foregroundColor(.black)
      }
    }
    .font(.headline)
    .foregroundColor(Color(.systemBackground))
    .fullScreenCover(isPresented: $shouldShowAddTransactionForm) {
      AddTransactionForm(card: card)
    }
    .sheet(isPresented: $shouldShowFilterSheet) {
      FilterSheet(selectedCategories: $selectedCategories)
    }
  }
  private var filterButton: some View {
    Button {
      shouldShowFilterSheet.toggle()
    } label: {
      Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
    }
    .buttonStyle(.borderedProminent)
  }
  private var addTransaction: some View {
    Button {
      shouldShowAddTransactionForm.toggle()
    } label: {
      Text("+ Transaction")
    }
    .buttonStyle(.borderedProminent)
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
