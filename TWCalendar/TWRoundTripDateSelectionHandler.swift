
import UIKit

protocol TWRangeSelectionDelegate{
    func didCompleteRangeSelection(selectedView: [UIView])
    func didStartNewRangeSelectionWith()
}

class TWRoundTripDateSelectionHandler: TWDateSelectionHandler {
    private var outboundDate: NSDate?
    private var inboundDate: NSDate?
    private var selectedDateTile: TWCalendarTile?
    private var outboundSelectedTile: TWCalendarTile?
    private var inboundSelectedTile: TWCalendarTile?
    private var isOutboundDragged = false
    private var isInboundDragged = false
    private let kSwipThreshold: CGFloat = 700
    var rangeSelectionDelegate: TWRangeSelectionDelegate?
    var changeMonthDelegate: TWChangeMonthDelegate?
    var validator:TWCalendarValidator
    var styler: TWCalendarStyler?

    init(validator: TWCalendarValidator){
        self.validator = validator
    }
    
    func setSelectedDates(outboundDate: NSDate?, inboundDate: NSDate?) {
        self.outboundDate = outboundDate
        self.inboundDate = inboundDate
    }
    
    func getSelectedDates() -> (NSDate, NSDate?){
        return (outboundDate!, inboundDate)
    }
    
    func resetSelection(){
        outboundSelectedTile = nil
        inboundSelectedTile = nil
    }
    
    func populatePreviousSelection(tile: TWCalendarTile) {
        tile.selected = false
        if(tile.date == outboundDate){
            tile.selected = true
            outboundSelectedTile = tile
        }
        if(tile.date == inboundDate){
            tile.selected = true
            inboundSelectedTile = tile
        }
    }
    
    func populatePreviousHighlighting(baseDate: NSDate) {
        rangeSelectionDelegate?.didStartNewRangeSelectionWith()
        if(inboundDate != nil){
            highlightSelection(baseDate)
        }
    }
    
    func handleDateTapped(tile: TWCalendarTile) {
        if(outboundDate == nil || inboundDate != nil || (inboundDate == nil && tile.date!.fallsBefore(outboundDate!))){
            outboundDate = tile.date
            changeSelectedStateFor(outboundSelectedTile, toState: false)
            outboundSelectedTile = tile
            
            changeSelectedStateFor(inboundSelectedTile, toState: false)
            inboundDate = nil
            inboundSelectedTile = nil
            rangeSelectionDelegate?.didStartNewRangeSelectionWith()
        } else {
            inboundDate = tile.date
            inboundSelectedTile = tile
            highlightSelection(tile.date!)
        }
        changeSelectedStateFor(tile, toState: true)
    }
    
    func handleDrag(recognizer: UIPanGestureRecognizer) {
        let gestureView = recognizer.view
        let (startTile, endTile) = getStartAndEndTiles(recognizer)
        
        if(isSwiped(recognizer.velocityInView(gestureView).x) || inboundDate == nil || isNotDraggableArea(startTile, endTile: endTile)){
            return
        }
        
        if(recognizer.state == .Began){
            if(isOutboundSameAsInbound()){
                isOutboundDragged = isLeftDrag(recognizer.velocityInView(gestureView))
                isInboundDragged = !isLeftDrag(recognizer.velocityInView(gestureView))
            } else {
                isOutboundDragged = startTile == outboundSelectedTile
                isInboundDragged = startTile == inboundSelectedTile
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
            
            if(isOutboundDragged && endTile!.date!.fallsOnOrBefore(inboundDate!)){
                changeHighlightingFor(&outboundSelectedTile, date: &outboundDate!, newTile:endTile)
            } else if(isInboundDragged && endTile!.date!.fallsOnOrAfter(outboundDate!)){
                changeHighlightingFor(&inboundSelectedTile, date: &inboundDate!, newTile:endTile)
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
        return (endTile.date != outboundDate && endTile.date != inboundDate)
    }
    
    private func changeSelectedStateFor(tile : TWCalendarTile?, toState:Bool){
        tile?.selected = toState
        tile?.refreshView()
        validator.updateDates(outboundDate, inboundDate:inboundDate)
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
        return outboundSelectedTile == inboundSelectedTile
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
        let outboundTilePosition = outboundSelectedTile?.position
        let inboundTilePosition = inboundSelectedTile?.position
        let topLeftPosition = TilePosition(row: 1, column:0)
        let bottomRightPosition = TilePosition(row: 6, column:6)
        var viewToBeHighligted = [UIView]()
        
        if(outboundSelectedTile? != nil && inboundSelectedTile? != nil){
            viewToBeHighligted = styler!.createViewForRange(outboundTilePosition!, endPosition: inboundTilePosition!)
        }
        else if(inboundSelectedTile != nil){
            viewToBeHighligted = styler!.createViewForRange(topLeftPosition, endPosition: inboundTilePosition!)
        }
        else if(outboundSelectedTile != nil){
            viewToBeHighligted = styler!.createViewForRange(outboundTilePosition!, endPosition: bottomRightPosition)
        }
        else {
            if (baseDate.fallsAfter(outboundDate!) && baseDate.fallsOnOrBefore(inboundDate!)){
                viewToBeHighligted = styler!.createViewForRange(topLeftPosition, endPosition: bottomRightPosition)
            }
        }
        rangeSelectionDelegate?.didCompleteRangeSelection(viewToBeHighligted)
    }
}
