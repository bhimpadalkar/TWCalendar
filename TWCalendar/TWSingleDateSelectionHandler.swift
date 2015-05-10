
import UIKit

class TWSingleDateSelectionHandler: TWDateSelectionHandler {
    var selectedDate: NSDate?
    var selectedDateTile: TWCalendarTile?
    var changeMonthDelegate: TWChangeMonthDelegate?
    var changeDateDelegate: TWCalendarDateDelegate?
    
    init(){
        
    }
    
    func handleDateTapped(tile: TWCalendarTile) {
        selectedDate = tile.date
        selectedDateTile?.selected = false
        tile.selected = true
        selectedDateTile?.refreshView()
        tile.refreshView()
        selectedDateTile = tile
        changeDateDelegate?.didSelectDate(selectedDate)
    }
    
    func handleDrag(recognizer: UIPanGestureRecognizer) {
        let velocity = recognizer.velocityInView(recognizer.view).x
        if(velocity < -300) {changeMonthDelegate?.changeMonthTo(.Next)}
        if(velocity > 300) {changeMonthDelegate?.changeMonthTo(.Previous)}
    }
    
    func populatePreviousSelection(tile: TWCalendarTile) {
        tile.selected = false
        if(selectedDate != nil && tile.date!.isSameDayAs(selectedDate!)){
            tile.selected = true
            selectedDateTile = tile
        }
    }
    
    func populatePreviousHighlighting(baseDate: NSDate) {
        
    }
    
    func setSelectedDates(startDate: NSDate?, endDate: NSDate?) {
        selectedDate = startDate
    }
    
    func getSelectedDates() -> (NSDate?, NSDate?){
        return (selectedDate, nil)
    }
    
    func resetSelection(){
        selectedDateTile = nil
    }

}
