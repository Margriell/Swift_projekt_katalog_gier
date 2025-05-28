//
//  Genre+CoreDataProperties.swift
//  Projekt_katalog_gier
//
//  Created by macos on 20/05/2025.
//
//

import Foundation
import CoreData


extension Genre {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Genre> {
        return NSFetchRequest<Genre>(entityName: "Genre")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var toGame: NSSet?

}

// MARK: Generated accessors for toGame
extension Genre {

    @objc(addToGameObject:)
    @NSManaged public func addToToGame(_ value: Game)

    @objc(removeToGameObject:)
    @NSManaged public func removeFromToGame(_ value: Game)

    @objc(addToGame:)
    @NSManaged public func addToToGame(_ values: NSSet)

    @objc(removeToGame:)
    @NSManaged public func removeFromToGame(_ values: NSSet)

}

extension Genre : Identifiable {

}
