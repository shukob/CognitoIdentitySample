//
//  IdentityProvider.swift
//  CognitoYourUserPoolsSample
//
//  Created by skonb on 2017/06/26.
//  Copyright © 2017年 Dubal, Rohan. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider

class IdentityProvider : AWSAbstractCognitoIdentityProvider{
    var client: DeveloperAuthenticationClient?
    var providerName: String = ""
    var token: String = ""
    
    init(regionType: AWSRegionType, identityId: String, identityPoolId: String, logins: [AnyHashable: Any], providerName: String, authClient client: DeveloperAuthenticationClient) {
        super.init(regionType, identityId: identityId, accountId: nil, identityPoolId: identityPoolId, logins: logins)
        
        self.client = client
        self.providerName = providerName
        
    }
    
    func authenticatedWithProvider() -> Bool {
        return logins[providerName] != nil
    }
    
    override func getIdentityId() -> AWSTask {
        // already cached the identity id, return it
        if identityId != "" {
            return AWSTask(result: nil)
        }
        else if !authenticatedWithProvider() {
            return super.getIdentityId()
        }
        else {
            return AWSTask(result: nil).continue(withBlock: {(_ task: AWSTask) -> Any in
                if identityId == "" {
                    return self.refresh()
                }
                return AWSTask(result: identityId)
            })
        }
        
    }
    
    func refresh() -> AWSTask {
        if !authenticatedWithProvider() {
            // We're using the simplified flow, so just return identity id
            return super.getIdentityId()
        }
        else {
            return client?.getToken(identityId, logins: logins)?.continue(withSuccessBlock: {(_ task: AWSTask) -> Any in
                if task.result {
                    let response: DeveloperAuthenticationResponse? = task.result
                    if !(identityPoolId == response?.identityPoolId) {
                        return try? AWSTask()!
                    }
                    // potential for identity change here
                    identityId = response?.identityId
                    self.token = response?.self.token
                }
                return AWSTask(result: identityId)
            })!
        }
    }
}
