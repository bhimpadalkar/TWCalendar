
import UIKit

protocol TWCalendarMessageDelegate{
    func datesDidChange(message:String, activateApply:Bool)
}

class TWCalendarValidator {
    private var outboundDate: NSDate?
    private var inboundDate: NSDate?
    private var message: String
    private var isRoundTrip: Bool
    var delegate: TWCalendarMessageDelegate?
    
    let kDefaultMessage: String = "Select a departure date"
    let kReturnMessage: String = "Select a return date"
    
    init(outboundDate: NSDate?, inboundDate: NSDate?, isRoundTrip: Bool){
        self.outboundDate = outboundDate
        self.inboundDate = inboundDate
        self.message = kDefaultMessage
        self.isRoundTrip = isRoundTrip
        updateMessage()
    }
    
    func updateDates(outboundDate:NSDate?, inboundDate:NSDate?){
        self.outboundDate = outboundDate?
        self.inboundDate = inboundDate?
        updateMessage()
        delegate?.datesDidChange(message, activateApply: isValidSelection())
    }
    
    func getInitialValidation(){
        delegate?.datesDidChange(message, activateApply: isValidSelection())
    }
    
    private func updateMessage(){
        var monthAndYearFormatter = NSDateFormatter()
        monthAndYearFormatter.dateFormat = "MM/dd"
        if !isRoundTrip{
            message = (outboundDate == nil) ? kDefaultMessage : monthAndYearFormatter.stringFromDate(outboundDate!)
        }else{
            if let date = inboundDate? {
                let outboundMessage = monthAndYearFormatter.stringFromDate(outboundDate!) + " - "
                message = outboundMessage + monthAndYearFormatter.stringFromDate(date)
            } else if let date = outboundDate? {
                message = kReturnMessage
            }
        }
    }
    
    private func isValidSelection() -> Bool{
        if !isRoundTrip{
            if let selectDate = outboundDate? {
                return true
            }
        } else{
            if let selectedDate = inboundDate? {
                return true
            }
        }
        return false
    }

}
