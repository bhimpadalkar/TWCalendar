
import UIKit

class TWSingleDateSelectionHandler: TWDateSelectionHandler {
    var selectedDate: NSDate?
    var selectedDateTile: TWCalendarTile?
    var validator:TWCalendarValidator?
    var changeMonthDelegate: TWChangeMonthDelegate?

    init(validator: TWCalendarValidator){
        self.validator = validator
    }
    
    init(){
        
    }
    
    func handleDateTapped(tile: TWCalendarTile) {
        selectedDate = tile.date
        selectedDateTile?.selected = false
        tile.selected = true
        selectedDateTile?.refreshView()
        tile.refreshView()
        selectedDateTile = tile
        validator?.updateDates(selectedDate, endDate: nil)
    }
    
    func handleDrag(recognizer: UIPanGestureRecognizer) {
        let velocity = recognizer.velocityInView(recognizer.view).x
        if(velocity < -300) {changeMonthDelegate?.changeMonthTo(.Next)}
        if(velocity > 300) {changeMonthDelegate?.changeMonthTo(.Previous)}
    }
    
    func populatePreviousSelection(tile: TWCalendarTile) {
        if(tile.date == selectedDate){
            tile.selected = true
            selectedDateTile = tile
        } else {
            tile.selected = false
        }
    }
    
    func populatePreviousHighlighting(baseDate: NSDate) {
        
    }
    
    func setSelectedDates(startDate: NSDate?, endDate: NSDate?) {
        selectedDate = startDate
    }
    
    func getSelectedDates() -> (NSDate, NSDate?){
        return (selectedDate!, nil)
    }
    
    func resetSelection(){
        selectedDateTile = nil
    }

}
