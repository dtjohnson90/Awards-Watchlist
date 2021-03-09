//
//  ErrorManager.swift
//  Oscars
//
//  Created by Dustin Johnson on 1/15/21.
//  Copyright © 2021 Dustin Johnson. All rights reserved.
//

import Foundation
import FirebaseAuth


class ErrorManager: NSObject {
    func firestoreError(error: AuthErrorCode, completionBlock: @escaping (_ title: String, _ showError: Bool, _ errorString: String) -> Void) {
        switch error {
        case .networkError:
            completionBlock("Network Error",true,"A network error has occured during the operation")
        case .internalError:
            completionBlock("Fatal Error",true,"An internal error has occurred. Please email the developer at dtjohnsonapps@gmail.com to try and resolve this.")
        case .invalidEmail:
            completionBlock("Invalid Email",true,"The email address provided is not a valid email.")
        case .wrongPassword:
            completionBlock("Password Error",true,"Either the password is incorrect or has not been setup.")
        case .providerAlreadyLinked:
            completionBlock("Linking Error",true,"This account has already been linked.")
        case .credentialAlreadyInUse:
            completionBlock("Linking Error",true,"This account is already linked to another user.")
        case .noSuchProvider:
            completionBlock("Linking Error",true,"This account has already been unlinked")
        case .userNotFound:
            completionBlock("Email Verification Error",true,"A user account was not found in order to send the verification email")
        case .keychainError:
            completionBlock("Internal Error",true,"An error has occurred when attempting to sign you out. Please quit the app and try again.")
        default:
            completionBlock("Unknown Error",true,"An error has occurred that has not been documented. Please email the developer at dtjohnsonapps@gmail.com.")
        }
    }
    
    func googleError(error: Int, completionBlock: @escaping (_ title: String, _ showError: Bool, _ errorString: String) -> Void) {
        switch error {
        case -1:
            completionBlock("Unknown Error",true,"An unknown error has occurred. Please quit the app and try again.")
        case -2:
            completionBlock("Sign In Error",true,"An error has occurred while signing you in. Please quit the app and try again.")
        case -4:
            completionBlock("Sign In Error",true,"You don't seem to be signed in. Please click 'Sign Out' and try again")
        case -6:
            completionBlock("EMM Error",true,"This is a strange error that shouldn't be seen. Please email the developer at dtjohnsonapps@gmail.com")
        default:
            completionBlock("Unknown Error",true,"An error has occurred that has not been documented. Please email the developer at dtjohnsonapps@gmail.com.")
        }
    }
}
