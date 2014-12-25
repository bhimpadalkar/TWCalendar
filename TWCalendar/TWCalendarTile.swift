
import UIKit

enum TWTileType: CGFloat{
    case Normal = 255
    case Disabled = 153
}

class TilePosition: NSObject{
    internal var row = 0
    internal var column = 0
    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
}

class TWCalendarTile: UIButton {
    var date: NSDate?
    var tileData: NSString?
    var isOfToday: Bool?
    var type: TWTileType?
    var position: TilePosition?
    
    init(frame: CGRect, position: TilePosition) {
        self.position = position
        super.init(frame: frame)
        resetData()
        self.contentEdgeInsets = UIEdgeInsetsMake(2, 1, 0, 0)
        self.layer.cornerRadius = self.frame.size.width/2
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.titleLabel?.font = UIFont(name: "Helvetica", size: 14)
        self.setTitleColor(UIColor(white: 76/255, alpha: 1), forState: UIControlState.Selected)
    }   

    required init(coder aDecoder: NSCoder) {
        super.init()
    }
    
    func setTileData(tileData: NSString){
        self.tileData = tileData
        self.setTitle(tileData, forState: UIControlState.Normal)
    }
    
    func refreshView(){
        setTileData(String(date!.day()))
        self.setTitleColor(UIColor(white: type!.rawValue/255, alpha: 1), forState: .Normal)
        if(selected){
            self.backgroundColor = UIColor.whiteColor()
        } else {
            if(isOfToday!){
                self.layer.borderWidth = 1
            }
            else{
                self.layer.borderWidth = 0
            }
        }
    }
    
    func resetData(){
        self.enabled = true
        date = nil
        tileData = nil
        isOfToday = false
        type = .Normal
        self.backgroundColor = UIColor.clearColor()
    }
}
