
import UIKit

class TWCalendarMonthView: UIView, TWRangeSelectionDelegate {
    private var numWeeks = 0
    private let numOfRows = 7
    private let numOfColumns = 7
    private let tileSize = CGSize(width: 32, height: 32)
    private let verticalSpacingBetweenTiles = 5
    private var xOffset = 0
    private var yOffset = 0
    private var dateTiles = [TWCalendarTile]()
    private var dateSelectionHandler: TWDateSelectionHandler?
    private var highlightedViews: [UIView]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let horizontalSpacingBetweenTiles = (Int(frame.size.width) - ((numOfColumns) * Int(tileSize.width))) / (numOfColumns - 1)
        xOffset = horizontalSpacingBetweenTiles + Int(tileSize.width)
        yOffset = verticalSpacingBetweenTiles + Int(tileSize.height)

        createHeaderTiles(xOffset)
        createDayTiles(xOffset, yOffset: yOffset)
    }

    required init(coder aDecoder: NSCoder) {
        super.init()
    }
    
    private func createHeaderTiles(xOffset: Int){
        let weekNames = ["S","M","T","W","T","F","S"]
        for (i,week) in enumerate(weekNames){
            let frame = CGRect(x: i * xOffset, y: 0, width: Int(tileSize.width), height: Int(tileSize.height))
            var tileView = TWCalendarTile(frame: frame, position:TilePosition(row:0, column:i))
            tileView.setTileData(week)
            dateTiles.append(tileView)
            addSubview(tileView)
        }
    }

    private func createDayTiles(xOffset: Int, yOffset: Int){
        for i in 1..<numOfRows {
            for j in 0..<numOfColumns {
                let frame = CGRect(x: j * xOffset, y: i * yOffset, width: Int(tileSize.width), height: Int(tileSize.height))
                var tile = TWCalendarTile(frame: frame, position:TilePosition(row:i, column:j))
                tile.addTarget(self, action: "handleDateTap:", forControlEvents: .TouchUpInside)
                dateTiles.append(tile)
                addSubview(tile)
            }
        }
    }
    
    func showDates(datesOfCurrentMonth:NSArray, datesOfPreviousMonth:NSArray, datesOfNextMonth:NSArray, minAvailableDate:NSDate?,  maxAvailableDate:NSDate?){
        var tileNum = 7;
        let dates = [datesOfPreviousMonth, datesOfCurrentMonth, datesOfNextMonth]
        dateSelectionHandler?.resetSelection()
        for i in 0...dates.count-1 {
            for j in 0...dates[i].count-1 {
                let d = dates[i][j] as NSDate;
                let tile = dateTiles[tileNum] as TWCalendarTile
                tile.resetData()
                tile.date = d
                dateSelectionHandler!.populatePreviousSelection(tile)
                tile.isOfToday = NSDate().isSameDayAs(d)
                if((minAvailableDate != nil && d.fallsBefore(minAvailableDate!)) || (maxAvailableDate != nil && d.fallsAfter(maxAvailableDate!))) {
                    tile.enabled = false
                }
                
                tile.refreshView()
                tileNum++;
            }
        }
        dateSelectionHandler?.populatePreviousHighlighting(datesOfCurrentMonth[0] as NSDate)
    }
    
    func handleDateTap(sender: TWCalendarTile){
        dateSelectionHandler?.handleDateTapped(sender)        
    }
    
    func setSelectedDates(startDate: NSDate?, endDate: NSDate?){
        dateSelectionHandler!.setSelectedDates(startDate, endDate: endDate)
    }
    
    func getSelectedDates() -> (NSDate, NSDate?) {
        return dateSelectionHandler!.getSelectedDates()
    }
    
    func didCompleteRangeSelection(highlightedViews: [UIView]) {
        self.highlightedViews = highlightedViews
        for view in highlightedViews{
            addSubview(view)
            sendSubviewToBack(view)
        }
    }
    
    func didStartNewRangeSelectionWith() {
        if let views = highlightedViews{
            for view in views{
                view.removeFromSuperview()
            }
        }
    }
    
    func setDateSelectionHandler(dateSelectionHandler : TWDateSelectionHandler){
        self.dateSelectionHandler = dateSelectionHandler
        if let handler = (dateSelectionHandler as? TWRangeDateSelectionHandler){
            handler.rangeSelectionDelegate = self
            handler.styler = TWCalendarStyler(tileSize: self.tileSize, xOffset: CGFloat(self.xOffset), yOffset: CGFloat(self.yOffset))
        }
    }
    
    func handleDrag(recognizer: UIPanGestureRecognizer){
        dateSelectionHandler?.handleDrag(recognizer)
    }
    
    func setChangeMonthDelegate(delegate: TWChangeMonthDelegate){
        dateSelectionHandler?.changeMonthDelegate = delegate
    }
}
