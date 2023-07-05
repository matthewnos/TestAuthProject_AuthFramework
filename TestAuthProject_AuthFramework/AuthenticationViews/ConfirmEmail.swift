//
//  ConfirmEmail.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 6/27/23.
//

import Foundation
import SwiftUI
import Amplify

struct ConfirmEmail: View {
    @State var verificationCode: String = ""
    @State private var showConfirmError = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var confirmError = ""
    @State private var resendError = ""
    @State private var showResendError = false
    @State private var errorReMessage = ""
    @State private var showReError = false
    @EnvironmentObject var athm: AuthManager
    
    var body: some View {
        VStack {
            SecureField("Verification Code", text: $verificationCode)
                .padding()
                .font(.body)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            
            if showConfirmError {
                VStack {
                    Text(confirmError)
                }
            }
            if showError {
                VStack {
                    Text(errorMessage)
                }
            }
            
            if showResendError {
                VStack {
                    Text(resendError)
                }
            }
            if showReError {
                VStack {
                    Text(errorReMessage)
                }
            }
            
            Button(action: {
                print("🔴 Confirm Code Here...")
                confirmAction()
                showError = false
                showConfirmError = false
                showReError = false
                showResendError = false
            }) {
                Text("Confirm Code")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Button(action: {
                resendCode()
                showError = false
                showConfirmError = false
                showReError = false
                showResendError = false
            }) {
                Text("Resend Code")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.white)
        .ignoresSafeArea()
    }
    
    func confirmAction(){
        Task {
            do {
                try await athm.confirmSignUp(for: athm.userAccount.email, with: verificationCode)
                try await athm.signIn(username: athm.userAccount.email, password: athm.userAccount.password)
                showConfirmError = false
                showError = false
            } catch let error as AuthError {
                print("🛑 Error Signing In: \(error)")
                confirmError = error.errorDescription
                print("🛑 Error Confirming Code: \(confirmError)")
                showConfirmError = true
                print("showConfirmError: \(showConfirmError)")
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                print("Unexpected error: \(error)")
            }
        }
    }
    
    func resendCode(){
        Task {
            do {
                try await athm.resendCode(for: athm.userAccount.email)
                showResendError = false
                showError = false
            } catch let error as AuthError {
                print("🛑 Error Signing In: \(error)")
                resendError = error.errorDescription
                print("🛑 Error Signing Up: \(resendError)")
                showResendError = true
                print("showRegisterError: \(showResendError)")
            } catch {
                errorReMessage = error.localizedDescription
                showReError = true
                print("Unexpected error: \(error)")
            }
        }
    }
}


        
