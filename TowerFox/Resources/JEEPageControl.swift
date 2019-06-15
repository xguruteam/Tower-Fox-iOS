//
//  ISPageControl.swift
//  BudMeow
//
//  Created by jkc on 7/31/18.
//  Copyright © 2018 budmeow. All rights reserved.
//

import UIKit

@IBDesignable class JEEPageControl: UIControl, UIScrollViewDelegate {
    struct pageStatic {
        static let kDotDiameterOn:CGFloat = 16
        static let kDotDiameterOff:CGFloat = 8
        static let kDotSpace:CGFloat = 12
    }
    var pageItem: JEEPageItem!
    var currentPage: Int = 0 {
        didSet{
            dotArray.forEach { (dot) in
                if dot.tag == (currentPage + 1) {
                    if dot.frame.size.width < self.pageItem.indicatorDiameterOn {
                        dot.transform = CGAffineTransform(scaleX: 2, y: 2)
                        dot.backgroundColor = self.pageItem.onColor
                    }
                }else{
                    if dot.frame.size.width > self.pageItem.indicatorDiameterOff{
                        dot.transform = CGAffineTransform(scaleX: 1, y: 1)
                        dot.backgroundColor = self.pageItem.offColor
                    }
                }
            }

        }
    }
    
    private var dotArray = [UIView]()
    private var isClickJump = false
    
    init(item: JEEPageItem!) {
        super.init(frame: CGRect.zero)
        self.pageItem = item
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initDotSize() {
        for dotView in self.dotArray {
            dotView.transform = CGAffineTransform.identity
            dotView.backgroundColor = self.pageItem.offColor
        }
    }
    
    func setupView() {
        var diameter = self.pageItem.indicatorDiameterOff
        if diameter <= 0 {
            diameter = pageStatic.kDotDiameterOff
        }
        
        let space = self.pageItem.indicatorSpace
        if space <= 0 {
            diameter = pageStatic.kDotSpace
        }
        let offColor = self.pageItem.offColor
        let onColor = self.pageItem.onColor
        
        for i in 0..<self.pageItem.numberOfPages {
            
            let dotView = UIView(frame: CGRect(x: CGFloat(i)*diameter+CGFloat(i)*space, y: 0, width: diameter, height: diameter))
            dotView.layer.cornerRadius = diameter/2
            dotView.backgroundColor = offColor
            dotView.tag = i+1
            self.addSubview(dotView)
            self.dotArray.append(dotView)
        }
        if self.pageItem.numberOfPages > 0 {
            let bigTransform = self.pageItem.indicatorDiameterOn/self.pageItem.indicatorDiameterOff
            self.dotArray[0].transform = CGAffineTransform(scaleX: bigTransform, y: bigTransform)
            self.dotArray[0].backgroundColor = onColor
        }
    }
    
    func changeToNearDot(forward: Bool, progress: CGFloat) {
        var toDotView: UIView?
        if forward && self.currentPage < self.dotArray.count {
            toDotView = self.dotArray[self.currentPage]
        }else if !forward&&self.currentPage > 1 {
            toDotView = self.dotArray[self.currentPage - 1]
        }
        let fromDotView = self.dotArray[self.currentPage]
        let diffTransform = (self.pageItem.indicatorDiameterOn - self.pageItem.indicatorDiameterOff)/self.pageItem.indicatorDiameterOff
        
        if progress > 0 && progress < 1 {
            let offColor = self.pageItem.offColor
            let onColor = self.pageItem.onColor
            if toDotView != nil {
                toDotView!.transform = CGAffineTransform(scaleX: 1+diffTransform*progress, y: 1+diffTransform*progress)
                
                toDotView?.backgroundColor = self.colorTransformToAnother(fromColor: offColor, toColor: onColor, progress: progress)
            }
            fromDotView.transform = CGAffineTransform(scaleX: (1 + diffTransform)-diffTransform*progress, y: (1 + diffTransform)-diffTransform*progress)
            fromDotView.backgroundColor = self.colorTransformToAnother(fromColor: onColor, toColor: offColor, progress: progress)
        }
    }
    
    func colorTransformToAnother(fromColor: UIColor, toColor: UIColor, progress: CGFloat) -> UIColor {
        let fromRGB = fromColor.cgColor.components!
        let toRGB = toColor.cgColor.components!
        return UIColor(red: fromRGB[0] + (toRGB[0] - fromRGB[0])*progress, green: fromRGB[1] + (toRGB[1] - fromRGB[1])*progress, blue: fromRGB[2] + (toRGB[2] - fromRGB[2])*progress, alpha: fromRGB[3] + (toRGB[3] - fromRGB[3])*progress)
    }
}

class JEEPageItem {
    var numberOfPages: Int!
    var onColor: UIColor = UIColor.appMainColor
    var offColor: UIColor = UIColor.appMainDarkColor
    var indicatorDiameterOn: CGFloat = 16
    var indicatorDiameterOff: CGFloat = 8
    var indicatorSpace: CGFloat = 12
    var hideForSignlePage: Bool = true
    
    init(pageNum: Int) {
        self.numberOfPages = pageNum
    }
}
