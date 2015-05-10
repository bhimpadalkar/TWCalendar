
import UIKit

protocol TWChangeMonthDelegate{
    func changeMonthTo(type: MonthType)
}

protocol TWCalendarDateDelegate {
    func didSelectDate(selectedDate: NSDate!)
    func didSelectDateRange(startDate: NSDate!, endDate: NSDate!)
}

protocol TWDateSelectionHandler {
    var changeMonthDelegate: TWChangeMonthDelegate? {get set}
    var changeDateDelegate: TWCalendarDateDelegate? {get set}
    func handleDateTapped(tile: TWCalendarTile)
    func handleDrag(recognizer: UIPanGestureRecognizer)
    func populatePreviousSelection(tile: TWCalendarTile)
    func populatePreviousHighlighting(baseDate: NSDate)
    func resetSelection()
    func setSelectedDates(startDate: NSDate?, endDate: NSDate?)
    func getSelectedDates() -> (NSDate?, NSDate?)
}
