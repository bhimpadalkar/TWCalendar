
import UIKit

public class TWCalendarView: UIView, TWChangeMonthDelegate {
    
    private var calendarViewModel: TWCalendarViewModel!
    var selectionMode: NSString!
    var monthView: TWCalendarMonthView!
    private let leftMargin = 0 as CGFloat
    private let rightMargin = 0 as CGFloat
    var isTransitioning = false
    private var startDate: NSDate?
    private var endDate: NSDate?
    
    
    //MARK: - Lifecycle methods
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        initializeCalendar(nil, endDate: nil, minDate: nil, maxDate: nil, selectionMode: "Single")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeCalendar(nil, endDate: nil, minDate: nil, maxDate: nil, selectionMode: "Single")
    }
    
    public override func drawRect(rect: CGRect) {
        addMonthView()
    }
    
    //MARK: - Public APIs
    
    public func initializeCalendar(startDate: NSDate?, endDate: NSDate?, minDate: NSDate?, maxDate: NSDate?, selectionMode: NSString) {
        self.selectionMode = selectionMode
        
        self.startDate = startDate
        self.endDate = endDate
        
        let baseDateForViewModel = (startDate == nil) ?  NSDate() : startDate!
        calendarViewModel = TWCalendarViewModel(baseDate: baseDateForViewModel, minDate: minDate, maxDate: maxDate)
    }
    
    public func showNextMonth() {
        showMonthViewFor(.Next)
    }
    
    public func showPreviousMonth() {
        showMonthViewFor(.Previous)
    }
    
    public func getSelectedDate() -> NSDate? {
        return monthView.getSelectedDates().0
    }
    
    public func getSelectedDateRange() -> (NSDate?, NSDate?) {
        return monthView.getSelectedDates()
    }
    
    //MARK: - Delegate Methods
    
    func changeMonthTo(monthType: MonthType) {
        if(isTransitioning) {return}
        showMonthViewFor(monthType)
    }
    
    //MARK: - Private Methods
    
    private func addMonthView() {
        var frameForMonthView = self.bounds
        frameForMonthView.origin.x = leftMargin
        frameForMonthView.size.width -= (leftMargin + rightMargin)
        monthView = TWCalendarMonthView(frame: frameForMonthView)
        self.addSubview(monthView)
        
        var panGesture = UIPanGestureRecognizer(target: monthView!, action: "handleDrag:")
        self.monthView.addGestureRecognizer(panGesture)
        
        let handler = isSingleDateMode() ? TWSingleDateSelectionHandler() : TWRangeDateSelectionHandler() as TWDateSelectionHandler
        monthView.setDateSelectionHandler(handler, delegate: self)
        monthView.setSelectedDates(startDate, endDate: endDate)
        showMonthViewFor(.Current)
    }
    
    private func showMonthViewFor(monthType: MonthType){
        if(monthType == .Next){
            calendarViewModel.moveToNextMonth()
        } else if (monthType == .Previous){
            calendarViewModel.moveToPreviousMonth()
        }
        slide(monthType)
    }
    
    private func updateMonthView(){
        monthView?.showDates(calendarViewModel!.daysInSelectedMonth!, datesOfPreviousMonth: calendarViewModel.daysToDisplayInPreviousMonth!,
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
                self.updateMonthView()
        }
    }
    
    private func isSingleDateMode() ->Bool {
        return selectionMode.isEqualToString("Single")
    }
}
