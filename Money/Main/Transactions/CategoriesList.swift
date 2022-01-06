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
            HStack(spacing: 12.0) {
              if let data = category.colorData,
                 let uiColor = UIColor.color(data: data) {
                let color = Color(uiColor)
                Spacer()
                  .frame(width: 30, height: 10)
                  .background(color)
              }
              Text(category.name ?? "")
              Spacer()
            }
          }
          .onDelete { indexSet in
            indexSet.forEach { index in
              viewContext.delete(categories[index])
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

struct CategoriesList_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      CategoriesList()
    }
    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
  }
}
