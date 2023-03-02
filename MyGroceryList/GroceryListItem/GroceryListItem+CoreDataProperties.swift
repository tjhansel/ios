//
//  GroceryListItem+CoreDataProperties.swift
//  MyGroceryList
//
//  Created by Jordan Hansen on 3/2/23.
//
//

import Foundation
import CoreData


extension GroceryListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroceryListItem> {
        return NSFetchRequest<GroceryListItem>(entityName: "GroceryListItem")
    }

    @NSManaged public var itemName: String?
    @NSManaged public var addedAt: Date?
    @NSManaged public var completed: Bool
    @NSManaged public var storeName: String?

}

extension GroceryListItem : Identifiable {

}
