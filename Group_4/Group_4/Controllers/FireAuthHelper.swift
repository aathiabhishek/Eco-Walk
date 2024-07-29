//
//  FireAuthHelper.swift
//  Group_4
//
//  Created by Aathi Abhishek T on 2024-06-20.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

class FireAuthHelper: ObservableObject {
    
    @Published var user: User? {
        didSet {
            objectWillChange.send()
        }
    }
    
    private static var shared: FireAuthHelper?
    private let db = Firestore.firestore()
    
    static func getInstance() -> FireAuthHelper {
        if (shared == nil) {
            shared = FireAuthHelper()
        }
        return shared!
    }
    
    func listenToAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else {
                return
            }
            self.user = user
        }
    }
    
    func signUp(name: String, email: String, password: String, contactNumber: String, photo: String, paymentNumber: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let result = authResult else {
                print(#function, "Error creating an account: \(error?.localizedDescription ?? "No error description")")
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            print(#function, "Successfully created an account: \(result.user.uid)")
            
            self.user = result.user
            UserDefaults.standard.set(self.user?.email, forKey: "KEY_EMAIL")
            self.saveUserProfile(name: name, email: email, contactNumber: contactNumber, paymentNumber: paymentNumber, photo: photo) { success, error in
                DispatchQueue.main.async {
                    completion(success, error)
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard let result = authResult else {
                print(#function, "Error signing in: \(error?.localizedDescription ?? "No error description")")
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            print(#function, "Successfully signed in: \(result.user.uid)")
            
            self.user = result.user
            UserDefaults.standard.set(self.user?.email, forKey: "KEY_EMAIL")
            DispatchQueue.main.async {
                completion(true, nil)
            }
        }
    }
    
    func signOut(completion: @escaping (Bool, Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                completion(true, nil)
            }
        } catch let signOutError as NSError {
            DispatchQueue.main.async {
                completion(false, signOutError)
            }
        }
    }
    
    private func saveUserProfile(name: String, email: String, contactNumber: String, paymentNumber: String, photo: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let user = user else {
            DispatchQueue.main.async {
                completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"]))
            }
            return
        }
        
        let userProfile = [
            "name": name,
            "email": email,
            "contactNumber": contactNumber,
            "paymentNumber": paymentNumber,
            "photo": photo
        ]
        
        db.collection("users").document(user.uid).setData(userProfile) { error in
            if let error = error {
                print("Error saving user profile: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, error)
                }
            } else {
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            }
        }
    }
}
