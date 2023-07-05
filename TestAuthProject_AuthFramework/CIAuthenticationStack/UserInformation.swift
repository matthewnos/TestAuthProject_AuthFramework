//
//  MainCode.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 6/26/23.
//

import Foundation
import SwiftUI
import Combine
import Amplify



struct UserAccount: Codable, Identifiable {
    var id = UUID()
    var rights: UserRights
    var firstName: String
    var lastName: String
    var username: String
    var password: String
    var phoneNumber: String
    var email: String
    var license: String
    var active: Bool
    var activeKey: String
    var orgkeys: [String]
    var role: String
    var sharedorgs: [String]
    var requests: [String]
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case password = "password"
        case phoneNumber = "phone"
        case email = "emailaddress"
        case active = "active"
        case activeKey = "activekey"
        case orgkeys = "orgkeys"
        case role = "role"
        case sharedorgs = "sharedorgs"
        case license = "license"
        case firstName = "firstname"
        case lastName = "lastname"
        case rights = "rights"
        case requests = "requests"
    }

    
    static func make() -> UserAccount {
        return UserAccount(rights: UserRights(role: "Administrator", layerAccess: [""]), firstName: "", lastName: "", username: "", password: "", phoneNumber: "", email: "", license: "", active: false, activeKey: "", orgkeys: [], role: "", sharedorgs: [], requests: [])
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let regEx = "^\\A(?=\\S*?[A-Z])(?=\\S*?[a-z])(?=\\S*?[0-9])(?=\\S*[:;#^_@$!%*?&])\\S{8,}\\z$"
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@", regEx)
        return passwordCheck.evaluate(with: password)
    }
    
    func isValidPhone(_ phone: String) -> Bool {
        let regEx = #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{4}$"#
        let phoneCheck = NSPredicate(format: "SELF MATCHES[c] %@", regEx)
        return phoneCheck.evaluate(with: phone)
    }
    
    func isValidName(_ name: String) -> Bool {
        let regEx = "(?<! )[-a-zA-Z' ]{2,26}"
        let nameCheck = NSPredicate(format: "SELF MATCHES %@", regEx)
        return nameCheck.evaluate(with: name)
    }
}

struct UserRights: Codable, Identifiable {
    public var id = UUID()
    public var role: String
    public var layerAccess: [String]
    
    enum CodingKeys: String, CodingKey {
        case role = "role"
        case layerAccess = "layeraccess"
    }
    
    static func make() -> UserRights {
        return UserRights(role: "Administrator", layerAccess: ["Path", "Doors","Cable Routes", "Rooms", "Physical Security"])
    }
}
