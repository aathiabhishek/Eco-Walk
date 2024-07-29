//
//  Walk.swift
//  Group_4
//
//  Created by Aathi Abhishek T on 2024-06-20.
//

import Foundation
import FirebaseFirestoreSwift
struct Walk : Identifiable,Hashable, Codable{
    
    // id prop will be used as a document id for the firestorde document
    //firestore document id must be used as a string type
    
    @DocumentID var id: String? = UUID().uuidString
    let name: String
    let description: String
    let starRating: Double
    let guide: String
    let photos: [String]
    let price: Double
    let dateTime: String
    let address: String
    let contactNumber: String
    let latitude: Double?
    let longitude: Double?
    let location: String
    var numberOfTickets: Int?
    
    init(name: String, description: String, starRating: Double, guide: String, photos: [String], price: Double, dateTime: String, address: String, contactNumber: String, latitude: Double?, longitude: Double?, location: String, numberOfTickets: Int?) {
       
        self.name = name
        self.description = description
        self.starRating = starRating
        self.guide = guide
        self.photos = photos
        self.price = price
        self.dateTime = dateTime
        self.address = address
        self.contactNumber = contactNumber
        self.latitude = latitude
        self.longitude = longitude
        self.location = location
        self.numberOfTickets = numberOfTickets
    }
}

