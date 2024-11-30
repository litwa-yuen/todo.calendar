//
//  SignInView.swift
//  todo.calendar
//
//  Created by Lit Wa Yuen on 11/29/24.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices
import FirebaseCore
import GoogleSignIn

struct SignInView: View {
    @AppStorage("isSignedIn") var isSignedIn = false // Track user sign-in state
    var body: some View {
        NavigationView {
            VStack {
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
                .padding()
                
                Spacer()

            }
      
            
        }
    }


    
    func handSignInButton() {
        if let rootViewController = getRootViewController() {
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                if let error = error {
                    print("Error during Google Sign-In: \(error.localizedDescription)")
                    return
                }
                
                guard let result = result else {
                    print("No result from Google Sign-In.")
                    return
                }
                
                let user = result.user
                guard let idToken = user.idToken?.tokenString else {
                    print("No ID token found in Google Sign-In result.")
                    return
                }
                
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )
                
                // Sign in to Firebase with the credential
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Firebase authentication error: \(error.localizedDescription)")
                    } else {
                        print("Successfully signed in with Google.")
                        DispatchQueue.main.async {
                            UserDefaults.standard.set(true, forKey: "isSignedIn")
                        }
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
