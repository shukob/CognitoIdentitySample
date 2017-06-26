//
//  TwitterProvider.swift
//  CognitoYourUserPoolsSample
//
//  Created by skonb on 2017/06/27.
//  Copyright © 2017年 Dubal, Rohan. All rights reserved.
//

import Foundation
import AWSCore
import TwitterKit

class TwitterProvider: NSObject, AWSIdentityProviderManager {
    func logins() -> AWSTask<NSDictionary> {
        if let session = Twitter.sharedInstance().sessionStore.session(){
            let token = "\(session.authToken);\(session.authTokenSecret)"
            return AWSTask(result: [AWSIdentityProviderTwitter: token])
        }
        return AWSTask(error:NSError(domain: "Twitter Login", code: -1 , userInfo: ["Twitter" : "No current twitter session"]))
    }
}
