//
//  SocialAuthenticationManager.swift
//  MyZone
//

import Foundation
import GoogleSignIn
import AuthenticationServices

enum SocialAuthenticationPlatform: String {
    case facebook
    case google
    case apple
}

class SocialAuthenticationManager: NSObject, GIDSignInDelegate {
    static let shared = SocialAuthenticationManager()
    private override init() { }
    
    private var loginCompletion: (([String: String?]?) -> Void)?
    private var sourceViewController: UIViewController?

    func login(with socialProvider: SocialAuthenticationPlatform, in viewController: UIViewController, completion: @escaping ([String: String?]?) -> Void) {
        viewController.view.endEditing(true)
        
        switch socialProvider {
        case .facebook:
            break
//            loginWithFacebook(in: viewController, completion: completion)
        case .google:
            loginWithGoogle(in: viewController, completion: completion)
        case .apple:
            loginWithApple(viewController: viewController, completion: completion)
        }
    }
    
//    private func loginWithFacebook(in viewController: UIViewController, completion: @escaping ([String: String?]?) -> Void) {
//        let loginManager = LoginManager()
//        loginManager.logOut()
//        loginManager.logIn(permissions: ["public_profile", "email"], from: viewController) { (FBLoginManagerResult, FBLoginError) in
//            if (FBLoginError != nil) {
////                PAMUtilManager.showFacebookErrorDialog(
////                    inView: viewController,
////                    facebookActionCallback: {
////                        PAMUtilManager.dismissFacebookErrorDialog()
////                        self.login(with: .facebook, in: viewController, completion: completion)
////                    }, emailActionCallback: {
////                        PAMUtilManager.dismissFacebookErrorDialog()
////                    }, closeActionCallback: {
////                        PAMUtilManager.dismissFacebookErrorDialog()
////                    }
////                )
//                return
//            }
//            if FBLoginManagerResult!.isCancelled {
//                return
//            }
////            self.loginCompletion = completion
//            let token = FBLoginManagerResult?.token?.tokenString ?? ""
////            completion(token)
//            self.getUserFBEmail(with: token, completion: completion)
//        }
//    }
    
//    func getUserFBEmail(with token: String, completion: @escaping ([String: String?]?) -> Void) {
//        let request = GraphRequest(graphPath: "me", parameters: ["fields" : "first_name, last_name, email"],
//                                   tokenString: token, version: "", httpMethod: .get)
//        request.start { (_, result, error) in
//            if error != nil {
//                completion(nil)
//            } else if let result = result as? [String: Any] {
//                let firstName = result["first_name"] as? String ?? ""
//                let lastName = result["last_name"] as? String ?? ""
//                let userData = ["name": "\(firstName) \(lastName)",
//                                "email": result["email"] as? String,
//                                "id": result["id"] as? String]
//                completion(userData)
//            }
//        }
//    }
    
    private func loginWithGoogle(in viewController: UIViewController, completion: @escaping ([String: String?]?) -> Void) {
        self.sourceViewController = viewController
        GIDSignIn.sharedInstance().presentingViewController = viewController
        GIDSignIn.sharedInstance()?.delegate = self
        self.loginCompletion = completion
        GIDSignIn.sharedInstance()?.signIn()
    }
        
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            loginCompletion?(nil)
        } else {
        
                let userData = ["name": user.profile.name,
                                "email": user.profile.email ,
                                "id": user.userID]
                loginCompletion?(userData)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
//        Log.error(error.localizedDescription)
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error?) {
//        Log.error(error?.localizedDescription ?? "Error")
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
        window.rootViewController?.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}

extension SocialAuthenticationManager {
    private func loginWithApple(viewController: UIViewController, completion: @escaping ([String: String?]?) -> Void) {
        self.sourceViewController = viewController
        self.loginCompletion = completion
        let appleIDProviderRequest = ASAuthorizationAppleIDProvider().createRequest()
        appleIDProviderRequest.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [appleIDProviderRequest])
        authorizationController.presentationContextProvider = self
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
}

extension SocialAuthenticationManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credentials = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userData = ["name": "\(credentials.fullName?.givenName ?? "") \(credentials.fullName?.familyName ?? "")",
                            "email": credentials.email,
                            "id": credentials.user]
            loginCompletion?(userData)
        }
    }
        
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        self.callback?(nil, error)
    }
}

extension SocialAuthenticationManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.sourceViewController!.view.window!
    }
}
