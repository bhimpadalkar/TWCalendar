
import UIKit

class TWCalendarMonthContainer: UIView {
    
    var monthView: TWCalendarMonthView?
    private let leftMargin = 17 as CGFloat
    private let rightMargin = 17 as CGFloat
    var isTransitioning = false

    override func awakeFromNib() {
        super.awakeFromNib()
        var frameForMonthView = self.frame
        frameForMonthView.origin.x = leftMargin
        frameForMonthView.origin.y = 0
        frameForMonthView.size.width = UIScreen.mainScreen().bounds.size.width - (leftMargin + rightMargin)
        monthView = TWCalendarMonthView(frame: frameForMonthView)
        self.addSubview(monthView!)
    }
    
    func showMonthViewFor(calendarViewModel: TWCalendarViewModel, monthType: MonthType){
        slide(monthType)
        updateMonthView(calendarViewModel)
    }
    
    private func updateMonthView(calendarViewModel: TWCalendarViewModel){
        monthView!.showDates(calendarViewModel.daysInSelectedMonth!, datesOfPreviousMonth: calendarViewModel.daysToDisplayInPreviousMonth!, datesOfNextMonth: calendarViewModel.daysToDisplayInNextMonth!, minAvailableDate: calendarViewModel.minDate, maxAvailableDate: calendarViewModel.maxDate)
    }
    
    private func slide(monthType: MonthType){
        isTransitioning = true
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            var frame = self.frame
            frame.origin.x = CGFloat(monthType.rawValue) * self.frame.size.width
            self.frame = frame
            }) {
                (x: Bool) -> Void in
                var frame = self.frame
                frame.origin.x = 0
                self.frame = frame
                self.isTransitioning = false
        }
    }
}
