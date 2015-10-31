// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HangoutLocation.swift instead.

import CoreData

public enum HangoutLocationAttributes: String {
    case locationconfirm = "locationconfirm"
    case locationid = "locationid"
    case updatejid = "updatejid"
    case updatetime = "updatetime"
}

public enum HangoutLocationRelationships: String {
    case hangout = "hangout"
}

@objc public
class _HangoutLocation: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "HangoutLocation"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _HangoutLocation.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var locationconfirm: NSNumber?

    // func validateLocationconfirm(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var locationid: NSNumber?

    // func validateLocationid(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

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

