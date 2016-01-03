
@objc(Hangout)
public class Hangout: _Hangout {

	// Custom logic goes here.
    func getLatestMessage() -> HangoutMessage?
    {
        let filter = NSPredicate(format: "self.updatetime == %@.@max.updatetime",self.message)
        let hangoutmessage = self.message.filteredSetUsingPredicate(filter).first as? HangoutMessage
        return hangoutmessage
    }
    
    func getUser(sender:XMPPJID) ->  HangoutUser?
    {
        let filter = NSPredicate(format: "jidstr == %@", sender.bare())
        let user = self.user.filteredSetUsingPredicate(filter).first as? HangoutUser
        return user
    }
  
    func getOtherUser(sender:XMPPJID) ->  HangoutUser?
    {
        let filter = NSPredicate(format: "jidstr != %@", sender.bare())
        let user = self.user.filteredSetUsingPredicate(filter).first as? HangoutUser
        return user
    }
    
    func getLatestTime() -> HangoutTime?
    {
        let filter = NSPredicate(format: "self.updatetime == %@.@max.updatetime",self.time)
        let hangoutTime = self.time.filteredSetUsingPredicate(filter).first as? HangoutTime
        return hangoutTime
    }
        
    func getInitTime() -> HangoutTime?
    {
        let filter = NSPredicate(format: "self.updatetime == %@.@min.updatetime",self.time)
        let hangoutTime = self.time.filteredSetUsingPredicate(filter).first as? HangoutTime
        return hangoutTime
    }
    
    func getLatestLocation() -> HangoutLocation?
    {
        let filter = NSPredicate(format: "self.updatetime == %@.@max.updatetime",self.location)
        let mylocation = self.location.filteredSetUsingPredicate(filter).first as? HangoutLocation
        return mylocation
    }
}
