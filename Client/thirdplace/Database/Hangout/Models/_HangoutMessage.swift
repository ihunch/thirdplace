// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HangoutMessage.swift instead.

import CoreData

public enum HangoutMessageAttributes: String {
    case content = "content"
    case messageid = "messageid"
    case updatejid = "updatejid"
    case updatetime = "updatetime"
}

public enum HangoutMessageRelationships: String {
    case hangout = "hangout"
}

@objc public
class _HangoutMessage: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "HangoutMessage"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _HangoutMessage.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var content: String?

    // func validateContent(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var messageid: NSNumber?

    // func validateMessageid(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var updatejid: String?

    // func validateUpdatejid(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var updatetime: NSDate?

    // func validateUpdatetime(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    // MARK: - Relationships

    @NSManaged public
    var hangout: Hangout?

    // func validateHangout(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

}

