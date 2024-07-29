//
//  FireDBHelper.swift
//  Group_4
//
//  Created by Aathi Abhishek T on 2024-06-20.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class FireDBHelper: ObservableObject {
    @Published var walkList = [Walk]()
    @Published var favoriteWalks = [Walk]()
    @Published var purchaseWalks = [Walk]()
    @Published var userProfile: UserProfile?
    private let COLLECTION_USER = "users"
    private let db: Firestore
    private let COLLECTION_NAME = "Nature_Walk_Data"
    private static var shared: FireDBHelper?

    init(db: Firestore) {
        self.db = db
    }

    static func getInstance() -> FireDBHelper {
        if shared == nil {
            shared = FireDBHelper(db: Firestore.firestore())
        }
        return shared!
    }
    var isUserLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    func insertWalk(newWalk: Walk) {
        do {
            try self.db.collection(COLLECTION_NAME).addDocument(from: newWalk)
        } catch let error {
            print(#function, "Unable to insert the document to Firestore: \(error)")
        }
    }

    func getAllWalks() {
        db.collection(COLLECTION_NAME).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error getting walks: \(error.localizedDescription)")
                return
            }

            guard let snapshot = querySnapshot else {
                print("No walks available")
                return
            }

            self.walkList = snapshot.documents.compactMap { document in
                try? document.data(as: Walk.self)
            }

            print("Walks fetched successfully: \(self.walkList)")
        }
    }

    func getFavorites() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).collection("favorites").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting favorites: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No favorites available")
                return
            }

            self.favoriteWalks = documents.compactMap { document in
                try? document.data(as: Walk.self)
            }
        }
    }

    func addFavorite(_ walk: Walk) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        do {
            try db.collection("users").document(userId).collection("favorites").document(walk.id!).setData(from: walk)
        } catch let error {
            print("Error adding favorite to Firestore: \(error)")
        }
    }

    func removeFavorite(_ walk: Walk) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).collection("favorites").document(walk.id!).delete { error in
            if let error = error {
                print("Error removing favorite: \(error)")
            }
        }
    }

    func isFavorite(_ walk: Walk) -> Bool {
        return favoriteWalks.contains(where: { $0.id == walk.id })
    }
    func buyTickets() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).collection("purchaseTicket").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting favorites: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No purchase Ticket available")
                return
            }

            self.purchaseWalks = documents.compactMap { document in
                try? document.data(as: Walk.self)
            }
        }
    }

    func addPurchase(walk: Walk, numberOfTickets: Int) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        do {
            var walkToPurchase = walk
            walkToPurchase.numberOfTickets = numberOfTickets
            try db.collection("users").document(userId).collection("purchaseTicket").document(walk.id!).setData(from: walkToPurchase)
        } catch let error {
            print("Error adding purchase to Firestore: \(error)")
        }
    }

    
    
    func removePurchase(_ walk: Walk) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).collection("purchaseTicket").document(walk.id!).delete { error in
            if let error = error {
                print("Error removing favorite: \(error)")
            }
        }
    }

    func getUserProfile() {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            db.collection(COLLECTION_USER).document(userId).getDocument { (document, error) in
                if let document = document, document.exists {
                    do {
                        self.userProfile = try document.data(as: UserProfile.self)
                    } catch let error {
                        print("Error decoding user profile: \(error)")
                    }
                } else {
                    print("User profile does not exist")
                }
            }
        }
        
        func updateUserProfile(profileToUpdate: UserProfile) {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("Error: Invalid user ID")
                return
            }
            
            do {
                try db.collection(COLLECTION_USER).document(userId).setData(from: profileToUpdate) { error in
                    if let error = error {
                        print("Error updating user profile: \(error)")
                    } else {
                        print("User profile successfully updated")
                    }
                }
            } catch let error {
                print("Error updating user profile: \(error)")
            }
        }
}

