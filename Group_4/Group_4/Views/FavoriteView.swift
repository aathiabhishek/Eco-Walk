//
//  FavoriteView.swift
//  Group_4
//
//  Created by Zohaib Babar Ali on 2024-06-28.
//

import SwiftUI

struct FavoriteView: View {
    @ObservedObject var fireDBHelper = FireDBHelper.getInstance()
    @Binding var showFavorites: Bool // Binding to toggle back to HomeView
    
    var body: some View {
        NavigationView {
            VStack {
                List(fireDBHelper.favoriteWalks) { walk in
                    NavigationLink(destination: DetailView(walk: walk)) {
                        favoriteWalkRow(walk: walk)
                    }
                }
                .listStyle(.plain)
            }
            .navigationBarTitle("Favorite Walks")
            .navigationBarItems(trailing: Button(action: {
                showFavorites = false // Toggle back to HomeView
            }) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.blue)
            })
        }
        .onAppear {
            fireDBHelper.getFavorites()
        }
    }
    
    private func favoriteWalkRow(walk: Walk) -> some View {
        HStack {
            if let photoURL = walk.photos.first, let url = URL(string: photoURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 50, height: 50)
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: 120, height: 120)
                            .clipShape(Rectangle())
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 120, height: 120)
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
            VStack(alignment: .leading) {
                Text(walk.name)
                    .font(.headline)
                Text("$\(walk.price, specifier: "%.2f") per person")
                    .font(.subheadline)
                Text("Rating: \(walk.starRating, specifier: "%.1f")")
                    .font(.subheadline)
            }
        }
    }
}

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteView(showFavorites: .constant(true))
            .environmentObject(FireDBHelper.getInstance())
    }
}
