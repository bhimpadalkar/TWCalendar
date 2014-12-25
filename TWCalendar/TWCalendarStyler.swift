
import UIKit

class TWCalendarStyler: NSObject {
    
    internal var tileSize: CGSize
    internal var xOffset: CGFloat
    internal var yOffset: CGFloat
    
    init(tileSize: CGSize, xOffset: CGFloat, yOffset: CGFloat){
        self.tileSize = tileSize
        self.xOffset = xOffset
        self.yOffset = yOffset
    }
    
    func createViewForRange(startPosition: TilePosition, endPosition: TilePosition) -> [UIView]{
        var views: [UIView] = []
        var startX = CGFloat(startPosition.column) * xOffset
        var endX = 6 * xOffset + tileSize.width
        var startRow = startPosition.row
        var endRow = endPosition.row
        var y = yOffset * CGFloat(startRow)
        
        while(startRow <= endRow){
            var frame = CGRect();
            
            if(startRow != startPosition.row){
                startX = 0
            }
            
            if(startRow == endPosition.row){
                endX = CGFloat(endPosition.column) * xOffset + tileSize.width
            }
            
            frame.origin.x = startX
            frame.size.width = endX - startX
            frame.origin.y = y
            frame.size.height = tileSize.height
            var view = UIView(frame: frame)
            view.layer.cornerRadius = view.frame.height/2
            view.backgroundColor = UIColor(white: 135/255, alpha: 1)
            
            views.append(view)
            startRow++
            y += yOffset
        }
        return views
    }
}
