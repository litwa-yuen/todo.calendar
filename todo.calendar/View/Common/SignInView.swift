//
//  SignInView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/29/24.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices
import Firebase
import GoogleSignIn
import CryptoKit

struct SignInView: View {
    @State var errorMessage: String = ""
    @State var showAlert: Bool = false
    @State var isLoading: Bool = false
    @Environment(\.colorScheme) private var scheme
    @AppStorage("isSignedIn") var isSignedIn: Bool = false
    @State var nonce: String?
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Button(action: handSignInButton) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                        Text("Sign in with Google")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                SignInWithAppleButton(.signIn) { request in
                    let nonce = randomNonceString()
                    self.nonce = nonce
                    request.requestedScopes = [.email, .fullName]
                    request.nonce = sha256(nonce)
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        loginWithFirebase(authorization)
                    case .failure(let error):
                        showErrorMessage(error.localizedDescription)
                    }
                    
                }
                .overlay{
                    ZStack{
                        Capsule()
                        HStack{
                            Image(systemName: "applelogo")
                            Text("Sign in with Apple")
                        }
                        .foregroundStyle(scheme == .dark ? .black : .white)
                    }
                    .allowsHitTesting(false)
                }
                .frame(height: 45)
                .clipShape(.capsule)
                .padding(.top, 10)
                
            }
            
            
        }
        .alert(errorMessage, isPresented: $showAlert) {}
        .overlay {
            if isLoading {
                loadingView()
            }
        }
    }
    @ViewBuilder
    func loadingView() -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
            ProgressView()
                .frame(width: 45, height: 45)
                .background(.background, in: .rect(cornerRadius: 5))
        }
    }
    func showErrorMessage(_ message: String) {
        errorMessage = message
        showAlert.toggle()
        isLoading = false
    }
    
    func loginWithFirebase(_ authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            isLoading = true
            guard let nonce else {
                showErrorMessage("Cannot process your request.")
                return
                //fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                showErrorMessage("Cannot process your request.")
                //print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                showErrorMessage("Cannot process your request.")
                //print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    showErrorMessage(error.localizedDescription)
                    return
                }
                // User is signed in to Firebase with Apple.
                isSignedIn = true
                isLoading = false
                
            }
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func handSignInButton() {
        if let rootViewController = getRootViewController() {
            isLoading = true
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                if let error = error {
                    
                    showErrorMessage("Error during Google Sign-In: \(error.localizedDescription)")
                    return
                }
                
                guard let result = result else {
                    showErrorMessage("No result from Google Sign-In.")
                    return
                }
                
                let user = result.user
                guard let idToken = user.idToken?.tokenString else {
                    showErrorMessage("No ID token found in Google Sign-In result.")
                    return
                }
                
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )
                
                // Sign in to Firebase with the credential
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        showErrorMessage("Firebase authentication error: \(error.localizedDescription)")
                    } else {
                        isSignedIn = true
                        isLoading = false
                    }
                }
            }
        }
    }
    
    
}

func getRootViewController() -> UIViewController? {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let rootViewController = scene.windows.first?.rootViewController else {
        return nil
    }
    
    return getVisibleViewController(from: rootViewController)
}

private func getVisibleViewController(from vc: UIViewController) -> UIViewController {
    if let nav = vc as? UINavigationController {
        return getVisibleViewController(from: nav.visibleViewController!)
    }
    if let tab = vc as? UITabBarController {
        return getVisibleViewController(from: tab.selectedViewController!)
    }
    if let presented = vc.presentedViewController {
        return getVisibleViewController(from: presented)
    }
    
    return vc
    
}
