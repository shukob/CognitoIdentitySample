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

 
public class TCTutor : AWSModel {
    
    var id: NSNumber?
    var userId: NSNumber?
    var nickName: String?
    var userIcon: String?
    var backImage: String?
    var title: String?
    var _description: String?
    var updated: String?
    var updatedUser: String?
    var created: String?
    var createdUser: String?
    
   	public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]!{
		var params:[AnyHashable : Any] = [:]
		params["id"] = "id"
		params["userId"] = "user_id"
		params["nickName"] = "nick_name"
		params["userIcon"] = "user_icon"
		params["backImage"] = "back_image"
		params["title"] = "title"
		params["_description"] = "description"
		params["updated"] = "updated"
		params["updatedUser"] = "updated_user"
		params["created"] = "created"
		params["createdUser"] = "created_user"
		
        return params
	}
}
