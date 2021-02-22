//
//  ManagedTodoItem+CoreDataProperties.swift
//  TodoList_CoreData
//
//  Created by Kazunobu Someya on 2021-02-22.
//
//

import Foundation
import CoreData


extension ManagedTodoItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedTodoItem> {
        return NSFetchRequest<ManagedTodoItem>(entityName: "ManagedTodoItem")
    }

    @NSManaged public var title: String?
    @NSManaged public var todoDescription: String?
    @NSManaged public var priorityNumber: Int16
    @NSManaged public var isCompleted: Bool

}

extension ManagedTodoItem : Identifiable {

}
