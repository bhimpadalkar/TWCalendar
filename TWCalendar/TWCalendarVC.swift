
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

public class TWCalendarVC: UIViewController, TWCalendarMessageDelegate {

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
        
        validator!.getInitialValidation()
    }
    
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    @IBAction func showNextMonthTapped(sender: AnyObject) {
        navigateToMonth(.Next)
    }
    
    @IBAction func showPreviousMonthTapped(sender: AnyObject) {
        navigateToMonth(.Previous)
    }
    
    @IBAction func applyTapped(sender: AnyObject) {
//        startDate = monthViewContainer.monthView?.getSelectedDates().0
//        endDate = monthViewContainer.monthView?.getSelectedDates().1?
//        if(selectionMode == "Single") {delegate?.applySelectedDate(startDate!)}
//        else {delegate?.applySelectedDateRange(startDate!, endDate: endDate!)}
        closeTapped(sender)
    }
    
    @IBAction func closeTapped(sender: AnyObject) {
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func shouldChangeMonthTo(type: MonthType) {
        if(!monthViewContainer!.isTransitioning){navigateToMonth(type)}
    }
    
    private func navigateToMonth(month: MonthType){
    }
    
    func datesDidChange(message: String, activateApply: Bool) {
        messageIndicatorLabel?.text = message
        applyButton?.enabled = activateApply
    }
 }
