
import Foundation

class TWCalendarViewModel {
   
    private var formatter : NSDateFormatter
    var baseDate: NSDate
    var minDate, maxDate: NSDate?
    var daysInSelectedMonth, daysToDisplayInNextMonth, daysToDisplayInPreviousMonth : NSArray?
    var monthAndYearString = ""
    
    init(baseDate : NSDate, minDate: NSDate?, maxDate: NSDate?){
        self.baseDate = baseDate
        self.minDate = minDate
        self.maxDate = maxDate
        formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        setupViewModelFor(baseDate)
    }
    
    func moveToNextMonth(){
        setupViewModelFor(baseDate.firstDateOfNextMonth())
    }
    
    func moveToPreviousMonth(){
        setupViewModelFor(baseDate.firstDateOfPreviousMonth())
    }
    
    private func setupViewModelFor(date: NSDate){
        baseDate = date.firstDateOfMonth()
        calculateDaysToShow()
        monthAndYearString = formatter.stringFromDate(date)
    }
    
    private func calculateDaysToShow() {
        daysInSelectedMonth = calculateDaysInSelectedMonth()
        daysToDisplayInPreviousMonth = calculateDaysToDisplayInPreviousMonth()
        daysToDisplayInNextMonth = calculateDaysToDisplayInNextMonth()
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
        let numOfDays = numberOfDaysToShowInPreviousMonth()
        let components = beginningOfPreviousMonth.componentsForMonthDayAndYear()
        for i in n - (numOfDays - 1)...n{
            days.addObject(NSDate.dateFor(i, month: components.month, year: components.year))
        }
        return days;
    }
    
    private func calculateDaysToDisplayInNextMonth() -> NSArray {
        var days = NSMutableArray()
        
        let components = baseDate.firstDateOfNextMonth().componentsForMonthDayAndYear()
        let numOfDays = numberOfDaysToDisplayInNextMonth()
        
        for i in 1...numOfDays{
            days.addObject(NSDate.dateFor(i, month: components.month, year: components.year))
        }
        return days;
    }
    
    private func numberOfDaysToShowInPreviousMonth() -> NSInteger{
        var num = baseDate.weekday() - 1;
        if (num == 0){
            num = 7;
        }
        return num;
    }
    
    private func numberOfDaysToDisplayInNextMonth() -> NSInteger{
        let components = baseDate.componentsForMonthDayAndYear()
        components.day = baseDate.numberOfDaysInMonth()
        let lastDayOfTheMonth = NSCalendar.currentCalendar().dateFromComponents(components)
        let maxNumOfDays = (daysInSelectedMonth!.count + daysToDisplayInPreviousMonth!.count) > 35 ? 7 : 14
        var num = maxNumOfDays - lastDayOfTheMonth!.weekday()
        if (num == 0){
            num = maxNumOfDays;
        }
        return num;
    }

}
