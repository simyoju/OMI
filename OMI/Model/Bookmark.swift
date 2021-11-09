//
//  Bookmark.swift
//  OMI
//
//  Created by simyo on 2021/10/25.
//

import Foundation
import RealmSwift

class Bookmarks: Object {
//     @objc dynamic var id:Int = 0
    @objc dynamic var location:String = ""
    @objc dynamic var icon_name:String = ""
    @objc dynamic var cur_temp:String = ""
    @objc dynamic var max_temp:String = ""
    @objc dynamic var min_temp:String = ""
    
    override static func primaryKey() -> String? {
        return "location"
    }
}
