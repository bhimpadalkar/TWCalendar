
import UIKit

enum MonthType: Int {
    case Next = -1
    case Current = 0
    case Previous = 1
}

public protocol TWCalendarDelegate{
    func applySelectedDate(startDate: NSDate)
    func applySelectedDateRange(startDate: NSDate, endDate: NSDate)
}

public class TWCalendarVC: UIViewController, TWChangeMonthDelegate, TWCalendarMessageDelegate {

    private var calendarViewModel: TWCalendarViewModel?;
    private var startDate: NSDate?
    private var endDate: NSDate?
    private var selectionMode: NSString?
    private var validator: TWCalendarValidator?
    public var backgroundImage: UIImage?
    public var delegate: TWCalendarDelegate?
    @IBOutlet weak var monthViewContainer: TWCalendarMonthContainer!
    @IBOutlet weak var monthNameLabel: UILabel?
    @IBOutlet weak var messageIndicatorLabel: UILabel?
    @IBOutlet weak var applyButton: UIButton?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        var imageView = UIImageView(frame: self.view.frame)
        imageView.image = backgroundImage?
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        var panGesture = UIPanGestureRecognizer(target: monthViewContainer.monthView!, action: "handleDrag:")
        self.monthViewContainer.monthView!.addGestureRecognizer(panGesture)
        self.monthViewContainer.monthView!.setChangeMonthDelegate(self)
        
        let handler = isSingleDateMode() ? TWSingleDateSelectionHandler(validator: validator!) : TWRangeDateSelectionHandler(validator: validator!) as TWDateSelectionHandler
        monthViewContainer.monthView?.setDateSelectionHandler(handler)
        monthViewContainer.monthView?.setSelectedDates(startDate, endDate: endDate)
        
        monthViewContainer.showMonthViewFor(calendarViewModel!, monthType: .Current)
        updateHeader()
        
        validator!.getInitialValidation()
    }
    
    public func initializeCalendar(selectionMode: NSString, startDate: NSDate?, endDate: NSDate?, minDate: NSDate?, maxDate: NSDate?) {
        self.selectionMode = selectionMode
        self.startDate = startDate
        self.endDate = endDate
        self.validator = getValidator()
        
        let baseDateForViewModel = (startDate == nil) ?  NSDate() : startDate!
        calendarViewModel = TWCalendarViewModel(baseDate: baseDateForViewModel, minDate: minDate, maxDate: maxDate)
    }
    
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    private func updateHeader(){
        monthNameLabel?.text = calendarViewModel!.monthAndYearString
    }
    
    private func swipe(recognizer : UISwipeGestureRecognizer){
        if(recognizer.direction == .Left){
            navigateToMonth(.Next)
        } else if (recognizer.direction == .Right) {
            navigateToMonth(.Previous)
        }
    }
    
    @IBAction func showNextMonthTapped(sender: AnyObject) {
        navigateToMonth(.Next)
    }
    
    @IBAction func showPreviousMonthTapped(sender: AnyObject) {
        navigateToMonth(.Previous)
    }
    
    @IBAction func applyTapped(sender: AnyObject) {
        startDate = monthViewContainer.monthView?.getSelectedDates().0
        endDate = monthViewContainer.monthView?.getSelectedDates().1?
        if(selectionMode == "Single") {delegate?.applySelectedDate(startDate!)}
        else {delegate?.applySelectedDateRange(startDate!, endDate: endDate!)}
        closeTapped(sender)
    }
    
    @IBAction func closeTapped(sender: AnyObject) {
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func shouldChangeMonthTo(type: MonthType) {
        if(!monthViewContainer!.isTransitioning){navigateToMonth(type)}
    }
    
    private func navigateToMonth(month: MonthType){
        if(month == .Next){
            calendarViewModel!.moveToNextMonth()
        } else if (month == .Previous){
            calendarViewModel!.moveToPreviousMonth()
        }
        monthViewContainer.showMonthViewFor(calendarViewModel!, monthType: month)
        updateHeader()
    }
    
    func datesDidChange(message: String, activateApply: Bool) {
        messageIndicatorLabel?.text = message
        applyButton?.enabled = activateApply
    }
    
    private func getValidator() -> TWCalendarValidator{
        let validator = TWCalendarValidator(startDate: startDate?, endDate: endDate?, isRangeMode:!isSingleDateMode())
        validator.delegate = self
        return validator
    }
    
    private func isSingleDateMode() ->Bool {
        return selectionMode!.isEqualToString("Single")
    }
 }
