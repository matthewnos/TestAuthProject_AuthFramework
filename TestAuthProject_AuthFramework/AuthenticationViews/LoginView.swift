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
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            VStack {
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
                HStack {
                    if showLoginError {
                        HStack {
                            Text(loginError)
                                .font(.system(size: 11))
                            Spacer()
                        }
                    } else if showError {
                        HStack {
                            Text(errorMessage)
                                .font(.system(size: 11))
                            Spacer()
                        }
                    } else {
                        HStack {
                            Text("")
                                .font(.system(size: 11))
                            Spacer()
                        }
                    }
                    Button(action: {
                        athm.authState = .forgotRequest
                    }) {
                        Text("Forgot Password")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
                VStack {
                    Button(action: {
                        showLoginError = false
                        showError = false
                        signIn()
                    }) {
                        Text("Log in")
                            .font(.headline)
                            .frame(height: 25)
                            .frame(maxWidth: .infinity)
                    }
                    .cornerRadius(8)
                    .buttonStyle(.borderedProminent)
                    
                    Text("Don't have an account yet?")
                        .padding(.top,30)
                    Button(action: {
                        athm.authState = .register
                    }) {
                        Text("Create Account")
                            .font(.headline)
                            .frame(height: 25)
                            .frame(maxWidth: .infinity)
                    }
                    .cornerRadius(8)
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: 200)
            }
            //        .frame(maxWidth: hSizeClass == .compact ? .infinity : 500)
            .frame(maxWidth: 500)
            .padding()
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


