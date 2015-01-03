
import UIKit

public class TWCalendarMonthContainer: UIView, TWChangeMonthDelegate {
    
    private var calendarViewModel: TWCalendarViewModel!
    var selectionMode: NSString!
    var monthView: TWCalendarMonthView!
    private let leftMargin = 17 as CGFloat
    private let rightMargin = 17 as CGFloat
    var isTransitioning = false
    private var startDate: NSDate?
    private var endDate: NSDate?

    override public func awakeFromNib() {
        super.awakeFromNib()
        var frameForMonthView = self.frame
        frameForMonthView.origin.x = leftMargin
        frameForMonthView.origin.y = 0
        frameForMonthView.size.width = UIScreen.mainScreen().bounds.size.width - (leftMargin + rightMargin)
        monthView = TWCalendarMonthView(frame: frameForMonthView)
        self.addSubview(monthView)
        
        var panGesture = UIPanGestureRecognizer(target: monthView!, action: "handleDrag:")
        self.monthView.addGestureRecognizer(panGesture)
        self.monthView.setChangeMonthDelegate(self)
        initializeCalendar(nil, endDate: nil, minDate: nil, maxDate: nil, selectionMode: "Single")
        showMonthViewFor(.Current)
    }
    
    public override init(frame:CGRect) {
        super.init(frame:frame)
        var frameForMonthView = self.frame
        frameForMonthView.origin.x = leftMargin
        frameForMonthView.origin.y = 0
        frameForMonthView.size.width = UIScreen.mainScreen().bounds.size.width - (leftMargin + rightMargin)
        monthView = TWCalendarMonthView(frame: frameForMonthView)
        self.addSubview(monthView)
        
        var panGesture = UIPanGestureRecognizer(target: monthView!, action: "handleDrag:")
        self.monthView.addGestureRecognizer(panGesture)
        self.monthView.setChangeMonthDelegate(self)
        initializeCalendar(nil, endDate: nil, minDate: nil, maxDate: nil, selectionMode: "Single")
        showMonthViewFor(.Current)
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func initializeCalendar(startDate: NSDate?, endDate: NSDate?, minDate: NSDate?, maxDate: NSDate?, selectionMode: NSString) {
        self.selectionMode = selectionMode
        let handler = isSingleDateMode() ? TWSingleDateSelectionHandler() : TWRangeDateSelectionHandler() as TWDateSelectionHandler
        monthView.setDateSelectionHandler(handler)
        
        self.startDate = startDate
        self.endDate = endDate
        monthView.setSelectedDates(startDate, endDate: endDate)
        
        let baseDateForViewModel = (startDate == nil) ?  NSDate() : startDate!
        calendarViewModel = TWCalendarViewModel(baseDate: baseDateForViewModel, minDate: minDate, maxDate: maxDate)
    }
    
    func changeMonthTo(monthType: MonthType) {
        if(isTransitioning) {return}
        showMonthViewFor(monthType)
//        updateHeader()
    }
    
    func showMonthViewFor(monthType: MonthType){
        slide(monthType)
        if(monthType == .Next){
            calendarViewModel.moveToNextMonth()
        } else if (monthType == .Previous){
            calendarViewModel.moveToPreviousMonth()
        }
        updateMonthView()
    }
    
    private func updateMonthView(){
        monthView!.showDates(calendarViewModel!.daysInSelectedMonth!, datesOfPreviousMonth: calendarViewModel.daysToDisplayInPreviousMonth!,
            datesOfNextMonth: calendarViewModel.daysToDisplayInNextMonth!,
            minAvailableDate: calendarViewModel.minDate,
            maxAvailableDate: calendarViewModel.maxDate)
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
    
    private func isSingleDateMode() ->Bool {
        return selectionMode.isEqualToString("Single")
    }
}
