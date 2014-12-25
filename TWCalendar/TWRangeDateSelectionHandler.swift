
import UIKit

protocol TWRangeSelectionDelegate{
    func didCompleteRangeSelection(selectedView: [UIView])
    func didStartNewRangeSelectionWith()
}

class TWRangeDateSelectionHandler: TWDateSelectionHandler {
    private var rangeStartDate: NSDate?
    private var rangeEndDate: NSDate?
    private var selectedDateTile: TWCalendarTile?
    private var startDateSelectedTile: TWCalendarTile?
    private var endDateSelectedTile: TWCalendarTile?
    private var isStartDateDragged = false
    private var isEndDateDragged = false
    private let kSwipThreshold: CGFloat = 700
    var rangeSelectionDelegate: TWRangeSelectionDelegate?
    var changeMonthDelegate: TWChangeMonthDelegate?
    var validator:TWCalendarValidator
    var styler: TWCalendarStyler?

    init(validator: TWCalendarValidator){
        self.validator = validator
    }
    
    func setSelectedDates(outboundDate: NSDate?, inboundDate: NSDate?) {
        self.rangeStartDate = outboundDate
        self.rangeEndDate = inboundDate
    }
    
    func getSelectedDates() -> (NSDate, NSDate?){
        return (rangeStartDate!, rangeEndDate)
    }
    
    func resetSelection(){
        startDateSelectedTile = nil
        endDateSelectedTile = nil
    }
    
    func populatePreviousSelection(tile: TWCalendarTile) {
        tile.selected = false
        if(tile.date == rangeStartDate){
            tile.selected = true
            startDateSelectedTile = tile
        }
        if(tile.date == rangeEndDate){
            tile.selected = true
            endDateSelectedTile = tile
        }
    }
    
    func populatePreviousHighlighting(baseDate: NSDate) {
        rangeSelectionDelegate?.didStartNewRangeSelectionWith()
        if(rangeEndDate != nil){
            highlightSelection(baseDate)
        }
    }
    
    func handleDateTapped(tile: TWCalendarTile) {
        if(rangeStartDate == nil || rangeEndDate != nil || (rangeEndDate == nil && tile.date!.fallsBefore(rangeStartDate!))){
            rangeStartDate = tile.date
            changeSelectedStateFor(startDateSelectedTile, toState: false)
            startDateSelectedTile = tile
            
            changeSelectedStateFor(endDateSelectedTile, toState: false)
            rangeEndDate = nil
            endDateSelectedTile = nil
            rangeSelectionDelegate?.didStartNewRangeSelectionWith()
        } else {
            rangeEndDate = tile.date
            endDateSelectedTile = tile
            highlightSelection(tile.date!)
        }
        changeSelectedStateFor(tile, toState: true)
    }
    
    func handleDrag(recognizer: UIPanGestureRecognizer) {
        let gestureView = recognizer.view
        let (startTile, endTile) = getStartAndEndTiles(recognizer)
        
        if(isSwiped(recognizer.velocityInView(gestureView).x) || rangeEndDate == nil || isNotDraggableArea(startTile, endTile: endTile)){
            return
        }
        
        if(recognizer.state == .Began){
            if(isOutboundSameAsInbound()){
                isStartDateDragged = isLeftDrag(recognizer.velocityInView(gestureView))
                isEndDateDragged = !isLeftDrag(recognizer.velocityInView(gestureView))
            } else {
                isStartDateDragged = startTile == startDateSelectedTile
                isEndDateDragged = startTile == endDateSelectedTile
            }
        }
        
        if(recognizer.state == .Changed){
            if(isEligibleToChangeMonth(endTile!)){
                if(endTile?.position?.row == 1 && endTile?.position?.column == 0){
                    changeMonthDelegate?.shouldChangeMonthTo(.Previous)
                }
                if(endTile?.position?.row == 6 && endTile?.position?.column == 6){
                    changeMonthDelegate?.shouldChangeMonthTo(.Next)
                }
            }
            
            if(isStartDateDragged && endTile!.date!.fallsOnOrBefore(rangeEndDate!)){
                changeHighlightingFor(&startDateSelectedTile, date: &rangeStartDate!, newTile:endTile)
            } else if(isEndDateDragged && endTile!.date!.fallsOnOrAfter(rangeStartDate!)){
                changeHighlightingFor(&endDateSelectedTile, date: &rangeEndDate!, newTile:endTile)
            }
        }
    }
    
    private func isNotDraggableArea(startTile: TWCalendarTile?, endTile: TWCalendarTile?) -> Bool{
        return (startTile == nil || endTile == nil || endTile?.position?.row == 0)
    }
    
    private func isSwiped(velocity: CGFloat) -> Bool{
        switch velocity {
            case let v where v > kSwipThreshold:
                changeMonthDelegate?.shouldChangeMonthTo(.Previous)
                return true
            case let v where v < -kSwipThreshold:
                changeMonthDelegate?.shouldChangeMonthTo(.Next)
                return true
            default:
                return false
        }
    }
    
    private func isEligibleToChangeMonth(endTile: TWCalendarTile) -> Bool {
        return (endTile.date != rangeStartDate && endTile.date != rangeEndDate)
    }
    
    private func changeSelectedStateFor(tile : TWCalendarTile?, toState:Bool){
        tile?.selected = toState
        tile?.refreshView()
        validator.updateDates(rangeStartDate, inboundDate:rangeEndDate)
    }
    
    private func changeHighlightingFor(inout tile: TWCalendarTile?, inout date: NSDate, newTile: TWCalendarTile?){
        if(!newTile!.enabled) {return}
        changeSelectedStateFor(tile, toState: isOutboundSameAsInbound())
        tile = newTile
        date = tile!.date!
        rangeSelectionDelegate?.didStartNewRangeSelectionWith()
        changeSelectedStateFor(newTile, toState: true)
        highlightSelection(newTile!.date!)
    }
    
    private func isOutboundSameAsInbound() -> Bool{
        return startDateSelectedTile == endDateSelectedTile
    }
    
    private func getStartAndEndTiles(recognizer: UIPanGestureRecognizer) -> (TWCalendarTile?, TWCalendarTile?){
        let gestureView = recognizer.view
        let endPoint = recognizer.locationInView(gestureView)
        let translation = recognizer.translationInView(gestureView!)
        let startPoint = CGPoint(x: endPoint.x - translation.x, y: endPoint.y - translation.y)
        
        var startView = gestureView?.hitTest(startPoint, withEvent: nil)
        var endView = gestureView?.hitTest(endPoint, withEvent: nil)
        
        if((startView?.isKindOfClass(TWCalendarTile)) == nil){
            return (nil, nil)
        }
        if((endView?.isKindOfClass(TWCalendarTile)) == nil){
            return (nil, nil)
        }
        return (startView as? TWCalendarTile, endView as? TWCalendarTile)
    }
    
    private func isLeftDrag(velocity: CGPoint) -> Bool {
        return velocity.x < 0
    }
    
    private func highlightSelection(baseDate: NSDate){
        let outboundTilePosition = startDateSelectedTile?.position
        let inboundTilePosition = endDateSelectedTile?.position
        let topLeftPosition = TilePosition(row: 1, column:0)
        let bottomRightPosition = TilePosition(row: 6, column:6)
        var viewToBeHighligted = [UIView]()
        
        if(startDateSelectedTile? != nil && endDateSelectedTile? != nil){
            viewToBeHighligted = styler!.createViewForRange(outboundTilePosition!, endPosition: inboundTilePosition!)
        }
        else if(endDateSelectedTile != nil){
            viewToBeHighligted = styler!.createViewForRange(topLeftPosition, endPosition: inboundTilePosition!)
        }
        else if(startDateSelectedTile != nil){
            viewToBeHighligted = styler!.createViewForRange(outboundTilePosition!, endPosition: bottomRightPosition)
        }
        else {
            if (baseDate.fallsAfter(rangeStartDate!) && baseDate.fallsOnOrBefore(rangeEndDate!)){
                viewToBeHighligted = styler!.createViewForRange(topLeftPosition, endPosition: bottomRightPosition)
            }
        }
        rangeSelectionDelegate?.didCompleteRangeSelection(viewToBeHighligted)
    }
}
