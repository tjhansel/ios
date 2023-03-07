//
//  Store+CoreDataProperties.swift
//  MyGroceryList
//
//  Created by Jordan Hansen on 3/3/23.
//
//

import Foundation
import CoreData


extension Store {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Store> {
        return NSFetchRequest<Store>(entityName: "Store")
    }

    @NSManaged public var name: String?
    @NSManaged public var listItems: NSSet?

}

// MARK: Generated accessors for listItems
extension Store {

    @objc(addListItemsObject:)
    @NSManaged public func addToListItems(_ value: GroceryListItem)

    @objc(removeListItemsObject:)
    @NSManaged public func removeFromListItems(_ value: GroceryListItem)

    @objc(addListItems:)
    @NSManaged public func addToListItems(_ values: NSSet)

    @objc(removeListItems:)
    @NSManaged public func removeFromListItems(_ values: NSSet)

}

extension Store : Identifiable {

}
