//
//  PasswordResetView.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 6/28/23.
//

import Foundation
import SwiftUI
import Amplify
import Combine

public struct PasswordResetView: View {
    @State var backgroundColor: Color = .red
    @State var show: Bool = false
    @State var width: CGFloat = UIScreen.main.bounds.width * 0.7
    @State var newPassword: String = ""
    @State var showAuthError: Bool = false
    @State var showError: Bool = false
    @State private var isPasswordValid = false
    @State private var isNewPasswordValid = false
    @State var authErrorMessage: String = ""
    @State var errorMessage: String = ""
    
    @EnvironmentObject var athm: AuthManager
    
    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                VStack(alignment: .leading, spacing: 40) {
                    Group {
                        HStack(spacing: 20){
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
                            Spacer()
                        }.padding(.leading, 40)
                        
                        HStack(spacing: 20){
                            SecureField("Password", text: $newPassword)
                                .padding()
                                .font(.body)
                                .foregroundColor(.primary)
                                .background(RoundedRectangle(cornerRadius: 8).fill(isPasswordValid ? Color.gray.opacity(0.1) : Color.red.opacity(0.2)))
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(isPasswordValid ? Color.green.opacity(0.3) : Color.red.opacity(0.8), lineWidth: 2))
                                .onChange(of: newPassword) { newValue in
                                    isNewPasswordValid = athm.isValidPassword(newValue)
                                    print(isNewPasswordValid)
                                }
                            Spacer()
                        }.padding(.leading, 40)
                        
                        VStack(spacing: 20){
                            if showAuthError {
                                HStack(spacing: 20) {
                                    Text(authErrorMessage)
                                    Spacer()
                                }.padding(.leading, 40)
                            }
                            if showError {
                                HStack(spacing: 20) {
                                    Text(errorMessage)
                                    Spacer()
                                }.padding(.leading, 40)
                            }
                        }
                    }
                }
                VStack {
                    HStack {
                        Button(action: {
                            Task {
                                do {
                                    try await resetPassword()
                                } catch {
                                    print("Error:", error)
                                }
                            }
                        }) {
                            Text("Confirm")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        Spacer()
                    }.padding(.leading, 40)
                }
            }
            Spacer()
        }
    }
    
    func resetPassword() async throws {
        do {
            try await athm.changePassword(oldPassword: athm.userAccount.password, newPassword: newPassword)
            showAuthError = false
            showError = false
            authErrorMessage = ""
            errorMessage = ""
            athm.userAccount.password = newPassword
            athm.signOut()
            athm.authState = .login
        } catch let error as AuthError {
            authErrorMessage = error.localizedDescription
            showAuthError = true
            print("Change password failed with error \(error)")
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("Unexpected error: \(error)")
        }
    }
}


