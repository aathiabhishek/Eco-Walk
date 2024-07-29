//
//  ContentView.swift
//  Group_4
//
//  Created by Aathi Abhishek T on 2024-06-20.
//

import SwiftUI


struct ContentView: View {
    
    //update this line with shared instance
    var firedbHelper : FireDBHelper = FireDBHelper.getInstance()
    var fireAuthHelper : FireAuthHelper = FireAuthHelper.getInstance()
    // create an instance of root view enum to start the navigation with
    @State private var root: RootView = .Login
    
    var body: some View {
        
        NavigationStack{
            
            switch(root){
            case .Login:
                SignInView(rootScreen: self.$root)
                    .environmentObject(firedbHelper)
                    .environmentObject(fireAuthHelper)
            case.Home:
                HomeView(rootScreen: self.$root)
                    .environmentObject(firedbHelper)
                    .environmentObject(fireAuthHelper)
            case .SignUp:
                SignUpView(rootScreen: self.$root)
                    .environmentObject(firedbHelper)
                    .environmentObject(fireAuthHelper)
                
            }//NavigationStack
            
        }//body
    }
}
