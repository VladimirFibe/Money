//
//  CategoriesList.swift
//  Money
//
//  Created by Vladimir Fibe on 06.01.2022.
//

import SwiftUI

struct CategoriesList: View {
  @State private var name = ""
  @State private var color = Color.red
  @Binding var selectedCategories: Set<TransactionCategory>
  @Environment(\.managedObjectContext) private var viewContext
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.timestamp, ascending: false)],
    animation: .default)
  private var categories: FetchedResults<TransactionCategory>
  var body: some View {
    Form {
      if !categories.isEmpty {
        Section(header: Text("Select a category")) {
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
          .onDelete { indexSet in
            indexSet.forEach { index in
              let category = categories[index]
              viewContext.delete(category)
              selectedCategories.remove(category)
            }
            try? viewContext.save()
          }
        }
      }
      Section(header: Text("Create a category")) {
        TextField("Name", text: $name)
        ColorPicker("Color", selection: $color)
        Button(action: handleCreate) {
          Text("Create")
        }
        .buttonStyle(.borderedProminent)
        .frame(maxWidth: .infinity)
        
      }
    }
    .navigationTitle("Categories")
  }
  private func handleCreate() {
    let context = PersistenceController.shared.container.viewContext
    let category = TransactionCategory(context: context)
    category.name = name
    category.colorData = UIColor(color).encode()
    category.timestamp = Date()
    try? context.save()
    name = ""
  }
}
struct CategoryRow: View {
  var category: TransactionCategory
  var body: some View {
    HStack(spacing: 12.0) {
      if let data = category.colorData,
         let uiColor = UIColor.color(data: data) {
        let color = Color(uiColor)
        Spacer()
          .frame(width: 30, height: 10)
          .background(color)
      }
      Text(category.name ?? "")
        .foregroundColor(Color(.label))
      Spacer()
    }
  }
}
struct CategoriesList_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      CategoriesList(selectedCategories: .constant(.init()))
    }
    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
  }
}
