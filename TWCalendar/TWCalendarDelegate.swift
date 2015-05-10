import Foundation

@objc protocol TWCalendarDelegate {
    optional func didSelectDate(calendarView: TWCalendarView!, selectedDate: NSDate!)
    optional func didSelectDateRange(calendarView: TWCalendarView!, startDate: NSDate!, endDate: NSDate!)
    optional func didChangeMonth(calendarView: TWCalendarView!, monthAndYear: String!)
}