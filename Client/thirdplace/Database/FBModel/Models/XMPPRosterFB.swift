@objc(XMPPRosterFB)
public class XMPPRosterFB: _XMPPRosterFB {

	// Custom logic goes here.
    func updateUnReadMessage(messages:Int)
    {
        self.unreadMessages = NSNumber(integer: messages)
    }
}
