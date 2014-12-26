
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
    public var startDate: NSDate?
    public var endDate: NSDate?
    public var backgroundImage: UIImage?
    public var delegate: TWCalendarDelegate?
    public var selectionMode: NSString?
    private var validator: TWCalendarValidator?
    @IBOutlet weak var monthViewContainer: TWCalendarMonthContainer!
    @IBOutlet weak var monthNameLabel: UILabel!
    @IBOutlet weak var messageIndicatorLabel: UILabel!
    @IBOutlet weak var applyButton: UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.validator = getValidator()
        
        var imageView = UIImageView(frame: self.view.frame)
        imageView.image = backgroundImage?
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        let handler = isSingleDateMode() ? TWSingleDateSelectionHandler(validator: validator!) : TWRangeDateSelectionHandler(validator: validator!) as TWDateSelectionHandler
        monthViewContainer.frontMonthView?.setDateSelectionHandler(handler)
        monthViewContainer.frontMonthView?.setSelectedDates(startDate, endDate: endDate)
        
        let baseDateForViewModel = (startDate == nil) ?  NSDate() : startDate!
        calendarViewModel = TWCalendarViewModel(date: baseDateForViewModel)
        monthViewContainer.showMonthViewFor(calendarViewModel!, monthType: .Current)
        updateHeader()
        
        var panGesture = UIPanGestureRecognizer(target: monthViewContainer.frontMonthView!, action: "handleDrag:")
        self.monthViewContainer.frontMonthView!.addGestureRecognizer(panGesture)
        self.monthViewContainer.frontMonthView!.setChangeMonthDelegate(self)
        
        validator!.getInitialValidation()
    }
    
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    private func updateHeader(){
        monthNameLabel!.text = calendarViewModel!.monthAndYearString
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
        startDate = monthViewContainer.frontMonthView?.getSelectedDates().0
        endDate = monthViewContainer.frontMonthView?.getSelectedDates().1?
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
        messageIndicatorLabel.text = message
        applyButton.enabled = activateApply
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
