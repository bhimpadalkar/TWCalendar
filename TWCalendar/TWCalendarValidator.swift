
import UIKit

protocol TWCalendarMessageDelegate{
    func datesDidChange(message:String, activateApply:Bool)
}

class TWCalendarValidator {
    private var startDate: NSDate?
    private var endDate: NSDate?
    private var message: String
    private var isRangeMode: Bool
    var delegate: TWCalendarMessageDelegate?
    
    let kDefaultMessageForSingleMode: String = "Select a date"
    let kDefaultMessageForRangeMode: String = "Select start date"
    let kMessageToSelectEndDate: String = "Select end date"
    
    init(startDate: NSDate?, endDate: NSDate?, isRangeMode: Bool){
        self.startDate = startDate
        self.endDate = endDate
        self.message = kDefaultMessageForSingleMode
        self.isRangeMode = isRangeMode
        updateMessage()
    }
    
    func updateDates(startDate:NSDate?, endDate:NSDate?){
        self.startDate = startDate?
        self.endDate = endDate?
        updateMessage()
        delegate?.datesDidChange(message, activateApply: isValidSelection())
    }
    
    func getInitialValidation(){
        delegate?.datesDidChange(message, activateApply: isValidSelection())
    }
    
    private func updateMessage(){
        var monthAndYearFormatter = NSDateFormatter()
        monthAndYearFormatter.dateFormat = "MM/dd"
        if !isRangeMode{
            message = (startDate == nil) ? kDefaultMessageForSingleMode : monthAndYearFormatter.stringFromDate(startDate!)
        }else{
            if let date = endDate? {
                message = monthAndYearFormatter.stringFromDate(startDate!) + " - " + monthAndYearFormatter.stringFromDate(date)
            } else if let date = startDate? {
                message = kDefaultMessageForRangeMode
            }
        }
    }
    
    private func isValidSelection() -> Bool{
        if !isRangeMode{
            if let selectDate = startDate? {
                return true
            }
        } else{
            if let selectedDate = endDate? {
                return true
            }
        }
        return false
    }

}
