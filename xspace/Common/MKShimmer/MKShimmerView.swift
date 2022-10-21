//
//  MKShimmerView.swift
//  xspace
//
//  Created by Monks on 2022/8/29.
//  Copyright © 2022 星舰. All rights reserved.
//

import Foundation
import UIKit

public enum MKShimmerDirection: Int {
    case right,left,up,down
}
public class MKShimmerView: UIView {
    
    /// 需要闪烁的view，包括其子类
    public var contentView: UIView = UIView() {
        didSet{
            if oldValue != contentView {
                oldValue.removeFromSuperview()
                self.addSubview(contentView)
                if let layer = self.layer as? MKShimmerLayer {
                    layer.contentLayer = contentView.layer
                }
            }
        }
    }
    
    /// 是否闪烁，默认false
    public var shimmering: Bool {
        get{
            return (self.layer as? MKShimmerLayer)?.shimmering ?? false
        }
        set{
            (self.layer as? MKShimmerLayer)?.shimmering = newValue
        }
    }
    
    /// 闪烁间隔时间，默认0.4s
    public var shimmeringPauseDuration: TimeInterval {
        get{
            return (self.layer as? MKShimmerLayer)?.shimmeringPauseDuration ?? 0
        }
        set{
            (self.layer as? MKShimmerLayer)?.shimmeringPauseDuration = newValue
        }
    }
    
    /// 闪烁区域透明，默认0.5
    public var shimmeringAnimationOpacity: CGFloat {
        get{
            return (self.layer as? MKShimmerLayer)?.shimmeringAnimationOpacity ?? 1
        }
        set{
            (self.layer as? MKShimmerLayer)?.shimmeringAnimationOpacity = newValue
        }
    }
    
    /// 闪烁时content透明度，默认1
    public var shimmeringOpacity: CGFloat {
        get{
            return (self.layer as? MKShimmerLayer)?.shimmeringOpacity ?? 1
        }
        set{
            (self.layer as? MKShimmerLayer)?.shimmeringOpacity = newValue
        }
    }
    
    /// 闪烁移动速度，默认230
    public var shimmeringSpeed: CGFloat {
        get{
            return (self.layer as? MKShimmerLayer)?.shimmeringSpeed ?? 0
        }
        set{
            (self.layer as? MKShimmerLayer)?.shimmeringSpeed = newValue
        }
    }
    
    /// 闪烁区域范围[0,1],默认1
    public var shimmeringHighlightLength: CGFloat {
        get{
            return (self.layer as? MKShimmerLayer)?.shimmeringHighlightLength ?? 0
        }
        set{
            (self.layer as? MKShimmerLayer)?.shimmeringHighlightLength = newValue > 0 ? (newValue > 1 ? 1 : newValue) : 0
        }
    }
    
    /// 闪烁方向，默认向右
    public var shimmeringDirection: MKShimmerDirection {
        get{
            return (self.layer as? MKShimmerLayer)?.shimmeringDirection ?? .right
        }
        set{
            (self.layer as? MKShimmerLayer)?.shimmeringDirection = newValue
        }
    }
    
    /// 闪烁过渡结束的时间点CoreAnimation CACurrentMediaTime
    public var shimmeringFadeTime: TimeInterval {
        get{
            return (self.layer as? MKShimmerLayer)?.shimmeringFadeTime ?? 0
        }
        set{
            (self.layer as? MKShimmerLayer)?.shimmeringFadeTime = newValue
        }
    }
    
    /// 开始闪烁前的过渡时间长度，默认0.1
    public var shimmeringBeginFadeDuration: TimeInterval {
        get{
            return (self.layer as? MKShimmerLayer)?.shimmeringBeginFadeDuration ?? 0
        }
        set{
            (self.layer as? MKShimmerLayer)?.shimmeringBeginFadeDuration = newValue
        }
    }
    /// 结束闪烁后的过渡时间长度，默认0.3
    public var shimmeringEndFadeDuration: TimeInterval {
        get{
            return (self.layer as? MKShimmerLayer)?.shimmeringEndFadeDuration ?? 0
        }
        set{
            (self.layer as? MKShimmerLayer)?.shimmeringEndFadeDuration = newValue
        }
    }

    /// 闪烁开始的时间点CoreAnimation CACurrentMediaTime
    public var shimmeringBeginTime: TimeInterval {
        get{
            return (self.layer as? MKShimmerLayer)?.shimmeringBeginTime ?? 0
        }
        set{
            (self.layer as? MKShimmerLayer)?.shimmeringBeginTime = newValue
        }
    }
    
    
    public override class var layerClass: AnyClass {
        return MKShimmerLayer.classForCoder()
    }
    
    public override func layoutSubviews() {
        contentView.bounds = self.bounds
        contentView.center = self.center
    }
    
}
