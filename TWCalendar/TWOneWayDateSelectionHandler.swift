
import UIKit

class TWOneWayDateSelectionHandler: TWDateSelectionHandler {
    var selectedDate: NSDate?
    var selectedDateTile: TWCalendarTile?
    var validator:TWCalendarValidator
    var changeMonthDelegate: TWChangeMonthDelegate?

    init(validator: TWCalendarValidator){
        self.validator = validator
    }
    
    func handleDateTapped(tile: TWCalendarTile) {
        selectedDate = tile.date
        selectedDateTile?.selected = false
        tile.selected = true
        selectedDateTile?.refreshView()
        tile.refreshView()
        selectedDateTile = tile
        validator.updateDates(selectedDate, inboundDate: nil)
    }
    
    func handleDrag(recognizer: UIPanGestureRecognizer) {
        let velocity = recognizer.velocityInView(recognizer.view).x
        if(velocity < -300) {changeMonthDelegate?.shouldChangeMonthTo(.Next)}
        if(velocity > 300) {changeMonthDelegate?.shouldChangeMonthTo(.Previous)}
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
    
    func setSelectedDates(outboundDate: NSDate?, inboundDate: NSDate?) {
        selectedDate = outboundDate
    }
    
    func getSelectedDates() -> (NSDate, NSDate?){
        return (selectedDate!, nil)
    }
    
    func resetSelection(){
        selectedDateTile = nil
    }

}
