//
//  AddCardForm.swift
//  Money
//
//  Created by Vladimir Fibe on 04.01.2022.
//

import SwiftUI

struct AddCardForm: View {
  let card: Card?
  let didAddCard: ((Card) -> ())?
  init(card: Card? = nil, didAddCard: ((Card) -> ())? = nil) {
    self.card = card
    self.didAddCard = didAddCard
    if let card = card {
      _name = State(initialValue: card.cardname)
      _cardNumber = State(initialValue: card.cardnumber)
      _selection = State(initialValue: card.cardtype)
      _limit = State(initialValue: String(card.limit))
      _month = State(initialValue: card.cardmonth)
      _year = State(initialValue: card.cardyear)
      _color = State(initialValue: card.cardcolor)
    }
  }
  @Environment(\.dismiss) var dismiss
  @State private var name = ""
  @State private var cardNumber = ""
  @State private var limit = ""
  @State private var selection = "Visa"
  @State private var month = 1
  @State private var year = Calendar.current.component(.year, from: Date())
  @State private var color = Color.blue
  let currentYear = Calendar.current.component(.year, from: Date())
  var title: String {
    card == nil ? "Add Credit Card" : name
  }
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("CARD INFOMATION")) {
          TextField("Name", text: $name)
          TextField("Credit Card Number", text: $cardNumber)
            .keyboardType(.numberPad)
          TextField("Credit Limit", text: $limit)
            .keyboardType(.numberPad)
          Picker("Type", selection: $selection) {
            ForEach(["Visa", "Mastercard", "Discover", "Citybank"], id: \.self) { item in
              Text(item).tag(item)
            }
          }
        }
        Section(header: Text("EXPIRATION")) {
          Picker("Month", selection: $month) {
            ForEach(1...12, id: \.self) { item in
              Text("\(item)").tag(item)
            }
          }
          Picker("Year", selection: $year) {
            ForEach(currentYear...currentYear + 20, id: \.self) { item in
              Text("\(item)").tag(item)
            }
          }
        }
        Section(header: Text("COLOR")) {
          ColorPicker("Color", selection: $color)
        }
      }
      .navigationTitle(title)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) { cancelButton }
        ToolbarItem(placement: .navigationBarTrailing) { saveButton }
      }
      .accentColor(Color(.label))
    }
  }
  var cancelButton: some View {
    Button {
      dismiss()
    } label: {
      Text("Cancel")
    }
  }
  var saveButton: some View {
    Button {
      let viewContext = PersistenceController.shared.container.viewContext
      let card = card == nil ? Card(context: viewContext) : card!
      card.name = name
      card.number = cardNumber
      card.type = selection
      card.limit = Int32(limit) ?? 0
      card.month = Int16(month)
      card.year = Int16(year)
      card.timestamp = Date()
      card.color = UIColor(color).encode()
      do {
        try viewContext.save()
        dismiss()
        didAddCard?(card)
      } catch {
        print("DEBUG: Failed to persist new card: \(error.localizedDescription)")
      }
    } label: {
      Text("Save")
        .foregroundColor(Color(.systemBackground))
    }
    .buttonStyle(.borderedProminent)
  }
}

struct AddCardForm_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
      .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
  }
}

extension UIColor {
  class func color(data: Data) -> UIColor? {
    return try? NSKeyedUnarchiver
      .unarchiveTopLevelObjectWithData(data) as? UIColor
  }
  
  func encode() -> Data? {
    return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
  }
}
