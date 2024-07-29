//
//  SignInView.swift
//  Group_4
//
//  Created by Aathi Abhishek T on 2024-06-20.
//
import SwiftUI

struct SignInView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    @State private var showSignUp: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @Binding var rootScreen: RootView
    
    @EnvironmentObject var fireAuthHelper: FireAuthHelper // data shared in multiple views
    
    var body: some View {
        
        ZStack {
            Image("BG2")  // Background image
                .scaledToFit()
                .frame(width: 100, height: 100)
                .ignoresSafeArea()
                .opacity(0.88)
            VStack {
                HStack {
                    Image(systemName: "leaf.arrow.circlepath")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.BG)
                    
                    Text("ECO-PATH")
                        .font(.title)
                        .foregroundColor(.BG)
                        .bold()
                }
                .padding(5)
              //  .background(Color.white.opacity(0.40))
                .cornerRadius(10)
                Spacer()
                HStack {
                    Image(systemName: "mail")  // Mail icon
                        .font(.system(size: 35))
                        .frame(width: 50, height: 50)
                        .foregroundColor(.brown)
                        .padding(.leading, 5)
                    TextField("Enter an Email", text: $email)
                        .textFieldStyle(PlainTextFieldStyle())
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding(.horizontal)
                }
                .background(Color.TF.opacity(0.70))
                .cornerRadius(10)
                //.padding(5)
                HStack {
                    Image(systemName: "person.badge.key")
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
                .padding(.top,5)
                
                HStack {
                    Button(action: {
                        rememberMe.toggle()  // Toggle the rememberMe state
                        if rememberMe {
                            saveLoginCredentials(email: email, password: password)  // Save login credentials
                        } else {
                            clearLoginCredentials()  // Clear login credentials
                        }
                        
                        UserDefaults.standard.set(rememberMe, forKey: "RememberMe")  // Save rememberMe state
                    }) {
                        Image(systemName: rememberMe ? "checkmark.square" : "square")  // Checkbox icon
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(.leading, 10)
                    }
                    Text("Remember Me")  // Remember Me label
                        .font(.headline)
                        .bold()
                        .frame(width: 120, height: 50)
                        .padding(.trailing, 10)
                        .foregroundColor(.blue)
                }
                .background(Color.TF.opacity(0.70))  // Background color with transparency
                .cornerRadius(10)
                .padding(5)
                
                Button(action: {
                    if !self.email.isEmpty && !self.password.isEmpty {
                        // Validate credentials
                        self.fireAuthHelper.signIn(email: self.email, password: self.password) { success, error in
                            if success {
                                // Navigate to home screen by changing the root view
                                    self.rootScreen = .Home
                                if self.rememberMe {
                                    saveLoginCredentials(email: self.email, password: self.password)
                                } else {
                                    clearLoginCredentials()
                                }
                            } else {
                                // Show error alert
                                self.alertMessage = error?.localizedDescription ?? "Sign in failed"
                                self.showAlert = true
                            }
                        }
                    } else {
                        // Trigger alert displaying errors
                        self.alertMessage = "Email and password cannot be empty"
                        self.showAlert = true
                    }
                }) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
                
                NavigationLink(destination: SignUpView(rootScreen: $rootScreen).environmentObject(fireAuthHelper), isActive: $showSignUp) {
                    EmptyView()
                }
                
                Button(action: {
                    self.showSignUp = true
                }) {
                    Text("Don't have an account? Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 25)
            .padding(.top, 30)
            .onAppear {
                if let savedEmail = UserDefaults.standard.string(forKey: "savedEmail"),
                   let savedPassword = UserDefaults.standard.string(forKey: "savedPassword") {
                    self.email = savedEmail
                    self.password = savedPassword
                    self.rememberMe = true
                }
            }
        }
    }
    
    private func saveLoginCredentials(email: String, password: String) {
        UserDefaults.standard.set(email, forKey: "savedEmail")
        UserDefaults.standard.set(password, forKey: "savedPassword")
    }
    
    private func clearLoginCredentials() {
        UserDefaults.standard.removeObject(forKey: "savedEmail")
        UserDefaults.standard.removeObject(forKey: "savedPassword")
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(rootScreen: .constant(.Login))
            .environmentObject(FireAuthHelper.getInstance())
    }
}
