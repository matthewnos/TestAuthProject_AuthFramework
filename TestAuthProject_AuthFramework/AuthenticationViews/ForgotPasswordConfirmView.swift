//
//  ForgotPasswordConfirmView.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 6/28/23.
//

import Foundation
import SwiftUI
import Amplify
import Combine



struct ForgotPasswordConfirmationView: View {
    @State var newPassword: String = ""
    @State var showAuthError: Bool = false
    @State var showError: Bool = false
    @State private var isUsernameValid = false
    @State private var isPasswordValid = false
    @State var authErrorMessage: String = ""
    @State var errorMessage: String = ""
    @State var confirmationCode: String = ""
    @State var reErrorMessage = ""
    @State var resendErrorMessage = ""
    @State var showResendError = false
    @State var showReError = false
    
    @EnvironmentObject var athm: AuthManager
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            TextField("Email", text: $athm.userAccount.email)
                .padding()
                .font(.body)
                .foregroundColor(.primary)
                .background(RoundedRectangle(cornerRadius: 8).fill(isUsernameValid ? Color.gray.opacity(0.1) : Color.red.opacity(0.2)))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(isUsernameValid ? Color.green.opacity(0.3) : Color.red.opacity(0.8), lineWidth: 2))
                .cornerRadius(8)
                .onChange(of: athm.userAccount.email) { newValue in
                    isUsernameValid = athm.isValidEmail(newValue)
                    print(isUsernameValid)
                }
            
            SecureField("New Password", text: $newPassword)
                .padding()
                .font(.body)
                .foregroundColor(.primary)
                .background(RoundedRectangle(cornerRadius: 8).fill(isPasswordValid ? Color.gray.opacity(0.1) : Color.red.opacity(0.2)))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(isPasswordValid ? Color.green.opacity(0.3) : Color.red.opacity(0.8), lineWidth: 2))
                .cornerRadius(8)
                .onChange(of: newPassword) { newValue in
                    isPasswordValid = athm.isValidPassword(newValue)
                    print(isPasswordValid)
                }
            
            TextField("Confirmation Code", text: $confirmationCode)
                .padding()
                .font(.body)
                .foregroundColor(.primary)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            
            if showAuthError {
                HStack {
                    Text(authErrorMessage)
                        .font(.system(size: 11))
                    Spacer()
                }
                .padding(.leading)
            } else if showError {
                HStack {
                    Text(errorMessage)
                        .font(.system(size: 11))
                    Spacer()
                }
                .padding(.leading)
            } else if showResendError {
                HStack {
                    Text(resendErrorMessage)
                        .font(.system(size: 11))
                    Spacer()
                }
                .padding(.leading)
            } else if showReError {
                HStack {
                    Text(reErrorMessage)
                        .font(.system(size: 11))
                    Spacer()
                }
                .padding(.leading)
            } else {
                HStack {
                    Text(" ")
                        .font(.system(size: 11))
                    Spacer()
                }
            }
            VStack {
            Button(action: {
                showError = false
                showAuthError = false
                showResendError = false
                showReError = false
                forgotPasswordConfirm()
            }) {
                Text("Confirm")
                    .font(.headline)
                    .frame(height: 25)
                    .frame(maxWidth: .infinity)
            }
            .cornerRadius(8)
            .buttonStyle(.borderedProminent)
            
            Button(action: {
                signOut()
            }) {
                Text("Sign Out")
                    .font(.headline)
                    .frame(height: 25)
                    .frame(maxWidth: .infinity)
            }
            .cornerRadius(8)
            .buttonStyle(.borderedProminent)
            }.frame(maxWidth: 200)
        }
        .frame(maxWidth: 500)
        .padding()
    }
    
    func forgotPasswordConfirm() {
        Task {
            do {
                try await athm.confirmResetPassword(username: athm.userAccount.email, newPassword: newPassword, confirmationCode: confirmationCode)
                athm.userAccount.password = newPassword
                athm.signOut()
                athm.authState = .login
            } catch let error as AuthError {
                authErrorMessage = error.errorDescription
                showAuthError = true
                print("❌ \(error)")
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                print("❌ Unexpected error: \(error)")
            }
            
        }
    }
    
    func resendCode() {
        Task {
            do {
                try await athm.resendCodeEmail()
            } catch let error as AuthError {
                resendErrorMessage = error.errorDescription
                showResendError = true
                print("❌ \(error)")
            } catch {
                reErrorMessage = error.localizedDescription
                showReError = true
                print("❌ Unexpected error: \(error)")
            }
            
        }
    }
    
    func signOut(){
        Task {
            do {
                await athm.signOutGlobally()
            }
        }
    }
}

