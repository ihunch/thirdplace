// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to HangoutTime.swift instead.

import CoreData

public enum HangoutTimeAttributes: String {
    case enddate = "enddate"
    case startdate = "startdate"
    case timeconfirmed = "timeconfirmed"
    case timedescription = "timedescription"
    case updatejid = "updatejid"
    case updatetime = "updatetime"
}

public enum HangoutTimeRelationships: String {
    case hangout = "hangout"
}

@objc public
class _HangoutTime: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "HangoutTime"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _HangoutTime.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var enddate: NSDate?

    // func validateEnddate(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var startdate: NSDate?

    // func validateStartdate(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var timeconfirmed: NSNumber?

    // func validateTimeconfirmed(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var timedescription: String?

    // func validateTimedescription(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

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

