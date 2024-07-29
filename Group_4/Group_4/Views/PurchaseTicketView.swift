import SwiftUI

struct PurchaseTicketView: View {
    var walk: Walk
    @Binding var isPresented: Bool
    @State private var numberOfTickets: Int = 1
    @EnvironmentObject var fireDBHelper: FireDBHelper
    
    private var totalPrice: Double {
        return Double(numberOfTickets) * walk.price
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Purchase Tickets for \(walk.name)")
                    .font(.headline)
                    .padding()
                
                Stepper(value: $numberOfTickets, in: 1...10) {
                    Text("Number of Tickets: \(numberOfTickets)")
                }
                .padding()
                
                HStack {
                    Text("Total Price: $\(totalPrice, specifier: "%.2f")")
                        .font(.headline)
                        .padding()
                    
                    Spacer()
                }
                
                Button(action: {
                    fireDBHelper.addPurchase(walk: walk, numberOfTickets: numberOfTickets)
                    isPresented.toggle()
                }) {
                    Text("Confirm Purchase")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
            .navigationBarItems(trailing: Button(action: {
                isPresented.toggle()
            }) {
                Text("Cancel")
                    .foregroundColor(.blue)
            })
        }
    }
}

struct PurchaseTicketView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseTicketView(walk: Walk(name: "Nature Walk",
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
                                      numberOfTickets: 0),
                           isPresented: .constant(true))
            .environmentObject(FireDBHelper.getInstance())
    }
}

