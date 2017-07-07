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

 
public class TCCategory : AWSModel {
    
    var id: NSNumber?
    var sort: NSNumber?
    var name: String?
    var status: NSNumber?
    var updated: String?
    var updatedUser: String?
    var created: String?
    var createdUser: String?
    var subCategory: [TCSubCategory]?
    
   	public override static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]!{
		var params:[AnyHashable : Any] = [:]
		params["id"] = "id"
		params["sort"] = "sort"
		params["name"] = "name"
		params["status"] = "status"
		params["updated"] = "updated"
		params["updatedUser"] = "updated_user"
		params["created"] = "created"
		params["createdUser"] = "created_user"
		params["subCategory"] = "sub_category"
		
        return params
	}
	class func subCategoryJSONTransformer() -> ValueTransformer{
		return  ValueTransformer.awsmtl_JSONArrayTransformer(withModelClass: TCSubCategory.self);
	}
}
