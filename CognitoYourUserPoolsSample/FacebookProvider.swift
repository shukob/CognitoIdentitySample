//
//  FacebookProvider.swift
//  CognitoYourUserPoolsSample
//
//  Created by skonb on 2017/06/20.
//  Copyright © 2017年 Dubal, Rohan. All rights reserved.
//

import Foundation
import AWSCore
import FBSDKCoreKit

class FacebookProvider: NSObject, AWSIdentityProviderManager {
    func logins() -> AWSTask<NSDictionary> {
        if let token = FBSDKAccessToken.current()?.tokenString{
            return AWSTask(result: [AWSIdentityProviderFacebook:token])
        }
        return AWSTask(error:NSError(domain: "Facebook Login", code: -1 , userInfo: ["Facebook" : "No current Facebook access token"]))
    }
}
