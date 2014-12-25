
import UIKit

@objc public class TWCalendarHelper: NSObject {
    
    public class func calendarViewController() -> TWCalendarVC{
        let storyBoard = UIStoryboard(name: "Calendar", bundle: nil)
        var vc = storyBoard.instantiateInitialViewController() as TWCalendarVC
        return vc
    }
   
}
