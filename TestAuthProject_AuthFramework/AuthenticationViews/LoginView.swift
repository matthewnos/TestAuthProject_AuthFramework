//
//  LoginView.swift
//  CIMapCompanion
//
//  Created by Matthew Nos on 6/5/23.
//

import Foundation
import SwiftUI
import Amplify

struct LoginView: View {
    @State private var isUsernameValid = false
    @State private var isPasswordValid = false
    @State private var loginError = ""
    @State private var showLoginError = false
    @State private var errorMessage = ""
    @State private var showError = false
    @EnvironmentObject var athm: AuthManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TextField("Email", text: $athm.userAccount.email)
                .padding()
                .font(.body)
                .foregroundColor(.primary)
                .background(RoundedRectangle(cornerRadius: 8).fill(isUsernameValid ? Color.gray.opacity(0.1) : Color.red.opacity(0.2)))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(isUsernameValid ? Color.green.opacity(0.3) : Color.red.opacity(0.8), lineWidth: 2))
                .onChange(of: athm.userAccount.email) { newValue in
                    isUsernameValid = athm.isValidEmail(newValue)
                    print(isUsernameValid)
                }
            
            SecureField("Password", text: $athm.userAccount.password)
                .padding()
                .font(.body)
                .foregroundColor(.primary)
                .background(RoundedRectangle(cornerRadius: 8).fill(isPasswordValid ? Color.gray.opacity(0.1) : Color.red.opacity(0.2)))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(isPasswordValid ? Color.green.opacity(0.3) : Color.red.opacity(0.8), lineWidth: 2))
                .onChange(of: athm.userAccount.password) { newValue in
                    isPasswordValid = athm.isValidPassword(newValue)
                    print(isPasswordValid)
                }
            if showLoginError {
                VStack {
                    Text(loginError)
                }
            }
            if showError {
                VStack {
                    Text(errorMessage)
                }
            }
            
            Button(action: {
                signIn()
            }) {
                Text("Log in")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Button(action: {
                showLoginError = false
                showError = false
                athm.signOut()
            }) {
                Text("Sign Out")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Button(action: {
                athm.authState = .forgotRequest
            }) {
                Text("Forgot Password")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Button(action: {
                athm.authState = .none
            }) {
                Text("Account View")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Button(action: {
                athm.authState = .register
            }) {
                Text("Create Account")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            Task {
                try await athm.awaitAuthSession()
            }
        }
    }
    
    func signIn(){
        Task{
            do {
                try await athm.signIn(username: athm.userAccount.email, password: athm.userAccount.password)
                showLoginError = false
                showError = false
                print("showLoginError: \(showLoginError)")
            } catch let error as AuthError {
                print("🛑 Error Signing In: \(error)")
                loginError = error.errorDescription
                print("🛑 Error Signing In: \(loginError)")
                showLoginError = true
                print("showLoginError: \(showLoginError)")
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                print("Unexpected error: \(error)")
            }
        }
    }
}


