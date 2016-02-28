// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to XMPPRosterFB.swift instead.

import CoreData

public enum XMPPRosterFBAttributes: String {
    case axisx = "axisx"
    case axisy = "axisy"
    case fbid = "fbid"
    case isloginowner = "isloginowner"
    case jid = "jid"
    case unreadMessages = "unreadMessages"
}

@objc public
class _XMPPRosterFB: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "XMPPRosterFB"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _XMPPRosterFB.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var axisx: NSNumber?

    // func validateAxisx(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var axisy: NSNumber?

    // func validateAxisy(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var fbid: String?

    // func validateFbid(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var isloginowner: NSNumber?

    // func validateIsloginowner(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var jid: String?

    // func validateJid(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var unreadMessages: NSNumber?

    // func validateUnreadMessages(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    // MARK: - Relationships

}

