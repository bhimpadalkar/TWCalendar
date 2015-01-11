
import Foundation

public extension NSDate {
    
    public class func dateFor(day: NSInteger, month: NSInteger, year: NSInteger) -> NSDate {
        let gregorian = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        var components = NSDateComponents()
        components.day = day
        components.month = month
        components.year = year
        return gregorian!.dateFromComponents(components)!
    }
    
    func componentsForMonthDayAndYear() -> NSDateComponents {
        return NSCalendar.currentCalendar().components(.YearCalendarUnit | .MonthCalendarUnit | .DayCalendarUnit, fromDate: self)
    }
    
    func offsetDay(offset: NSInteger) -> NSDate {
        let gregorian = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        var offsetComponents = NSDateComponents()
        offsetComponents.day = offset
        let date: NSDate = gregorian!.dateByAddingComponents(offsetComponents, toDate: self, options: .MatchStrictly)!
        return date
    }
    
    func numberOfDaysInMonth() -> NSInteger {
        return NSCalendar.currentCalendar().rangeOfUnit(NSCalendarUnit.DayCalendarUnit, inUnit: NSCalendarUnit.MonthCalendarUnit, forDate: self).length
    }
    
    func day() -> NSInteger {
        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let components = calendar?.components(.DayCalendarUnit, fromDate: self)
        return components!.day
    }
    
    func weekday() -> NSInteger {
        return NSCalendar.currentCalendar().ordinalityOfUnit(.DayCalendarUnit, inUnit: .WeekCalendarUnit, forDate: self)
    }
    
    func firstDateOfMonth() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let currentDateComponents = calendar.components(.YearCalendarUnit | .MonthCalendarUnit, fromDate: self)
        let startOfMonth = calendar.dateFromComponents(currentDateComponents)!
        
        return startOfMonth
    }
    
    func firstDateOfPreviousMonth() -> NSDate {
        let components = NSDateComponents()
        components.month = -1
        return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: self, options: nil)!.firstDateOfMonth()
    }
    
    func firstDateOfNextMonth() -> NSDate {
        let components = NSDateComponents()
        components.month = 1
        return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: self, options: nil)!.firstDateOfMonth()
    }
    
    func fallsAfter(otherDate: NSDate) -> Bool{
        return comparisonResult(self, otherDate: otherDate) == NSComparisonResult.OrderedDescending
    }
    
    func fallsBefore(otherDate: NSDate) -> Bool{
        return comparisonResult(self, otherDate: otherDate) == NSComparisonResult.OrderedAscending
    }
    
    func fallsOnOrAfter(otherDate: NSDate) -> Bool{
        return comparisonResult(self, otherDate: otherDate) != NSComparisonResult.OrderedAscending
    }
    
    func fallsOnOrBefore(otherDate: NSDate) -> Bool{
        return comparisonResult(self, otherDate: otherDate) != NSComparisonResult.OrderedDescending
    }
    
    func isSameDayAs(otherDate: NSDate) -> Bool{
        return comparisonResult(self, otherDate: otherDate) == NSComparisonResult.OrderedSame
    }
    
    private func comparisonResult(date: NSDate, otherDate: NSDate) -> NSComparisonResult{
        let calendar = NSCalendar.currentCalendar()
        let currentDateComps = componentsForMonthDayAndYear()
        let testDateComps = calendar.components(.MonthCalendarUnit | .DayCalendarUnit | .YearCalendarUnit, fromDate: otherDate)
        
        let normalizedCurrentDate = calendar.dateFromComponents(currentDateComps)!
        let normalizedTestDate = calendar.dateFromComponents(testDateComps)
        
        return normalizedCurrentDate.compare(normalizedTestDate!)
    }
    
}