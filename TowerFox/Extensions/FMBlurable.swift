//
//  FMBlurable.swift
//  UGEN
//
//  Created by cgc on 7/20/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit


protocol Blurable
{
    var layer: CALayer { get }
    var subviews: [UIView] { get }
    var frame: CGRect { get }
    var superview: UIView? { get }
    
    func addSubview(_ view: UIView)
    func removeFromSuperview()
    
    func blur(blurRadius: CGFloat)
    func unBlur()
    
    var isBlurred: Bool { get }
}

extension Blurable
{
    func blur(blurRadius: CGFloat)
    {
        if self.superview == nil
        {            return
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: frame.width, height: frame.height), false, 1)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        guard let blur = CIFilter(name: "CIGaussianBlur"),
            let this = self as? UIView else
        {
            return
        }
        
        blur.setValue(CIImage(image: image!), forKey: kCIInputImageKey)
        blur.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        let ciContext  = CIContext(options: nil)
        
        let result = blur.value(forKey: kCIOutputImageKey) as! CIImage
        
        let boundingRect = CGRect(x:0,
                                  y: 0,
                                  width: frame.width,
                                  height: frame.height)
        
        let cgImage = ciContext.createCGImage(result, from: boundingRect)
        
        let filteredImage = UIImage(cgImage: cgImage!)
        
        let blurOverlay = BlurOverlay()
        blurOverlay.frame = boundingRect
        
        blurOverlay.image = filteredImage
        blurOverlay.contentMode = .center
        
        if let superview = superview as? UIStackView
        {
            var index = 0
            for v in 0..<(superview as UIStackView).arrangedSubviews.count {
                if (superview as UIStackView).arrangedSubviews[v] == this {
                    index = v
                }
            }

            removeFromSuperview()
            superview.insertArrangedSubview(blurOverlay, at: index)
        }
        else
        {
            blurOverlay.frame.origin = frame.origin
            
            UIView.transition(from: this,
                              to: blurOverlay,
                                      duration: 0.2,
                                      options: .curveEaseIn,
                                      completion: nil)
        }
        
        objc_setAssociatedObject(this,
                                 &BlurableKey.blurable,
                                 blurOverlay,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
    func unBlur()
    {
        guard let this = self as? UIView,
            let blurOverlay = objc_getAssociatedObject(self as? UIView as Any, &BlurableKey.blurable) as? BlurOverlay else
        {
            return
        }
        
        if let superview = blurOverlay.superview as? UIStackView
        {
            var index = 0
            for v in 0..<(superview as UIStackView).arrangedSubviews.count {
                if (superview as UIStackView).arrangedSubviews[v] == blurOverlay {
                    index = v
                }
            }
            blurOverlay.removeFromSuperview()
            superview.insertArrangedSubview(this, at: index)
        }
        else
        {
            this.frame.origin = blurOverlay.frame.origin
            
            UIView.transition(from: blurOverlay,
                              to: this,
                                      duration: 0.2,
                                      options: .curveEaseIn,
                                      completion: nil)
        }
        
        objc_setAssociatedObject(this,
                                 &BlurableKey.blurable,
                                 nil,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    
    var isBlurred: Bool
    {
        return objc_getAssociatedObject(self as? UIView ?? "", &BlurableKey.blurable) is BlurOverlay
    }
}

extension UIView: Blurable {
    
}
class BlurOverlay: UIImageView
{
}

struct BlurableKey
{
    static var blurable = "blurable"
}
