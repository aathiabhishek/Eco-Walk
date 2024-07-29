//
//  ProfileUpdateView.swift
//  Aathi_Abhishek_Parking
//
//  Created by Aathi Abhishek T on 2024-07-09.
//
import SwiftUI

struct ProfileUpdateView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var contactNumber: String = ""
    @State private var paymentNumber: String = ""
    @State private var photo: String = ""
    @Binding var rootScreen: RootView
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var fireDBHelper: FireDBHelper
    
    var body: some View {
        VStack {
            Text("Profile View")
            Spacer()
            if let url = URL(string: photo), !photo.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 150, height: 150)
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
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
            
            Form {
                TextField("Enter name", text: $name)
                TextField("Enter email", text: $email)
                TextField("Enter phone number", text: $contactNumber)
                TextField("Enter car payment number", text: $paymentNumber)
                TextField("Enter the URL", text: $photo)
            }
            
            Button(action: {
                self.updateProfile()
            }) {
                Text("Update Profile")
            }
            
            Spacer()
        }
        .onAppear {
            fireDBHelper.getUserProfile()
            
            // Ensure profile is set after fetching
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let profile = self.fireDBHelper.userProfile {
                    self.name = profile.name
                    self.email = profile.email
                    self.contactNumber = profile.contactNumber
                    self.paymentNumber = profile.paymentNumber
                    self.photo = profile.photo
                } else {
                    print("User profile is not available")
                }
            }
        }
        .navigationTitle(Text("Update Profile"))
    }
    
    private func updateProfile() {
        guard !name.isEmpty, !email.isEmpty, !contactNumber.isEmpty, !paymentNumber.isEmpty else {
            print("Error: Please fill in all fields")
            return
        }
        
        guard let userProfile = fireDBHelper.userProfile else {
            print("Error: User profile not available")
            return
        }

        var profileToUpdate = userProfile
        profileToUpdate.name = self.name
        profileToUpdate.email = self.email
        profileToUpdate.contactNumber = self.contactNumber
        profileToUpdate.paymentNumber = self.paymentNumber
        profileToUpdate.photo = self.photo
        
        fireDBHelper.updateUserProfile(profileToUpdate: profileToUpdate)
        dismiss()
    }
}

struct ProfileUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileUpdateView(rootScreen: .constant(.Login))
            .environmentObject(FireDBHelper.getInstance())
    }
}
