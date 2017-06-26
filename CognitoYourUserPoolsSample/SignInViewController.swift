//
// Copyright 2014-2017 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License").
// You may not use this file except in compliance with the
// License. A copy of the License is located at
//
//     http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, express or implied. See the License
// for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import AWSCognitoIdentityProvider
import FBSDKLoginKit
import TwitterKit

class SignInViewController: UIViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var twLoginButton: TWTRLogInButton!
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?

    var usernameText: String?
    
    func backgroundDidTap(sender: UITapGestureRecognizer){
       username.resignFirstResponder()
        password.resignFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if (FBSDKAccessToken.current() != nil) {
            //TODO
            
        }
        view?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backgroundDidTap)))
        fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"];
        fbLoginButton.delegate = self
        twLoginButton.logInCompletion = { [weak self](session, error) in
            if let _ = session{
                let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .APNortheast1, identityPoolId: CognitoFederatedIdentityPoolId, identityProviderManager: TwitterProvider())
                credentialsProvider.identityProvider.logins().continueWith(block: { [weak self](task) -> Any? in
                    print(task.result ?? "")
                    return credentialsProvider.identityProvider.getIdentityId().continueWith(block: { (task) -> Any? in
                        print(task.result ?? "")
                        self?.dismiss(animated: true, completion: nil)
                        return nil
                    })
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.password.text = nil
        self.username.text = usernameText
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func signInPressed(_ sender: AnyObject) {
        if (self.username.text != nil && self.password.text != nil) {
            let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.username.text!, password: self.password.text! )
            self.passwordAuthenticationCompletion?.set(result: authDetails)
        } else {
            let alertController = UIAlertController(title: "Missing information",
                                                    message: "Please enter a valid user name and password",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
            alertController.addAction(retryAction)
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if result.isCancelled{
            
        }else{
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .APNortheast1, identityPoolId: CognitoFederatedIdentityPoolId, identityProviderManager: FacebookProvider())
            credentialsProvider.identityProvider.logins().continueWith(block: { [weak self](task) -> Any? in
                print(task.result ?? "")
                return credentialsProvider.getIdentityId().continueWith(block: { (task) -> Any? in
                    print(task.result ?? "")
                    self?.dismiss(animated: true, completion: nil)
                    return nil
                })
            })
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
       return true
    }

}

extension SignInViewController: AWSCognitoIdentityPasswordAuthentication {
    
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if (self.usernameText == nil) {
                self.usernameText = authenticationInput.lastKnownUsername
            }
        }
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as? NSError {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.username.text = nil
                let pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
                let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .APNortheast1, identityPoolId: CognitoFederatedIdentityPoolId, identityProviderManager: pool)
                credentialsProvider.identityProvider.logins().continueWith(block: { [weak self](task) -> Any? in
                    print(task.result ?? "")
                   return credentialsProvider.getIdentityId().continueWith(block: { (task) -> Any? in
                    print(task.result ?? "")
                    self?.dismiss(animated: true, completion: nil)
                        return nil
                   })
                })
            }
        }
    }
}
