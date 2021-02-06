//
//  LoginViewController.swift
//  Red VS Blue
//
//  Created by Hanyu Yang on 2021/1/16.
//

import UIKit
import Firebase
import Rosefire
import GoogleSignIn
import CryptoKit
import AuthenticationServices

class LoginViewController: UIViewController, ASAuthorizationControllerPresentationContextProviding {
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var appleSignInButton: ASAuthorizationAppleIDButton!
    
    fileprivate var currentNonce: String?
    
    static var isGuest = false
    let REGISTRY_TOKEN = "9f549980-c326-4e31-aa18-869cc452b1d4"
    
    var rosefireName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        GIDSignIn.sharedInstance()?.presentingViewController = self
        googleSignInButton.style = .wide
        
        appleSignInButton.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rosefireName = nil
        if Auth.auth().currentUser != nil {
            print("Someone is already signed in! Just move on!")
            self.performSegue(withIdentifier: mainSegueIdentifier, sender: self)
        }
    }
    
    @IBAction func pressedRosefireLoginButton(_ sender: Any) {
        Rosefire.sharedDelegate().uiDelegate = self // This should be your view controller
        Rosefire.sharedDelegate().signIn(registryToken: REGISTRY_TOKEN) { (err, result) in
            if let err = err {
                print("Rosefire sign in error! \(err)")
                return
            }
            //            print("Result = \(result!.username!)")
            //            print("Result = \(result!.name!)")
            //            print("Result = \(result!.email!)")
            //            print("Result = \(result!.group!)")
            
            self.rosefireName = result!.name!
            
            Auth.auth().signIn(withCustomToken: result!.token) { (authResult, error) in
                if let error = error {
                    print("Firebase sign in error! \(error)")
                    return
                }
                // User is signed in using Firebase!
                print("sign in success")
                LoginViewController.isGuest = false
                self.performSegue(withIdentifier: mainSegueIdentifier, sender: self)
            }
        }
    }
    
    @IBAction func pressedSignInEmailButton(_ sender: Any) {
        LoginViewController.isGuest = false
        self.performSegue(withIdentifier: signUpSegueIdentifier, sender: self)
    }
    
    @IBAction func pressedSignInLaterButton(_ sender: Any) {
        AlertDialog.showAlertDialog(viewController: self, title: "Warning!",
                                    message: "You cannot play any games when you are not signed in!",
                                    confirmTitle: "Continue") {
            LoginViewController.isGuest = true
            self.performSegue(withIdentifier: mainSegueIdentifier, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == mainSegueIdentifier {
            if LoginViewController.isGuest {
                return
            }
            print("Checking for user: \(Auth.auth().currentUser!.uid)")
            UserManager.shared.addNewUserMabye(uid: Auth.auth().currentUser!.uid, name: rosefireName ??  RandomStringGenerator.shared.generateRandomUsername(), photoUrl: Auth.auth().currentUser!.photoURL?.absoluteString)
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    
    @available(iOS 13, *)
    @objc func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
}

@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error.localizedDescription)
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
                print("Sign in with apple success!")
                self.performSegue(withIdentifier: mainSegueIdentifier, sender: self)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
}
