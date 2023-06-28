//
//  HomeScreen.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 6/26/23.
//

import Foundation
import SwiftUI


struct HomeScreen: View {
    
    @EnvironmentObject var athm: AuthManager
    var body: some View {

            switch athm.authState {
            case .register:
                RegisterView()
            case .login:
                LoginView()
            case .reset:
                PasswordResetView()
            case .forgotRequest:
                ForgotPasswordRequestView()
            case .forgotConfirm:
                ForgotPasswordConfirmationView()
            case .signout:
                EmptyView()
            case .delete:
                EmptyView()
            case .session:
                EmptyView()
            case .update:
                EmptyView()
            case .none:
                LoginView()
            case .account:
                AccountView()
            case .confirm:
                ConfirmEmail()
            case .mfa:
                EmptyView()
            }
    }
}

