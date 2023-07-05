//
//  RegisterView.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 6/27/23.
//

import Foundation
import SwiftUI
import Combine
import Amplify

struct RegisterView: View {
    
    @State private var username = ""
    @State private var password = ""
    @State private var phone = ""
    @State private var registerError = ""
    @State private var errorMessage = ""
    @State private var showRegisterError = false
    @State private var showError = false
    @State private var isUsernameValid = false
    @State private var isPasswordValid = false
    @State private var isPhoneValid = false
    @State private var isFirstNameValid = false
    @State private var isLastNameValid = false
    @State var backgroundColor: Color = .red
    @State var show: Bool = false
    @State var width: CGFloat = UIScreen.main.bounds.width * 0.7
    
    @EnvironmentObject var athm: AuthManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TextField("Email", text: $athm.userAccount.email)
                .padding()
                .font(.body)
                .foregroundColor(.primary)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isUsernameValid ? Color.green.opacity(0.3) : Color.red.opacity(0.8), lineWidth: 2)
                )
                .cornerRadius(8)
                .padding(.horizontal)
                .onChange(of: athm.userAccount.email) { newValue in
                    isUsernameValid = athm.isValidEmail(newValue)
                    print("isUsernameValid: \(isUsernameValid)")
                }
            
            SecureField("Password", text: $athm.userAccount.password)
                .padding()
                .font(.body)
                .foregroundColor(.primary)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isPasswordValid ? Color.green.opacity(0.3) : Color.red.opacity(0.8), lineWidth: 2)
                )
                .cornerRadius(8)
                .padding(.horizontal)
                .onChange(of: athm.userAccount.password) { newValue in
                    isPasswordValid = athm.isValidPassword(newValue)
                    print("isPasswordValid: \(isPasswordValid)")
                }
            
            TextField("Phone", text: $phone)
                .padding()
                .font(.body)
                .foregroundColor(.primary)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isPhoneValid ? Color.green.opacity(0.3) : Color.red.opacity(0.8), lineWidth: 2)
                )
                .cornerRadius(8)
                .padding(.horizontal)
                .onChange(of: phone) { newValue in
                    athm.userAccount.phoneNumber = phone
                    isPhoneValid = athm.isValidPhone(newValue)
                    print("newValue: \(newValue)")
                    print("isPhoneValid: \(isPhoneValid)")
                    print("phone: \(phone)")
                    print("athm phone: \(athm.userAccount.phoneNumber)")
                }
            
            TextField("First Name", text: $athm.userAccount.firstName)
                .padding()
                .font(.body)
                .foregroundColor(.primary)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isFirstNameValid ? Color.green.opacity(0.3) : Color.red.opacity(0.8), lineWidth: 2)
                )
                .cornerRadius(8)
                .padding(.horizontal)
                .onChange(of: athm.userAccount.firstName) { newValue in
                    isFirstNameValid = athm.isValidName(newValue)
                    print("isFirstNameValid: \(isFirstNameValid)")
                }
            
            TextField("Last Name", text: $athm.userAccount.lastName)
                .padding()
                .font(.body)
                .foregroundColor(.primary)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isLastNameValid ? Color.green.opacity(0.3) : Color.red.opacity(0.8), lineWidth: 2)
                )
                .cornerRadius(8)
                .padding(.horizontal)
                .onChange(of: athm.userAccount.lastName) { newValue in
                    isLastNameValid = athm.isValidName(newValue)
                    print("isLastNameValid: \(isLastNameValid)")
                }
            
            if showRegisterError {
                VStack {
                    Text(registerError)
                }
            }
            if showError {
                VStack {
                    Text(errorMessage)
                }
            }
            
            
            Button(action: {
                print("🔴 Register Here...")
                print("email valid?: \(athm.userAccount.isValidEmail(athm.userAccount.email))")
                print("password valid?: \(athm.userAccount.isValidPassword(athm.userAccount.password))")
                print("phone valid?: \(athm.userAccount.isValidPhone(athm.userAccount.phoneNumber))")
                print("firstName valid?: \(athm.userAccount.isValidName(athm.userAccount.firstName))")
                print("lastName valid?: \(athm.userAccount.isValidName(athm.userAccount.lastName))")
                registerAction()
//                if AuthManager.shared.isValidRegistration(email: athm.userAccount.isValidEmail(athm.userAccount.email), pass: athm.userAccount.isValidPassword(athm.userAccount.password), phone: athm.userAccount.isValidPhone(athm.userAccount.phoneNumber), first: athm.userAccount.isValidName(athm.userAccount.firstName), last: athm.userAccount.isValidName(athm.userAccount.lastName)) {
//                    print("🟢 Registered and Validated")
//                    registerAction()
//                } else {
//                    print("🔴 Not Valid")
//                }
            })
            {
                Text("Register")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Button(action: {
                athm.signOut()
            })
            {
                Text("Sign Out")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .edgesIgnoringSafeArea(.all)
    }
    
    func registerAction(){
        Task {
            do {
                try await athm.signUp(username: athm.userAccount.email, password: athm.userAccount.password, email: athm.userAccount.email, phonenumber: athm.userAccount.phoneNumber)
                showRegisterError = false
                showError = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                    athm.authState = .confirm
                }
            } catch let error as AuthError {
                print("🛑 Error Signing In: \(error)")
                registerError = error.errorDescription
                print("🛑 Error Signing Up: \(registerError)")
                showRegisterError = true
                print("showRegisterError: \(showRegisterError)")
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                print("Unexpected error: \(error)")
            }
        }
    }
}



