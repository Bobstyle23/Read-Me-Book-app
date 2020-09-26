//
//  ViewController.swift
//  ReadMe
//
//  Created by MukhammadBobur Pakhriyev on 2020/09/18.
//  Copyright © 2020 MukhammadBobur Pakhriyev. All rights reserved.
//




import UIKit

// MARK:- Reusable SFSymbol Images
enum LibrarySymbol {
  case bookmark
  case bookmarkFill
  case book
  case letterSquare(letter: Character?)
  
  var image: UIImage {
    let imageName: String
    switch self {
    case .bookmark, .book:
      imageName = "\(self)"
    case .bookmarkFill:
      imageName = "bookmark.fill"
    case .letterSquare(let letter):
      guard let letter = letter?.lowercased(),
      let image = UIImage(systemName: "\(letter).square")
        else {
          imageName = "square"
          break
      }
      return image
    }
    return UIImage(systemName: imageName)!
  }
}

// MARK:- Library
enum Library {
  private static let starterData = [
    Book(title: "The Subtle art of not giving a F*ck", author: "Mark Manson", readMe: true),
    Book(title: "1984", author: "George Orwell", readMe: true),
    Book(title: "Animal Farm", author: "George Orwell", readMe: false),
    Book(title: "Slight Edge", author: "Jeff Olson", readMe:  false),
    Book(title: "The Da Vinci Code", author: "Dan Brown", readMe: true),
    Book(title: "The Dip", author: "Seth Godin", readMe: false),
    Book(title: "The Life and Complete Work of Francisco Goya", author: "P. Gassier & J Wilson", readMe: true),
    Book(title: "Lady Cottington's Pressed Fairy Book", author: "Lady Cottington", readMe: false),
    Book(title: "How to Draw Cats", author: "Janet Rancan", readMe: true),
    Book(title: "Drawing People", author: "Barbara Bradley", readMe: false),
    Book(title: "What to Say When You Talk to Yourself", author: "Shad Helmstetter", readMe: true)
  ]
  
  static var books: [Book] = loadBooks()
  
  private static let booksJSONURL = URL(fileURLWithPath: "Books",
                                relativeTo: FileManager.documentDirectoryURL).appendingPathExtension("json")
  
  
  /// This method loads all existing data from the `booksJSONURL`, if available. If not, it will fall back to using `starterData`
  /// - Returns: Returns an array of books, loaded from a JSON file
  private static func loadBooks() -> [Book] {
      let decoder = JSONDecoder()

      guard let booksData = try? Data(contentsOf: booksJSONURL) else {
        return starterData
      }

      do {
        let books = try decoder.decode([Book].self, from: booksData)
        return books.map { libraryBook in
          Book(
            title: libraryBook.title,
            author: libraryBook.author,
            review: libraryBook.review,
            readMe: libraryBook.readMe,
            image: loadImage(forBook: libraryBook)
          )
        }
        
      } catch let error {
        print(error)
        return starterData
      }
  }
  
  private static func saveAllBooks() {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    do {
      let booksData = try encoder.encode(books)
      try booksData.write(to: booksJSONURL, options: .atomicWrite)
    } catch let error {
      print(error)
    }
  }
  
  /// Adds a new book to the `books` array and saves it to disk.
  /// - Parameters:
  ///   - book: The book to be added to the library.
  ///   - image: An optional image to associate with the book.
  static func addNew(book: Book) {
    if let image = book.image { saveImage(image, forBook: book) }
    books.insert(book, at: 0)
    saveAllBooks()
  }
  
  
  /// Updates the stored value for a single book.
  /// - Parameter book: The book to be updated.
  static func update(book: Book) {
    if let newImage = book.image {
      saveImage(newImage, forBook: book)
    }
    
    guard let bookIndex = books.firstIndex(where: { storedBook in
      book.title == storedBook.title } )
    else {
        print("No book to update")
        return
    }
    
    books[bookIndex] = book
    saveAllBooks()
  }
  
  /// Removes a book from the `books` array.
  /// - Parameter book: The book to be deleted from the library.
  static func delete(book: Book) {
    guard let bookIndex = books.firstIndex(where: { storedBook in
      book == storedBook } )
      else { return }
  
    books.remove(at: bookIndex)
    
    let imageURL = FileManager.documentDirectoryURL.appendingPathComponent(book.title)
    do {
      try FileManager().removeItem(at: imageURL)
    } catch let error { print(error) }
    
    saveAllBooks()
  }
  
  static func reorderBooks(bookToMove: Book, bookAtDestination: Book) {
    let destinationIndex = Library.books.firstIndex(of: bookAtDestination) ?? 0
    books.removeAll(where: { $0.title == bookToMove.title })
    books.insert(bookToMove, at: destinationIndex)
    saveAllBooks()
  }
  
 
  /// - Parameters:
  ///   - image: The image to be saved.
  ///   - title: The title of the book associated with the image.
  static func saveImage(_ image: UIImage, forBook book: Book) {
    let imageURL = FileManager.documentDirectoryURL.appendingPathComponent(book.title)
    if let jpgData = image.jpegData(compressionQuality: 0.7) {
      try? jpgData.write(to: imageURL, options: .atomicWrite)
    }
  }
  
 
  /// - Parameter title: Title of the book you need an image for.
  /// - Returns: The image associated with the given book title.
  static func loadImage(forBook book: Book) -> UIImage? {
    let imageURL = FileManager.documentDirectoryURL.appendingPathComponent(book.title)
    return UIImage(contentsOfFile: imageURL.path)
  }
}

extension FileManager {
  static var documentDirectoryURL: URL {
    return `default`.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
}
