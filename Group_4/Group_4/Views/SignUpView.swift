//
//  SignUpView.swift
//  Group_4
//
//  Created by Aathi Abhishek T on 2024-06-20.
//

import SwiftUI

struct SignUpView: View {
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var contactNumber: String = ""
    @State private var paymentNumber: String = ""
    @State private var photo: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var rootScreen: RootView
    
    @EnvironmentObject var fireAuthHelper: FireAuthHelper
    
    var body: some View {
        NavigationView {
            ZStack{
                Image("BG2")  // Background image
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .ignoresSafeArea()
                    .opacity(0.88)
                VStack {
                    Group {
                        HStack {
                            Image(systemName: "person.circle")
                                .font(.system(size: 35))
                                .frame(width: 50, height: 50)
                                .foregroundColor(.brown)
                                .padding(.leading, 5)
                            TextField("Enter Name", text: $name)
                                .textFieldStyle(PlainTextFieldStyle())
                                .disableAutocorrection(true)
                                .autocapitalization(.words)
                                .padding(.horizontal)
                        }
                        .background(Color.TF.opacity(0.70))
                        .cornerRadius(10)
                        .padding(5)
                        
                        HStack {
                            Image(systemName: "mail")
                                .font(.system(size: 35))
                                .frame(width: 50, height: 50)
                                .foregroundColor(.brown)
                                .padding(.leading, 5)
                            TextField("Enter Email", text: $email)
                                .textFieldStyle(PlainTextFieldStyle())
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .padding(.horizontal)
                        }
                        .background(Color.TF.opacity(0.70))
                        .cornerRadius(10)
                        .padding(5)
                        
                        HStack {
                            Image(systemName: "lock")
                                .font(.system(size: 30))
                                .frame(width: 50, height: 50)
                                .foregroundColor(.brown)
                                .padding(.leading, 5)
                            SecureField("Enter Password", text: $password)
                                .textFieldStyle(PlainTextFieldStyle())
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .padding(.horizontal)
                        }
                        .background(Color.TF.opacity(0.70))
                        .cornerRadius(10)
                        .padding(5)
                        
                        HStack {
                            Image(systemName: "lock")
                                .font(.system(size: 30))
                                .frame(width: 50, height: 50)
                                .foregroundColor(.brown)
                                .padding(.leading, 5)
                            SecureField("Enter Password again", text: $confirmPassword)
                                .textFieldStyle(PlainTextFieldStyle())
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .padding(.horizontal)
                        }
                        .background(Color.TF.opacity(0.70))
                        .cornerRadius(10)
                        .padding(5)
                        
                        HStack {
                            Image(systemName: "phone")
                                .font(.system(size: 30))
                                .frame(width: 50, height: 50)
                                .foregroundColor(.brown)
                                .padding(.leading, 5)
                            TextField("Contact Number", text: $contactNumber)
                                .keyboardType(.phonePad)
                                .textFieldStyle(PlainTextFieldStyle())
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .padding(.horizontal)
                        }
                        .background(Color.TF.opacity(0.70))
                        .cornerRadius(10)
                        .padding(5)
                        HStack {
                            Image(systemName: "person.circle")
                                .font(.system(size: 35))
                                .frame(width: 50, height: 50)
                                .foregroundColor(.brown)
                                .padding(.leading, 5)
                            TextField("Enter photo URL", text: $photo)
                                .textFieldStyle(PlainTextFieldStyle())
                                .disableAutocorrection(true)
                                .autocapitalization(.words)
                                .padding(.horizontal)
                        }
                        .background(Color.TF.opacity(0.70))
                        .cornerRadius(10)
                        .padding(5)
                        HStack {
                            Image(systemName: "creditcard")
                                .font(.system(size: 30))
                                .frame(width: 50, height: 50)
                                .foregroundColor(.brown)
                                .padding(.leading, 5)
                            TextField("Payment Number", text: $paymentNumber)
                                .textFieldStyle(PlainTextFieldStyle())
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                                .padding(.horizontal)
                        }
                        .background(Color.TF.opacity(0.70))
                        .cornerRadius(10)
                        .padding(5)
                    }
                    Button(action: {
                        if self.validateInputs() {
                            self.fireAuthHelper.signUp(name: self.name, email: self.email, password: self.password, contactNumber: self.contactNumber, photo: self.photo, paymentNumber: self.paymentNumber) { success, error in
                                if success {
                                    self.rootScreen = .Login
                                } else {
                                    self.alertMessage = error?.localizedDescription ?? "Sign up failed"
                                    self.showAlert = true
                                }
                            }
                        } else {
                            self.showAlert = true
                        }
                    }) {
                        Label("Create Account", systemImage: "person.badge.plus")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                    .disabled(self.email.isEmpty || self.password.isEmpty || self.confirmPassword.isEmpty || self.name.isEmpty || self.contactNumber.isEmpty || self.paymentNumber.isEmpty)
                    
                    Spacer()
                }
                .navigationTitle("Sign Up")
            }
        }
    }
    
    private func validateInputs() -> Bool {
        if self.name.isEmpty {
            self.alertMessage = "Name cannot be empty."
            return false
        }
        
        if self.email.isEmpty {
            self.alertMessage = "Email cannot be empty."
            return false
        }
        
        if self.password.isEmpty {
            self.alertMessage = "Password cannot be empty."
            return false
        }
        
        if self.password != self.confirmPassword {
            self.alertMessage = "Passwords do not match."
            return false
        }
        
        if self.password.count < 6 {
            self.alertMessage = "Password must be at least 6 characters long."
            return false
        }
        
        if self.contactNumber.isEmpty {
            self.alertMessage = "Contact number cannot be empty."
            return false
        }
        
        if self.paymentNumber.isEmpty {
            self.alertMessage = "Car plate number cannot be empty."
            return false
        }
        
        return true
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(rootScreen: .constant(.Login))
            .environmentObject(FireAuthHelper.getInstance())
    }
}
