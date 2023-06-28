//
//  AccountView.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 6/28/23.
//

import Foundation
import SwiftUI

public struct AccountView: View {
    
    @EnvironmentObject var athm: AuthManager
    public var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Spacer().frame(height: 40)
                VStack(alignment: .leading, spacing: 40) {
                    Group {
                        HStack(spacing: 20){
                            VStack {
                                Text("Welcome, \(athm.userAccount.firstName)!")
                                    .font(.system(size: 24, weight: .bold))
                                Text("What would you like to do today?")
                                    .font(.system(size: 15, weight: .bold))
                            }
                            Spacer()
                        }.padding(.leading, 20)
                        
                        HStack(spacing: 20){
                            Button(action: {
                                print("Reset Password")
                                athm.authState = .reset
                            }) {
                                Text("Reset Password")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            Spacer()
                        }.padding(.leading, 20)
                        
                        HStack(spacing: 20){
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
                            Spacer()
                        }.padding(.leading, 20)
                        
                        HStack(spacing: 20){
                            Button(action: {
                                athm.signOut()
                            }) {
                                Text("Sign Out")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            Spacer()
                        }.padding(.leading, 20)
                        
                        HStack(spacing: 20){
                            Button(action: {
                                print("Delete Account")
                            }) {
                                Text("Delete Account")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            Spacer()
                        }.padding(.leading, 20)
                    }
                    Spacer().frame(height: 50)
                }
            }
            Spacer()
        }
    }
}

