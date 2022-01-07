//
//  FilterSheet.swift
//  Money
//
//  Created by Vladimir Fibe on 06.01.2022.
//

import SwiftUI

struct FilterSheet: View {
  @Binding var selectedCategories: Set<TransactionCategory>
  @Environment(\.dismiss) var dismiss
  @Environment(\.managedObjectContext) private var viewContext
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.timestamp, ascending: false)],
    animation: .default)
  private var categories: FetchedResults<TransactionCategory>
  var body: some View {
    NavigationView {
      Form {
        ForEach(categories) { category in
          Button(action: {
            if selectedCategories.contains(category) {
              selectedCategories.remove(category)
            } else {
              selectedCategories.insert(category)
            }
          }) {
            HStack {
              CategoryRow(category: category)
              if selectedCategories.contains(category) {
                Image(systemName: "checkmark")
              }
            }
          }
        }
      }
      .navigationTitle("Select filters")
      
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) { cancel }
        ToolbarItem(placement: .navigationBarTrailing) { save }
      }
    }
  }
  private var cancel: some View {
    Button {
      selectedCategories.removeAll()
      dismiss()
    } label: {
      Text("Cancel")
    }
  }
  private var save: some View {
    Button {
      dismiss()
    } label: {
      Text("Save")
    }
    .buttonStyle(.borderedProminent)
  }
}

struct FilterSheet_Previews: PreviewProvider {
  static var previews: some View {
    FilterSheet(selectedCategories: .constant(.init()))
      .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
  }
}
