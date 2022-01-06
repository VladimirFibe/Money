//
//  TransactionView.swift
//  Money
//
//  Created by Vladimir Fibe on 05.01.2022.
//

import SwiftUI

struct TransactionView: View {
  let transaction: CardTransaction
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
  }()
  @State private var shouldPresentActionSheet = false
  var body: some View {
    VStack(alignment: .leading, spacing: 20.0) {
      header
      photo
    }
    .padding()
    .background(Color.white)
    .shadow(radius: 5)
    .padding(.horizontal)
  }
  private var photo: some View {
    VStack {
      if let photoData = transaction.photoData,
          let uiImage = UIImage(data: photoData) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
      }
    }
  }
  private var header: some View {
    HStack(alignment: .bottom) {
      VStack(alignment: .leading, spacing: 4.0) {
        Text(transaction.cardname).font(.headline)
        if let date = transaction.timestamp {
          Text(dateFormatter.string(from: date))
        }
      }
      Spacer()
      VStack(alignment: .trailing, spacing: 4.0) {
        ellipsisButton
        Text(transaction.cardamount)
      }
    }
  }
  private var ellipsisButton: some View {
    Button {
      shouldPresentActionSheet.toggle()
    } label: {
      Image(systemName: "ellipsis").font(.headline)
    }
    .actionSheet(isPresented: $shouldPresentActionSheet) {
      .init(title: Text(transaction.cardname), buttons: [
        .destructive(Text("Delete"), action: handleDelete),
        .cancel()
      ])
    }
  }
  private func handleDelete() {
    let viewContext = PersistenceController.shared.container.viewContext
    viewContext.delete(transaction)
    do {
      try viewContext.save()
    } catch {
      print("DEBUG: \(error.localizedDescription)")
    }
  }
}

struct TransactionView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
      .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
  }
}
