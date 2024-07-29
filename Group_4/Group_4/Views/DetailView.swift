//
//  DetailView.swift
//  Group_4
//
//  Created by Aathi Abhishek T on 2024-06-24.
//


import SwiftUI

struct DetailView: View {
    var walk: Walk
    
    @State private var isFavorite = false
    @State private var isPurchased = false
    @State private var showMapView = false // State to control navigation to MapView
    @State private var showPurchaseView = false
    
    @EnvironmentObject var fireDBHelper: FireDBHelper
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image slider
                imageSlider
                
                // Walk details
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        favoriteButton
                        purchaseButton
                        Spacer()
                        Text("Rating:")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.gray) // Secondary color
                        HStack(spacing: 3) { // Horizontal stack for star ratings
                            ForEach(0..<5) { index in
                                Image(systemName: starType(for: index, rating: walk.starRating)) // Star icon
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    HStack {
                        Text("Name:")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.gray) // Secondary color
                        Text(walk.name)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                    }
                    
                    HStack {
                        Text("Guide:")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.gray) // Secondary color
                        Text(walk.guide)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("Price:")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.gray) // Secondary color
                        Text("$\(walk.price, specifier: "%.2f") per person")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    HStack {
                        Text("Address:")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.gray) // Secondary color
                        Text(walk.address)
                            .font(.subheadline)
                            .foregroundColor(.blue) // Primary color
                            .padding(.horizontal)
                            .onTapGesture {
                                showMapView.toggle() // Toggle to show MapView
                            }
                    }
                    
                    HStack {
                        Text("Date & Time:")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.gray) // Secondary color
                        Text(walk.dateTime)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    Text("Description:")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.gray) // Secondary color
                    Text(walk.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                }
                .padding(.horizontal)
                
                // Buttons
                HStack(spacing: 16) {
                    Spacer()
                    phoneButton(contactNumber: walk.contactNumber)
                    shareButton
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .navigationBarTitle(walk.name)
        .sheet(isPresented: $showMapView) {
            if let latitude = walk.latitude, let longitude = walk.longitude {
                MapView(address: walk.address, latitude: latitude, longitude: longitude)
            } else {
                Text("Location coordinates not available")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .sheet(isPresented: $showPurchaseView) {
            PurchaseTicketView(walk: walk, isPresented: $showPurchaseView)
        }
        .onAppear {
            isFavorite = fireDBHelper.isFavorite(walk)
            isPurchased = fireDBHelper.purchaseWalks.contains(where: { $0.id == walk.id })
        }
    }
    
    private var imageSlider: some View {
        TabView {
            ForEach(walk.photos, id: \.self) { photo in
                AsyncImage(url: URL(string: photo)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxHeight: 300)
                            .clipped()
                            .cornerRadius(10)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(10)
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.horizontal)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 300)
        .padding(.horizontal)
    }
    
    private var favoriteButton: some View {
        Button(action: {
            if isFavorite {
                fireDBHelper.removeFavorite(walk)
            } else {
                fireDBHelper.addFavorite(walk)
            }
            isFavorite.toggle()
        }) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title)
                .foregroundColor(isFavorite ? .red : .gray)
        }
    }
    
    private var shareButton: some View {
        Button(action: {
            share()
        }) {
            Image(systemName: "square.and.arrow.up")
                .font(.title)
                .foregroundColor(.gray)
        }
    }
    
    private var purchaseButton: some View {
        Button(action: {
            if fireDBHelper.isUserLoggedIn {
                showPurchaseView.toggle()
            } else {
                print(#function, "Error while purchasing")
            }
        }) {
            Image(systemName: isPurchased ? "ticket.fill" : "ticket")
                .font(.title)
                .foregroundColor(isPurchased ? .blue : .gray)
                .padding(12)
        }
    }
    
    private func share() {
        let mapLink = "https://maps.apple.com/?address=\(walk.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        let textToShare = "Check out this walk: \(walk.name) at \(walk.address) - [Open in Maps](\(mapLink))"
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    private func dialPhoneNumber(_ phoneNumber: String?) {
        guard let phoneNumber = phoneNumber,
              let phoneURL = URL(string: "tel://\(phoneNumber.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)"),
              UIApplication.shared.canOpenURL(phoneURL) else {
            print("Failed to open phone URL")
            return
        }
        
        UIApplication.shared.open(phoneURL) { success in
            if success {
                print("Successfully opened phone URL: \(phoneURL)")
            } else {
                print("Failed to open phone URL: \(phoneURL)")
            }
        }
    }
    
    private func phoneButton(contactNumber: String) -> some View {
        Button(action: {
            dialPhoneNumber(contactNumber)
        }) {
            Image(systemName: "phone")
                .font(.title)
                .foregroundColor(.gray)
                .padding(12)
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
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(walk: Walk(name: "Nature Walk",
                              description: "Enjoy a peaceful walk in the nature reserve.",
                              starRating: 4.5,
                              guide: "John Doe",
                              photos: ["https://example.com/photo1.jpg", "https://example.com/photo2.jpg", "https://example.com/photo3.jpg"],
                              price: 29.99,
                              dateTime: "2024-07-01 10:00 AM",
                              address: "123 Nature Street",
                              contactNumber: "1234567890",
                              latitude: 37.7749,
                              longitude: -122.4194,
                              location: "Toronto",
                              numberOfTickets: 0))
        .environmentObject(FireDBHelper.getInstance())
    }
}

