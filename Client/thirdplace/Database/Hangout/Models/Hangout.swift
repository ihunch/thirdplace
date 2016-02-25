
@objc(Hangout)
public class Hangout: _Hangout {

	// Custom logic goes here.
    func getLatestMessage() -> HangoutMessage?
    {
        let filter = NSPredicate(format: "self.updatetime == %@.@max.updatetime",self.message)
        //Due to the time is based on min, so there will be chance to get messages at the same mins.
        //If return 1, that's time, otherwise, filter by messageid.
        let hangoutmessages = self.message.filteredSetUsingPredicate(filter) as? Set<HangoutMessage>
        //print(hangoutmessages)
        //print(hangoutmessages?.count)
        if (hangoutmessages?.count > 1)
        {
            let sortmessages = hangoutmessages?.sort({ $0.0.messageid?.integerValue > $0.1.messageid?.integerValue})
            return sortmessages?.first
        }
        else
        {
            return hangoutmessages?.first
        }
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
            
    func getLatestLocation() -> HangoutLocation?
    {
        let filter = NSPredicate(format: "self.updatetime == %@.@max.updatetime",self.location)
        let mylocation = self.location.filteredSetUsingPredicate(filter).first as? HangoutLocation
        return mylocation
    }
}
