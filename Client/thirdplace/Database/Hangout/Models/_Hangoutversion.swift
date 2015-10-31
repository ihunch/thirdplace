// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Hangoutversion.swift instead.

import CoreData

public enum HangoutversionAttributes: String {
    case versionid = "versionid"
    case versiontime = "versiontime"
}

public enum HangoutversionRelationships: String {
    case hangout = "hangout"
}

@objc public
class _Hangoutversion: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Hangoutversion"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Hangoutversion.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var versionid: NSNumber?

    // func validateVersionid(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var versiontime: NSDate?

    // func validateVersiontime(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    // MARK: - Relationships

    @NSManaged public
    var hangout: Hangout?

    // func validateHangout(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

}

