/*
 Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License").
 You may not use this file except in compliance with the License.
 A copy of the License is located at

 http://aws.amazon.com/apache2.0

 or in the "license" file accompanying this file. This file is distributed
 on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 express or implied. See the License for the specific language governing
 permissions and limitations under the License.
 */
 

import Foundation
import AWSCore

 
public class TCUserSetting : AWSModel {
    
    var id: NSNumber?
    var userId: NSNumber?
    var infoMail: NSNumber?
    var directMessage: NSNumber?
    var response: NSNumber?
    var follow: NSNumber?
    var teachingFavorite: NSNumber?
    var teachingPurchase: NSNumber?
    var teachingReport: NSNumber?
    var updated: String?
    var updatedUser: String?
    var created: String?
    var createdUser: String?
    
   	public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]!{
		var params:[AnyHashable : Any] = [:]
		params["id"] = "id"
		params["userId"] = "user_id"
		params["infoMail"] = "info_mail"
		params["directMessage"] = "direct_message"
		params["response"] = "response"
		params["follow"] = "follow"
		params["teachingFavorite"] = "teaching_favorite"
		params["teachingPurchase"] = "teaching_purchase"
		params["teachingReport"] = "teaching_report"
		params["updated"] = "updated"
		params["updatedUser"] = "updated_user"
		params["created"] = "created"
		params["createdUser"] = "created_user"
		
        return params
	}
}
