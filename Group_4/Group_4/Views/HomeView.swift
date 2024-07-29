//
//  HomeView.swift
//  Group_4
//
//  Created by Aathi Abhishek T on 2024-06-20.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct HomeView: View {
    @ObservedObject var fireDBHelper = FireDBHelper.getInstance()
    @Binding var rootScreen: RootView
    @State private var showProfileUpdateView: Bool = false
    @State private var showFavorites: Bool = false
    @State private var searchText: String = ""
    @State private var showPurchase: Bool = false
    @EnvironmentObject var fireAuthHelper: FireAuthHelper
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchField
                walkList
            }
            .navigationBarTitle("Nature Walk Sessions")
            .toolbar {
                toolbarContent
            }
        }
        .sheet(isPresented: self.$showProfileUpdateView) {
            ProfileUpdateView(rootScreen: self.$rootScreen)
                .environmentObject(self.fireDBHelper)
        }
        .sheet(isPresented: self.$showFavorites) {
            FavoriteView(showFavorites: self.$showFavorites)
                .environmentObject(self.fireDBHelper)
        }
        .sheet(isPresented: self.$showPurchase) {
            PurchaseTicket(showPurchases: self.$showPurchase)
                .environmentObject(self.fireDBHelper)
        }
        .onAppear {
            fireDBHelper.getAllWalks()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search by name or location", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    private var walkList: some View {
        List(filteredWalks) { walk in
            NavigationLink(destination: DetailView(walk: walk)) {
                walkRow(walk: walk)
            }
        }
        .listStyle(.plain)
    }
    
    private func walkRow(walk: Walk) -> some View {
        HStack {
            if let photoURL = walk.photos.first, let url = URL(string: photoURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 150, height: 150)
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: 150, height: 150)
                            .clipShape(Rectangle())
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .clipShape(Rectangle())
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .clipShape(Rectangle())
            }
            VStack(alignment: .leading, spacing: 10) {
                Text(walk.name)
                    .font(.headline)
                Text("$\(walk.price, specifier: "%.2f") per person")
                    .font(.subheadline)
                HStack(spacing: 3) { // Horizontal stack for star ratings
                    ForEach(0..<5) { index in
                        Image(systemName: starType(for: index, rating: walk.starRating)) // Star icon
                            .foregroundColor(.yellow)
                    }
                }
                Text(walk.location)
                    .font(.headline)

              
            }
            .padding()
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button(action: { self.showProfileUpdateView = true }) {
                    Label("Profile", systemImage: "person")
                }
                Button(action: { showFavorites.toggle() }) {
                    Label("Favorites", systemImage: "heart")
                }
                Button(action: { showPurchase.toggle() }) {
                    Label("Purchase", systemImage: "ticket")
                }
                Button(action: { signOut() }) {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }

            } label: {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.green)
            }
        }
    }
    private func starType(for index: Int, rating: Double) -> String {
        let value = Double(index) + 1.0
        if rating >= value {
            return "star.fill" // Full star for ratings greater than or equal to current index + 1
        } else if rating >= Double(index) + 0.5 {
            return "star.lefthalf.fill" // Half-filled star for ratings between current index + 0.5 and current index + 1
        } else {
            return "star" // Empty star for all other cases
        }
    }

    private var filteredWalks: [Walk] {
        if searchText.isEmpty {
            return fireDBHelper.walkList
        } else {
            return fireDBHelper.walkList.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.location.lowercased().contains(searchText.lowercased())
            }
        }
    }

    private func signOut() {
        fireAuthHelper.signOut { success, error in
                if success {
                    print("Sign-out successful.")
                    self.rootScreen = .Login // Navigate to Login screen upon sign-out
                } else {
                if let error = error {
                    // Handle sign-out error
                    self.alertMessage = "Sign-out error: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let fireDBHelper = FireDBHelper(db: Firestore.firestore())
        return HomeView(rootScreen: .constant(.Login))
            .environmentObject(fireDBHelper)
            .environmentObject(FireAuthHelper.getInstance())
    }
}
