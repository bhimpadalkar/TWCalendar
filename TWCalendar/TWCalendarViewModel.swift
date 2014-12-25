
import Foundation

class TWCalendarViewModel {
   
    private var monthAndYearFormatter : NSDateFormatter
    var baseDate: NSDate
    var daysInSelectedMonth, daysToDisplayInNextMonth, daysToDisplayInPreviousMonth : NSArray?
    var monthAndYearString = ""
    
    init(date : NSDate){
        baseDate = date
        monthAndYearFormatter = NSDateFormatter()
        monthAndYearFormatter.dateFormat = "LLLL yyyy"
        moveToMonthForDate(date)
    }
    
    private func moveToMonthForDate(date: NSDate){
        baseDate = date.firstDateOfMonth()
        recalculateVisibleDays()
        monthAndYearString = monthAndYearFormatter.stringFromDate(date)
    }
    
    private func recalculateVisibleDays() {
        daysInSelectedMonth = calculateDaysInSelectedMonth()
        daysToDisplayInPreviousMonth = calculateDaysToDisplayInPreviousMonth()
        daysToDisplayInNextMonth = calculateDaysToDisplayInNextMonth()
        let from = (daysToDisplayInPreviousMonth!.count > 0 ? daysToDisplayInPreviousMonth!.firstObject : daysInSelectedMonth!.firstObject) as NSDate
        let to = (daysToDisplayInNextMonth?.count > 0 ? daysToDisplayInNextMonth!.lastObject : daysInSelectedMonth!.lastObject) as NSDate
    }
    
    private func calculateDaysInSelectedMonth() -> NSArray {
       var days = NSMutableArray()
        
        var numDays = baseDate.numberOfDaysInMonth()
        var components = baseDate.componentsForMonthDayAndYear()
        for i in 1...numDays {
            days.addObject(NSDate.dateFor(i, month: components.month, year: components.year))
        }
        return days;
    }
    
    private func calculateDaysToDisplayInPreviousMonth() -> NSArray{
        var days = NSMutableArray()
        
        let beginningOfPreviousMonth = baseDate.firstDateOfPreviousMonth()
        let n = beginningOfPreviousMonth.numberOfDaysInMonth()
        let numPartialDays = numberOfDaysInPreviousPartialWeek()
        let components = beginningOfPreviousMonth.componentsForMonthDayAndYear()
        for i in n - (numPartialDays - 1)...n{
            days.addObject(NSDate.dateFor(i, month: components.month, year: components.year))
        }
        return days;
    }
    
    private func calculateDaysToDisplayInNextMonth() -> NSArray {
        var days = NSMutableArray()
        
        let components = baseDate.firstDateOfNextMonth().componentsForMonthDayAndYear()
        let numPartialDays = numberOfDaysInFollowingPartialWeek()
        
        for i in 1...numPartialDays{
            days.addObject(NSDate.dateFor(i, month: components.month, year: components.year))
        }
        return days;
    }
    
    private func numberOfDaysInPreviousPartialWeek() -> NSInteger{
        var num = baseDate.weekday() - 1;
        if (num == 0){
            num = 7;
        }
        return num;
    }
    
    private func numberOfDaysInFollowingPartialWeek() -> NSInteger{
        let c = baseDate.componentsForMonthDayAndYear()
        c.day = baseDate.numberOfDaysInMonth()
        let lastDayOfTheMonth = NSCalendar.currentCalendar().dateFromComponents(c)
        let maxNumOfDays = (daysInSelectedMonth!.count + daysToDisplayInPreviousMonth!.count) > 35 ? 7 : 14
        var num = maxNumOfDays - lastDayOfTheMonth!.weekday()
        if (num == 0){
            num = maxNumOfDays;
        }
        return num;
    }
    
    func moveToNextMonth(){
        moveToMonthForDate(baseDate.firstDateOfNextMonth())
    }

    func moveToPreviousMonth(){
        moveToMonthForDate(baseDate.firstDateOfPreviousMonth())
    }


}
