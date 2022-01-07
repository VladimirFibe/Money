//
//  AddTransactionForm.swift
//  Money
//
//  Created by Vladimir Fibe on 05.01.2022.
//

import SwiftUI
import CoreData
import UIKit
struct AddTransactionForm: View {
  let card: Card
  init(card: Card) {
    self.card = card
    let context = PersistenceController.shared.container.viewContext
    let request = TransactionCategory.fetchRequest()
    request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
    do {
      let result = try context.fetch(request)
      if let first = result.first {
        _selectedCategories = .init(initialValue: [first])
      }
    } catch {
      print("DEBUG: Failed to preselected categories: \(error.localizedDescription)")
    }
  }
  @Environment(\.dismiss) var dismiss
  @State private var name = ""
  @State private var amount = ""
  @State private var date = Date()
  @State private var photoData: Data?
  @State private var shouldPresentPhotoPicker = false
  @State private var selectedCategories = Set<TransactionCategory>()
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Information")) {
          TextField("Name", text: $name)
          TextField("Amount", text: $amount)
          DatePicker("Date", selection: $date, displayedComponents: .date)
        }
        Section(header: Text("Categories")) {
          NavigationLink(destination: CategoriesList(selectedCategories: $selectedCategories)) {
            Text("Select categories")
          }
          let sortedByTimestampCategories = Array(selectedCategories).sorted(by: {$0.timestamp?.compare($1.timestamp ?? Date()) == .orderedDescending})
          ForEach(sortedByTimestampCategories) { category in
            CategoryRow(category: category)
          }
        }
        Section(header: Text("Photo/Receipt")) {
          Button {
            shouldPresentPhotoPicker.toggle()
          } label: {
            Text("Select Photo")
          }
          .fullScreenCover(isPresented: $shouldPresentPhotoPicker) {
            PhotoPickerView(photoData: $photoData)
          }
          
          if let data = photoData, let image = UIImage.init(data: data) {
            Image(uiImage: image)
              .resizable()
              .scaledToFill()
          }
        }
      }
      .navigationTitle("Add Transaction")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) { cancelButton }
        ToolbarItem(placement: .navigationBarTrailing) { saveButton }
      }
    }
    
  }
  private var saveButton: some View {
    Button {
      let context = PersistenceController.shared.container.viewContext
      let transaction = CardTransaction(context: context)
      transaction.name = name
      transaction.amount = Float(amount) ?? 0
      transaction.timestamp = date
      transaction.photoData = photoData
      transaction.card = card
      transaction.categories = self.selectedCategories as NSSet
      do {
        try context.save()
        dismiss()
      } catch {
        print("DEBUG: Failed to save transaction \(error.localizedDescription)")
      }
    } label: {
      Text("Save")
    }
  }
  private var cancelButton: some View {
    Button {
      
      dismiss()
    } label: {
      Text("Cancel")
    }
    
  }
  struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var photoData: Data?
    func makeCoordinator() -> Coordinator {
      Coordinator(parent: self)
    }
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
      private let parent: PhotoPickerView
      init(parent: PhotoPickerView) {
        self.parent = parent
      }
      func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
      }
      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        let resizedImage = image?.resized(to: .init(width: 500, height: 500))
        let imageData = resizedImage?.jpegData(compressionQuality: 0.5)
        self.parent.photoData = imageData
        picker.dismiss(animated: true)
      }
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
      
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = context.coordinator
      return imagePicker
    }
  }
}

struct AddTransactionForm_Previews: PreviewProvider {
  static let card: Card? = {
    let context = PersistenceController.shared.container.viewContext
    let request = Card.fetchRequest()
    request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
    return try? context.fetch(request).first
  }()
  static var previews: some View {
    if let card = card {
      AddTransactionForm(card: card)
    }
  }
}

extension UIImage {
  func resized(to newSize: CGSize) -> UIImage {
    return UIGraphicsImageRenderer(size: newSize).image { _ in
      let hScale = newSize.height / size.height
      let vScale = newSize.width / size.width
      let scale = max(hScale, vScale)
      let resizeSize = CGSize(width: size.width * scale,
                              height: size.height * scale)
      var middle = CGPoint.zero
      if resizeSize.width > newSize.width {
        middle.x -= (resizeSize.width - newSize.width) / 2.0
      }
      if resizeSize.height > newSize.height {
        middle.y -= (resizeSize.height - newSize.height) / 2.0
      }
      draw(in: CGRect(origin: middle, size: resizeSize))
    }
  }
}
