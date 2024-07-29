//
//  Group_4App.swift
//  Group_4
//
//  Created by Aathi Abhishek T on 2024-06-20.
//

import SwiftUI
import Firebase
import FirebaseFirestore

@main
struct Group_4App: App {
    // Initialize FireDBHelper as an environment object
    @StateObject var fireDBHelper = FireDBHelper.getInstance()

    init() {
        FirebaseApp.configure()
        // You can initialize Firestore inside FireDBHelper.getInstance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(fireDBHelper)
        }
    }
}
