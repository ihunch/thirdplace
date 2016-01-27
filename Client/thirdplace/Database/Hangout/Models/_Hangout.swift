// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Hangout.swift instead.

import CoreData

public enum HangoutAttributes: String {
    case createUserJID = "createUserJID"
    case createtime = "createtime"
    case hangoutdescription = "hangoutdescription"
    case hangoutid = "hangoutid"
    case locationconfirmed = "locationconfirmed"
    case preferedlocation = "preferedlocation"
    case sorttime = "sorttime"
    case timeconfirmed = "timeconfirmed"
}

public enum HangoutRelationships: String {
    case location = "location"
    case message = "message"
    case time = "time"
    case user = "user"
    case version = "version"
}

@objc public
class _Hangout: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Hangout"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Hangout.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var createUserJID: String?

    // func validateCreateUserJID(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var createtime: NSDate?

    // func validateCreatetime(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var hangoutdescription: String?

    // func validateHangoutdescription(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var hangoutid: NSNumber?

    // func validateHangoutid(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var locationconfirmed: NSNumber?

    // func validateLocationconfirmed(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var preferedlocation: String?

    // func validatePreferedlocation(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var sorttime: NSDate?

    // func validateSorttime(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    @NSManaged public
    var timeconfirmed: NSNumber?

    // func validateTimeconfirmed(value: AutoreleasingUnsafeMutablePointer<AnyObject>, error: NSErrorPointer) -> Bool {}

    // MARK: - Relationships

    @NSManaged public
    var location: NSSet

    @NSManaged public
    var message: NSSet

    @NSManaged public
    var time: NSSet

    @NSManaged public
    var user: NSSet

    @NSManaged public
    var version: NSSet

}

extension _Hangout {

    func addLocation(objects: NSSet) {
        let mutable = self.location.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as! Set<NSObject>)
        self.location = mutable.copy() as! NSSet
    }

    func removeLocation(objects: NSSet) {
        let mutable = self.location.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as! Set<NSObject>)
        self.location = mutable.copy() as! NSSet
    }

    func addLocationObject(value: HangoutLocation!) {
        let mutable = self.location.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.location = mutable.copy() as! NSSet
    }

    func removeLocationObject(value: HangoutLocation!) {
        let mutable = self.location.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.location = mutable.copy() as! NSSet
    }

}

extension _Hangout {

    func addMessage(objects: NSSet) {
        let mutable = self.message.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as! Set<NSObject>)
        self.message = mutable.copy() as! NSSet
    }

    func removeMessage(objects: NSSet) {
        let mutable = self.message.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as! Set<NSObject>)
        self.message = mutable.copy() as! NSSet
    }

    func addMessageObject(value: HangoutMessage!) {
        let mutable = self.message.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.message = mutable.copy() as! NSSet
    }

    func removeMessageObject(value: HangoutMessage!) {
        let mutable = self.message.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.message = mutable.copy() as! NSSet
    }

}

extension _Hangout {

    func addTime(objects: NSSet) {
        let mutable = self.time.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as! Set<NSObject>)
        self.time = mutable.copy() as! NSSet
    }

    func removeTime(objects: NSSet) {
        let mutable = self.time.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as! Set<NSObject>)
        self.time = mutable.copy() as! NSSet
    }

    func addTimeObject(value: HangoutTime!) {
        let mutable = self.time.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.time = mutable.copy() as! NSSet
    }

    func removeTimeObject(value: HangoutTime!) {
        let mutable = self.time.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.time = mutable.copy() as! NSSet
    }

}

extension _Hangout {

    func addUser(objects: NSSet) {
        let mutable = self.user.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as! Set<NSObject>)
        self.user = mutable.copy() as! NSSet
    }

    func removeUser(objects: NSSet) {
        let mutable = self.user.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as! Set<NSObject>)
        self.user = mutable.copy() as! NSSet
    }

    func addUserObject(value: HangoutUser!) {
        let mutable = self.user.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.user = mutable.copy() as! NSSet
    }

    func removeUserObject(value: HangoutUser!) {
        let mutable = self.user.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.user = mutable.copy() as! NSSet
    }

}

extension _Hangout {

    func addVersion(objects: NSSet) {
        let mutable = self.version.mutableCopy() as! NSMutableSet
        mutable.unionSet(objects as! Set<NSObject>)
        self.version = mutable.copy() as! NSSet
    }

    func removeVersion(objects: NSSet) {
        let mutable = self.version.mutableCopy() as! NSMutableSet
        mutable.minusSet(objects as! Set<NSObject>)
        self.version = mutable.copy() as! NSSet
    }

    func addVersionObject(value: Hangoutversion!) {
        let mutable = self.version.mutableCopy() as! NSMutableSet
        mutable.addObject(value)
        self.version = mutable.copy() as! NSSet
    }

    func removeVersionObject(value: Hangoutversion!) {
        let mutable = self.version.mutableCopy() as! NSMutableSet
        mutable.removeObject(value)
        self.version = mutable.copy() as! NSSet
    }

}

