
import UIKit

class TWCalendarMonthContainer: UIView {
    
    var frontMonthView: TWCalendarMonthView?
    private let leftMargin = 17 as CGFloat
    private let rightMargin = 17 as CGFloat
    var isTransitioning = false

    override func awakeFromNib() {
        var frameForMonthView = self.frame
        frameForMonthView.origin.x = leftMargin
        frameForMonthView.origin.y = 0
        frameForMonthView.size.width -= leftMargin + rightMargin
        frontMonthView = TWCalendarMonthView(frame: frameForMonthView)
        self.addSubview(frontMonthView!)
    }
    
    func showMonthViewFor(calendarViewModel: TWCalendarViewModel, monthType: MonthType){
        slide(monthType)
        updateMonthView(calendarViewModel)
    }
    
    private func updateMonthView(calendarViewModel: TWCalendarViewModel){
        let minAvailableDate = NSDate()
        frontMonthView!.showDates(calendarViewModel.daysInSelectedMonth!, leadingAdjacentDates: calendarViewModel.daysToDisplayInPreviousMonth!, trailingAdjacentDates: calendarViewModel.daysToDisplayInNextMonth!, minAvailableDate: minAvailableDate, maxAvailableDate: minAvailableDate.offsetDay(333))
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
