//
//  RichText.swift
//  slideView
//
//  Created by Lendo on 2022/8/23.
//

import UIKit

class RichTextLabel: UILabel {
    typealias ClickBlock = ()->()
    private var rangeBlockDic: [String: ClickBlock] = [:]
    private var rangeColorDic: [String: UIColor] = [:]
    private var myString: String = ""
    private var attributedSting:NSMutableAttributedString?
    let layoutManager = NSLayoutManager()
    var textContainer = NSTextContainer()
    var textStorage :NSTextStorage?
    
    var padding = 0.0
    var width = UIScreen.main.bounds.width
    var height:CGFloat {
        if let _ = attributedSting {
            return attributedSting!.boundingRect(with: CGSize(width: width, height: 2000), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).size.height
        } else {
            return myString.boundingRect(with: CGSize(width: width, height: 2000), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).size.height
        }
    }
    
    var pointView:UIView?
    override init(frame: CGRect) {
        super.init(frame: frame)
        font = UIFont.systemFont(ofSize: 12, weight: .regular)
        textColor = UIColor(white: 1, alpha: 0.7)
//        setSting("登录即同意《服务条款》和《隐私协议》，并授权星舰加速器获取手机号")
        isUserInteractionEnabled = true
        width = frame.width
        numberOfLines = 0
        textContainer = NSTextContainer(size: self.bounds.size)
        textContainer.lineFragmentPadding = padding
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.size = self.frame.size
        textContainer.maximumNumberOfLines = self.numberOfLines
        layoutManager.addTextContainer(textContainer)
        textContainer.layoutManager = layoutManager
    }
    
    func calcGlyphsPositionInView() ->CGPoint {
        var offsetPoint = CGPoint.zero
        let size = layoutManager.usedRect(for: textContainer)
        let h = ceil(size.height)
        if h < self.bounds.height {
            offsetPoint.y = (self.bounds.height - h)/2
        }
        return offsetPoint
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    func setSting(_ string: String) {
        myString = string
        text = string
        attributedSting = NSMutableAttributedString(string: string)
        let p = NSMutableParagraphStyle()
        p.lineSpacing = 5
        attributedSting?.addAttribute(.paragraphStyle, value: p, range: NSRange(location: 0, length: string.count))
        attributedSting?.addAttribute(.font, value: UIFont.systemFont(ofSize: 12, weight: .regular), range: NSRange(location: 0, length: string.count))
        attributedText = attributedSting
    }
    
    override var attributedText: NSAttributedString? {
        didSet{
            prepareTextSystem()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textContainer.size = bounds.size
    }
    
    func prepareTextSystem() {
        textStorage = NSTextStorage(attributedString: self.attributedSting!)
        textStorage!.addLayoutManager(layoutManager)
        textContainer.size = self.frame.size
    }
    
    func addClickBlock(_ block: ClickBlock?, string: String, color:UIColor?) {
        let range = searchText(subSrting: string)
        addClickBlock(block, range: range, color: color)
        attributedText = attributedSting
    }

    func addClickBlock(_ block: ClickBlock?, range: NSRange, color:UIColor?) {
        if let _ = block {
            addClickBlock(block!, range: range)
        }
        if let _ = color {
            addColor(color!, range: range)
        }
        attributedText = attributedSting
    }
    
    func addColor(_  color:UIColor, range: NSRange) {
        guard self.attributedSting != nil else {
            return
        }
        rangeColorDic[NSStringFromRange(range)] = color
        self.attributedSting!.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        attributedText = attributedSting
    }
    
    func addClickBlock(_ block: @escaping ClickBlock, range: NSRange) {
        rangeBlockDic[NSStringFromRange(range)] = block
    }
    
    func removeColor(range: NSRange) {
        if rangeColorDic[range.string()] != nil , let _ = self.attributedSting {
            rangeColorDic.removeValue(forKey: range.string())
            self.attributedSting!.removeAttribute(NSAttributedString.Key.foregroundColor, range: range)
        }
        attributedText = attributedSting
    }
    
    func removeClickBlock(range: NSRange) {
        rangeBlockDic.removeValue(forKey: range.string())
    }
    
    func searchText(subSrting:String) -> NSRange {
        let ra =  self.myString.range(of: subSrting)
        if let _ = ra {
            return NSRange(ra!, in: self.myString)
        } else {
            return NSRange(location: 0, length: 0)
        }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect)
        textContainer.size = rect.size
    // 计算文字Frame的时候测试用, 实际绘制还是用Label自带的layoutManager
//        let rang = layoutManager.glyphRange(for: textContainer)
//        self.layoutManager.drawGlyphs(forGlyphRange: rang, at: calcGlyphsPositionInView())
    }

    var tapPoint: CGPoint?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        tapPoint = touch?.location(in: self)
        pointView?.frame = CGRect(origin: tapPoint!, size: pointView!.bounds.size)

        
        for (key, block) in rangeBlockDic {
            // 基于高度为0 , 顶格计算的, 但是绘制文字的时候有个偏移量
            let offsetPoint = calcGlyphsPositionInView()
            // 点击的时候就去计算一次点击模块, 可以考虑做个缓存优化一下
            var rect = self.boundingRectForCharacaterRange(range: NSRangeFromString(key))
            rect = CGRect(origin: CGPoint(x: rect.origin.x + offsetPoint.x, y: rect.origin.y + offsetPoint.y), size: rect.size)
            if let _ = tapPoint , rect.contains(tapPoint!){
                block()
            }
        }
    }
    
    func boundingRectForCharacaterRange(range:NSRange) -> CGRect {
        guard self.attributedSting != nil else {
            return CGRect.zero
        }
        var ra: NSRange = NSRange()
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &ra)
        let rect = layoutManager.boundingRect(forGlyphRange: ra, in: textContainer)
        
        return rect
    }
}

extension NSRange {
    func string() -> String {
        return NSStringFromRange(self)
    }
}

extension CGSize {
    func localString() -> String {
        return "width = " + NSNumber(value: width).stringValue + ", height = " + NSNumber(value: height).stringValue
    }
}
