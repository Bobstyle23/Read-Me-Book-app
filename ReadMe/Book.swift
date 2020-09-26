//
//  Book.swift
//  ReadMe
//
//  Created by MukhammadBobur Pakhriyev on 2020/09/18.
//  Copyright © 2020 MukhammadBobur Pakhriyev. All rights reserved.
//

import UIKit

struct Book: Hashable {
    let title: String
    let author: String
    var review: String?
    var readMe: Bool
    
    var image: UIImage?
    
    static let mockBook = Book(title: "", author: "", readMe: true)
        
}

extension Book: Codable {
    enum CodingKeys: String, CodingKey {
        case title
        case author
        case review
        case readMe
    }
}
