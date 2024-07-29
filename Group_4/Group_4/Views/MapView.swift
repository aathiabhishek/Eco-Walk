import SwiftUI
import MapKit

struct MapView: View {
    let address: String
    let latitude: Double
    let longitude: Double
    
    @State private var region = MKCoordinateRegion()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: [Landmark(name: "Nature Reserve", latitude: latitude, longitude: longitude)]) { landmark in
                MapPin(coordinate: CLLocationCoordinate2D(latitude: landmark.latitude, longitude: landmark.longitude), tint: .green)
            }
            .onAppear {
                setRegion()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Go Back")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationBarTitle("Map View")
    }
    
    private func setRegion() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            }
        }
    }
}


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(address: "123 Nature Street, City, Country", latitude: 37.7749, longitude: -122.4194)
    }
}
