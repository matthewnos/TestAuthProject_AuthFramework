//
//  AmplifyAuthCode.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 6/26/23.
//

import Foundation
import SwiftUI
import Combine
import Amplify
import AWSCognitoIdentity
import AWSCognitoAuthPlugin


@MainActor
class AuthManager: ObservableObject {
    
    @Published public var isSignedIn: Bool = false
    @Published public var message: String = ""
    @Published public var userAccount: UserAccount = UserAccount.make() {
        didSet {
            if userAccount.isValidPassword(userAccount.password) {
                isValidPassword = true
            } else {
                isValidPassword = false
            }
            
            if userAccount.isValidEmail(userAccount.email) {
                isEmailValid = true
            } else {
                isEmailValid = false
            }
            
            if userAccount.isValidPhone(userAccount.phoneNumber) {
                isValidPhone = true
            } else {
                isValidPhone = false
            }
            
            if userAccount.isValidName(userAccount.firstName) {
                isValidFirstName = true
            } else {
                isValidFirstName = false
            }
            
            if userAccount.isValidName(userAccount.lastName) {
                isValidLastName = true
            } else {
                isValidLastName = false
            }
        }
    }
    
    @Published public var userRights: UserRights = UserRights.make()
    @Published var authState: AuthState = .none
    var authToken: String = ""
    var subs = Set<AnyCancellable>()
    private var _refreshStopwatch: Stopwatch? = nil
    var refreshStopwatch: Stopwatch {
        get {
            _refreshStopwatch = _refreshStopwatch ?? Stopwatch(minutes: 10, repeatForever: true, onComplete: refreshSignIn)
            return _refreshStopwatch!
        }
    }
    
    static let shared = AuthManager()
    
    enum AuthState {
        case register
        case login
        case reset
        case forgotRequest
        case forgotConfirm
        case signout
        case delete
        case session
        case update
        case none
        case account
        case confirm
        case mfa
    }
    
    
    //MARK: Amplify
    func signIn(username: String, password: String) async throws {
        do {
            let signInResult = try await Amplify.Auth.signIn(username: username, password: password)
            if signInResult.isSignedIn {
                print("🟢 Sign in Successful")
                isSignedIn = true
                authState = .account
            } else {
                errorLoad()
            }
        } catch let error as AuthError {
            isSignedIn = false
            print("🛑 Sign in failed \(error)")
            errorLoad()
            throw error
        } catch {
            isSignedIn = false
            print("🛑 Unexpected error: \(error)")
            errorLoad()
            throw error
        }
    }
    
    func errorLoad(){

    }
    
    func signIn(){
        Task{
            do {
                try await signIn(username: userAccount.email, password: userAccount.password)
            } catch {
                print("Error Signing In: \(error)")
            }
        }
    }
    
    func refreshSignIn() {
        print("Refreshing Sign-In Auth Token")
        Task {
            do {
                authToken = try await getAuthToken()
                print("Sign-In Auth Token: Refreshed! New Token: \(authToken)")
            } catch {
                print("Error refreshing token: \(error)")
            }
        }
    }
    
    //MARK: Sign Up
    func signUp(username: String, password: String, email: String, phonenumber: String) async throws {
        let cleanPhone = cleanPhone(number: phonenumber)
        let userAttributes = [AuthUserAttribute(.email, value: email),AuthUserAttribute(.phoneNumber, value: cleanPhone)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        do {
            let signUpResult = try await Amplify.Auth.signUp(
                username: username,
                password: password,
                options: options
            )
            if case let .confirmUser(deliveryDetails, _, userId) = signUpResult.nextStep {
                print("Delivery details \(String(describing: deliveryDetails)) for userId: \(String(describing: userId))")
            } else {
                print("SignUp Complete")
            }
        } catch let error as AuthError {
            print("An error occurred while registering a user \(error)")
            errorLoad()
            throw error
        } catch {
            print("Unexpected error: \(error)")
            errorLoad()
            throw error
        }
    }
    
    //MARK: Confirm Sign Up
    func confirmSignUp(for username: String, with confirmationCode: String) async throws {
        do {
            let confirmSignUpResult = try await Amplify.Auth.confirmSignUp(
                for: username,
                confirmationCode: confirmationCode
            )
            print("Confirm sign up result completed: \(confirmSignUpResult.isSignUpComplete)")
        } catch let error as AuthError {
            print("An error occurred while confirming sign up \(error)")
            errorLoad()
            throw error
        } catch {
            print("Unexpected error: \(error)")
            errorLoad()
            throw error
        }
    }
        
        func resendCode(for username: String) async throws {
            do {
                let request = try await Amplify.Auth.resendSignUpCode(for: username)
            }catch let error as AuthError {
                print("An error occurred while confirming sign up \(error)")
                errorLoad()
                throw error
            } catch {
                print("Unexpected error: \(error)")
                errorLoad()
                throw error
            }
        }
    
    func resendCodeEmail() async throws{
        do {
            let deliveryDetails = try await Amplify.Auth.resendConfirmationCode(forUserAttributeKey: .email)
            print("Resend code send to - \(deliveryDetails)")
        } catch let error as AuthError {
            print("Resend code failed with error \(error)")
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw error
        }
    }
    
    //MARK: Confirm Sign Up & Sign In
    func confirm(username: String, code: String) {
        Task {
            do {
                try await confirmSignUp(for: username, with: code)
                try await signIn(username: userAccount.email, password: userAccount.password)
            }
        }
    }
    
    func awaitAttributes() async throws -> (email: String, phone: String) {
        do {
            let attributes = try await Amplify.Auth.fetchUserAttributes()
            guard let email = attributes.first(where: { $0.key == AuthUserAttributeKey.email })?.value,
                  let phone = attributes.first(where: { $0.key == AuthUserAttributeKey.phoneNumber })?.value else {
                throw AuthError.unknown("Email or phone number not found in user attributes")
            }
            return (email, phone)
        } catch let error as AuthError {
            print("Fetching user attributes failed with error \(error)")
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw error
        }
    }
    
    func getAuthToken() async throws -> String {
        do {
            let session = try await Amplify.Auth.fetchAuthSession(options: .forceRefresh())
            if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                
                let token = tokens.idToken
                
                if !refreshStopwatch.isRunning {
                    refreshStopwatch.start()
                }
                
                return token
            } else {
                throw AuthError.unknown("Failed to get Cognito token provider")
            }
        } catch {
            throw error
        }
    }
    
    func awaitAuthSession() async throws -> Bool {
        do {
            let session = try await Amplify.Auth.fetchAuthSession(options: .forceRefresh())
            if session.isSignedIn {
                isSignedIn = true
                authState = .account
            } else {
                authState = .none
                isSignedIn = false
            }
            print("🟢 NWM Is amplify Signed In - \(session.isSignedIn)")
            print("🟢 NWM Is local Signed In - \(isSignedIn)")
            return session.isSignedIn
        } catch let error as AuthError {
            print("Fetch session failed with error \(error)")
            errorLoad()
            throw error
        } catch {
            print("Unexpected Error: \(error)")
            throw error
        }
    }
    
    func signOutGlobally() async {
        let result = await Amplify.Auth.signOut(options: .init(globalSignOut: true))
        guard let signOutResult = result as? AWSCognitoSignOutResult
        else {
            print("Signout Failed.")
            return
        }
        print("Local Signout Successful: \(signOutResult.signedOutLocally)")
        switch signOutResult {
        case .complete:
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                isSignedIn = false
                authState = .none
                userAccount = UserAccount.make()
            }
            print("Completed Sign Out.")
        case .failed:
            print("Sign Out Failure.")
        default:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                isSignedIn = false
                authState = .none
                userAccount = UserAccount.make()
            }
            print("Partial Sign Out...")
        }
    }
    
    //Forgot Password (needs auth from email)
    
    func resetPassword(username: String) async throws {
        do {
            let resetResult = try await Amplify.Auth.resetPassword(for: username)
            switch resetResult.nextStep {
            case .confirmResetPasswordWithCode(let deliveryDetails, let info):
                print("Confirm reset password with code sent to - \(deliveryDetails) \(String(describing: info))")
            case .done:
                print("Reset completed")
            }
        } catch let error as AuthError {
            print("Reset password failed with error \(error)")
            if let cognitoAuthError = error.underlyingError as? AWSCognitoAuthError {
                switch cognitoAuthError {
                case .userNotFound:
                    print("User not found")
                    throw error
                case .invalidParameter:
                    print("Invalid Parameter")
                    throw error
                default:
                    print("break")
                    break
                }
            } else {
                print("else throw")
                throw error
            }    
        } catch {
            print("Unexpected error: \(error)")
            throw error
        }
    }
    
    func confirmResetPassword(username: String, newPassword: String, confirmationCode: String) async throws {
        do {
            try await Amplify.Auth.confirmResetPassword(
                for: username,
                with: newPassword,
                confirmationCode: confirmationCode
            )
            print("Password reset confirmed")
        } catch let error as AuthError {
            print("Reset password failed with error \(error)")
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw error
        }
    }
    
    //Change Password, must be logged in to do this
    //MARK: Change Password
    func changePassword(oldPassword: String, newPassword: String) async throws {
        do {
            try await Amplify.Auth.update(oldPassword: oldPassword, to: newPassword)
            print("🟢 Change password succeeded")
        } catch let error as AuthError {
            print("🛑 Change password failed with error \(error)")
            throw error
        } catch {
            print("🛑 Unexpected error: \(error)")
            throw error
        }
    }
    

    

    
    //MARK: Sign Up
    func register(username: String, password: String, email: String, phonenumber: String){
        Task {
            do {
                try await signUp(username: username, password: password, email: email, phonenumber: phonenumber)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                    authState = .confirm
                }
            }
        }
    }
    
    //MARK: Sign Out
    func signOut(){
        Task {
            do {
                await signOutGlobally()
            }
        }
    }
    //MARK: Delete User
    
    

    
    func deleteUser() async {
        do {
            try await Amplify.Auth.deleteUser()
            print("🟢 Successfully deleted user")
            authState = .register
        } catch let error as AuthError {
            print("🛑 Delete user failed with error \(error)")
        } catch {
            print("🛑 Unexpected error: \(error)")
        }
    }
    
    //MARK: Validation regEx
    
    //Validation
    @Published public var isEmailValid: Bool = true
    @Published public var isValidPassword: Bool = true
    @Published public var isValidPhone: Bool = true
    @Published public var isValidFirstName: Bool = true
    @Published public var isValidLastName: Bool = true
    @Published public var goodEmail = false
    @Published public var isValidOrg: Bool = true
    @Published public var tempBool: Bool = true

    
    func isValidLogin(email: Bool, pass: Bool) -> Bool {
        if email == true && pass == true {
            return true
        }
        return false
    }
    
    func isValidRegistration(email: Bool, pass: Bool, phone: Bool, first: Bool, last: Bool) -> Bool {
        return email && pass && phone && first && last
    }
    
    func isValidName(_ name: String) -> Bool {
        let regEx = "(?<! )[-a-zA-Z' ]{2,26}"
        let nameCheck = NSPredicate(format: "SELF MATCHES %@", regEx)
        return nameCheck.evaluate(with: name)
    }
    
    func isValidPhone(_ phone: String) -> Bool {
        let regEx = #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{4}$"#
        let phoneCheck = NSPredicate(format: "SELF MATCHES[c] %@", regEx)
        return phoneCheck.evaluate(with: phone)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func regexPassword(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*()_+\\-=[\\]{}|;':\",./<>?])(?!.*?(.)\\1{2})[A-Za-z\\d!@#$%^&*()_+\\-=[\\]{}|;':\",./<>?]{8,}$"
        do {
            let passwordRegex = try NSRegularExpression(pattern: passwordRegEx, options: [])
            let range = NSRange(location: 0, length: password.utf16.count)
            let match = passwordRegex.firstMatch(in: password, options: [], range: range)
            return match != nil
        } catch {
            print("Invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    func regexEmail(_ email: String) -> Bool {
        let emailRegEx = "^(?=.{1,256})(?=.{1,64}@.{1,255}$)(?=.{1,64}[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$)(?:(?:[^<>()\\[\\]\\\\.,;:\\s@\"]+(?:\\.[^<>()\\[\\]\\\\.,;:\\s@\"]+)*)|(?:(?:[^<>()[\\]\\\\.,;:\\s@\"]+\\.)?[^<>()[\\]\\\\.,;:\\s@\"]{1,64}@[^<>()[\\]\\\\.,;:\\s@\"]{1,255}\\.[^<>()[\\]\\\\.,;:\\s@\"]{2,6})$"
        
        do {
            let emailRegex = try NSRegularExpression(pattern: emailRegEx, options: [])
            let range = NSRange(location: 0, length: email.utf16.count)
            let match = emailRegex.firstMatch(in: email, options: [], range: range)
            return match != nil
        } catch {
            print("Invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    //MARK: Clean Phone Number
    func isValidPassword(_ password: String) -> Bool {
        let regEx = "^\\A(?=\\S*?[A-Z])(?=\\S*?[a-z])(?=\\S*?[0-9])(?=\\S*[#^_@$!%*?&])\\S{8,}\\z$"
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@", regEx)
        return passwordCheck.evaluate(with: password)
    }
    
    //MARK: Clean Phone Number
    func cleanPhone(number: String) -> String {
        let clean = "+1"+number
        print("Clean Number: \(clean)")
        return clean
    }
    
}

protocol AuthCognitoTokensProvider {
    func getCognitoTokens() -> Result<AuthCognitoTokens, AuthError>
}

protocol AuthCognitoTokens {

    var idToken: String {get}

    var accessToken: String {get}

    var refreshToken: String {get}

}
