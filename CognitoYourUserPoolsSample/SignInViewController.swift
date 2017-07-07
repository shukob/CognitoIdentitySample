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

enum LoginType{
    case Facebook, Twitter, UserPool
}

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
                self?.login(with: credentialsProvider,  loginType: .Twitter)
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
            login(with: credentialsProvider,  loginType: .Facebook)
            
        }
    }
    
    func login(with credentialsProvider: AWSCognitoCredentialsProvider, loginType: LoginType){
        credentialsProvider.identityProvider.logins().continueWith(block: { [weak self](task) -> Any? in
            return credentialsProvider.getIdentityId().continueWith(block: { (task) -> Any? in
                if let error = task.error{
                    print(error)
                    return nil
                }else{
                    if let identityId = task.result{
                        let config = AWSServiceConfiguration(region: .APNortheast1, credentialsProvider: credentialsProvider)
                        AWSServiceManager.default().defaultServiceConfiguration = config
                        return TCTectecClient.default().userDetailGet(identityId: String(identityId)).continueWith(block: {[weak self] (task: AWSTask<TCUserDetail>) -> Any? in
                            if task.result == nil{
                                self?.registerUser(with: credentialsProvider, identityId: identityId as String, loginType: loginType)
                            }else{
                                self?.dismiss(animated: true, completion: nil)
                            }
                            return nil
                        })
                    }else{
                        return nil
                    }
                }
            })
        })
    }
    
    func registerUser(with credentialsProvider: AWSCognitoCredentialsProvider, identityId: String,  loginType: LoginType){
        switch(loginType){
        case .Facebook:
            let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: FBSDKAccessToken.current().tokenString, version: nil, httpMethod: "GET")
            let _ = req?.start(completionHandler: { [weak self](_, result, _) in
                if let result = result as? [String: Any]{
                    let email = result["email"] as? String
                    let nickName = result["name"] as? String
                    self?.registerUser(withNickName: nickName!, email: email!, identityId: identityId)
               }
            })
        case .Twitter:
            TWTRAPIClient.withCurrentUser().requestEmail(forCurrentUser: { (email, error) in
                if let email = email{
                    TWTRAPIClient.withCurrentUser().loadUser(withID: Twitter.sharedInstance().sessionStore.session()!.userID, completion: {[weak self] (user, error) in
                        if let user = user{
                            let nickName = user.screenName
                            self?.registerUser(withNickName: nickName, email: email, identityId: identityId)
                        }
                    })
                }
            })
            break
        case .UserPool:
            let pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
            let user = pool.currentUser()
            user?.getDetails().continueOnSuccessWith { [weak self] (task) -> AnyObject? in
                let nickName = user?.username
                let email = self?.username?.text
                self?.registerUser(withNickName: nickName!, email: email!, identityId: identityId)
                return nil
            }
            break
        default:
            break
        }
    }
    
    func registerUser(withNickName nickName: String, email: String, identityId: String){
        let newUser = try! TCNewUser(dictionary: ["identityId": identityId, "nickName": nickName, "email": email], error: ())
        TCTectecClient.default().userPost(body: newUser).continueWith(block: {[weak self] (result) -> Any? in
            if let _ = result.result{
                self?.dismiss(animated: true, completion: nil)
            }else{
                //TODO handle registration error
            }
            
            return nil
        })
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
        DispatchQueue.main.async { [weak self] in
            if let error = error as? NSError {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self?.present(alertController, animated: true, completion:  nil)
            } else {
                let pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
                let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .APNortheast1, identityPoolId: CognitoFederatedIdentityPoolId, identityProviderManager: pool)
                self?.login(with: credentialsProvider, loginType: .UserPool)
            }
        }
    }
}
