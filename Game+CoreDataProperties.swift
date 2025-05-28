//
//  Game+CoreDataProperties.swift
//  Projekt_katalog_gier
//
//  Created by macos on 20/05/2025.
//
//

import Foundation
import CoreData


extension Game {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var publisher: String?
    @NSManaged public var descriptionText: String?
    @NSManaged public var coverImage: Data?
    @NSManaged public var coverImageName: String?
    @NSManaged public var playTime: Int16
    @NSManaged public var rating: Double
    @NSManaged public var isCompleted: Bool
    @NSManaged public var isFavorite: Bool
    @NSManaged public var isCustom: Bool
    @NSManaged public var toGenre: NSSet?

}

// MARK: Generated accessors for toGenre
extension Game {

    @objc(addToGenreObject:)
    @NSManaged public func addToToGenre(_ value: Genre)

    @objc(removeToGenreObject:)
    @NSManaged public func removeFromToGenre(_ value: Genre)

    @objc(addToGenre:)
    @NSManaged public func addToToGenre(_ values: NSSet)

    @objc(removeToGenre:)
    @NSManaged public func removeFromToGenre(_ values: NSSet)

}

extension Game : Identifiable {

}
