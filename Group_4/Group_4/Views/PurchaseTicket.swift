//
//  Purchase.swift
//  Group_4
//
//  Created by Aathi Abhishek T on 2024-07-08.
//
//
import SwiftUI

struct PurchaseTicket: View {
    @ObservedObject var fireDBHelper = FireDBHelper.getInstance()
    @Binding var showPurchases: Bool // Binding to toggle back to HomeView

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(fireDBHelper.purchaseWalks) { walk in
                        NavigationLink(destination: DetailView(walk: walk)) {
                            purchaseWalkRow(walk: walk)
                        }
                    }
                }
                .listStyle(.plain)

                Button(action: {
                    showPurchases = false // Toggle back to HomeView
                }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding()
            }
            .navigationBarTitle("Purchase Walks")
            .onAppear {
                fireDBHelper.buyTickets()
            }
        }
    }

    private func purchaseWalkRow(walk: Walk) -> some View {
        VStack(alignment: .leading) {
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

                    // Display number of tickets and total price
                    Text("Number of Tickets: \(walk.numberOfTickets!)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Total Price: $\(walk.price * Double(walk.numberOfTickets ?? 0), specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct PurchaseTicket_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseTicket(showPurchases: .constant(true))
            .environmentObject(FireDBHelper.getInstance())
    }
}
