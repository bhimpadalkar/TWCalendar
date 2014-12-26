
import UIKit

protocol TWChangeMonthDelegate{
    func shouldChangeMonthTo(type: MonthType)
}

protocol TWDateSelectionHandler {
    var validator: TWCalendarValidator {get set}
    var changeMonthDelegate: TWChangeMonthDelegate? {get set}
    func handleDateTapped(tile: TWCalendarTile)
    func handleDrag(recognizer: UIPanGestureRecognizer)
    func populatePreviousSelection(tile: TWCalendarTile)
    func populatePreviousHighlighting(baseDate: NSDate)
    func resetSelection()
    func setSelectedDates(startDate: NSDate?, endDate: NSDate?)
    func getSelectedDates() -> (NSDate, NSDate?)
}
