//
//  UserProfile.swift
//  Group_4
//
//  Created by Aathi Abhishek T on 2024-07-10.
//

import Foundation
import FirebaseFirestoreSwift

struct UserProfile: Identifiable, Hashable, Codable {
    @DocumentID var id: String?
   var photo: String
    var name: String
    var email: String
    var contactNumber: String
    var paymentNumber: String
    
    init(name: String, email: String, contactNumber: String, paymentNumber: String, photo: String) {
        self.name = name
        self.photo = photo
        self.email = email
        self.contactNumber = contactNumber
        self.paymentNumber = paymentNumber
    }
}
