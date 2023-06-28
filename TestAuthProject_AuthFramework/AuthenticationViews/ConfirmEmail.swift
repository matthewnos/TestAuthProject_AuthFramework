//
//  ConfirmEmail.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 6/27/23.
//

import Foundation
import SwiftUI

public struct ConfirmEmail: View {
    @State var verificationCode: String = ""
    @EnvironmentObject var athm: AuthManager
    
    public var body: some View {
        VStack {
            SecureField("Verification Code", text: $verificationCode)
                .padding()
                .font(.body)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
            
            Button(action: {
                print("🔴 Confirm Code Here...")
                athm.confirm(username: athm.userAccount.email, code: verificationCode)
            }) {
                Text("Confirm Code")
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
}


        
