// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HangoutUser.swift instead.

import CoreData

public enum HangoutUserAttributes: String {
    case goingstatus = "goingstatus"
    case jidstr = "jidstr"
    case username = "username"
}

public enum HangoutUserRelationships: String {
    case hangout = "hangout"
}

@objc public
class _HangoutUser: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "HangoutUser"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _HangoutUser.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var goingstatus: String?

    // func validateGoingstatus(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var jidstr: String?

    // func validateJidstr(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var username: String?

    // func validateUsername(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    // MARK: - Relationships

    @NSManaged public
    var hangout: Hangout?

    // func validateHangout(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

}

