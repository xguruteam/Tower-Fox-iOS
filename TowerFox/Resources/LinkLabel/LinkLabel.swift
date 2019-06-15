//
//  LinkLabel.swift
//  TwIM
//
//  Created by Andrew Hart on 06/08/2015.
//  Copyright (c) 2015 Project Dent. All rights reserved.
//

import UIKit

private class Attribute {
    let attributeName: String
    let value: AnyObject
    let range: NSRange
    
    init(attributeName: String, value: AnyObject, range: NSRange) {
        self.attributeName = attributeName
        self.value = value
        self.range = range
    }
}

private class LinkAttribute {
    let url: NSURL
    let urlString: NSString
    let range: NSRange
    
    init(url: NSURL, range: NSRange, str: NSString) {
        self.url = url
        self.range = range
        self.urlString = str
    }
    
}

public protocol LinkLabelInteractionDelegate: class {
    func linkLabelDidSelectLink(linkLabel: LinkLabel, url: NSURL, urlString: NSString)
}

public class LinkLabel: UILabel, UIGestureRecognizerDelegate {
    
    private var linkAttributes: Array<LinkAttribute> = []
    
    private var standardTextAttributes: Array<Attribute> = []
    
    public var linkTextAttributes: Dictionary<String, AnyObject> {
        didSet {
            self.setupAttributes()
        }
    }
    
    //Text attributes displayed when a link has been highlighted
    public var highlightedLinkTextAttributes: Dictionary<String, AnyObject> {
        didSet {
            self.setupAttributes()
        }
    }
    
    private var highlightedLinkAttribute: LinkAttribute? {
        didSet {
            if self.highlightedLinkAttribute !== oldValue {
                self.setupAttributes()
            }
        }
    }
    
    override public var attributedText: NSAttributedString? {
        set {
            if newValue == nil {
                super.attributedText = newValue
                return
            }
            
            super.attributedText = newValue
            
            if newValue != nil {
                let range = NSMakeRange(0, self.attributedText!.length)
                
                let mutableAttributedText = NSMutableAttributedString(attributedString: newValue!)
                
                var standardAttributes: Array<Attribute> = []
                var linkAttributes: Array<LinkAttribute> = []
                
                self.attributedText!.enumerateAttributes(
                    in: range,
                    options: []) {
                        (attributes, range: NSRange, _) -> Void in
                        for (attributeName, value): (NSAttributedStringKey, Any) in attributes {
                            
                            if attributeName == NSAttributedStringKey.link {
                                if value is NSURL {
                                    let linkAttribute = LinkAttribute(url: value as! NSURL, range: range, str: "")
                                    linkAttributes.append(linkAttribute)
                                }else{
                                    let linkAttribute = LinkAttribute(url: NSURL(string: "")!, range: range, str: value as! NSString)
                                    linkAttributes.append(linkAttribute)
                                }
                            } else {
                                let attribute = Attribute(attributeName: attributeName.rawValue, value: value as AnyObject, range: range)
                                standardAttributes.append(attribute)
                            }
                        }
                }
                
                self.standardTextAttributes = standardAttributes
                self.linkAttributes = linkAttributes
                
                super.attributedText = mutableAttributedText
            }
            
            self.setupAttributes()
        }
        get {
            return super.attributedText
        }
    }
    
    public weak var interactionDelegate: LinkLabelInteractionDelegate?
    
    override public init(frame: CGRect) {
        linkTextAttributes = [
            NSAttributedStringKey.underlineStyle.rawValue: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue)]
        
        highlightedLinkTextAttributes = [
            NSAttributedStringKey.underlineStyle.rawValue: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue)]
        
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        
        let touchGestureRecognizer = TouchGestureRecognizer(target: self, action: #selector(respondToLinkLabelTouched(_ :)))
        touchGestureRecognizer.delegate = self
        self.addGestureRecognizer(touchGestureRecognizer)
//
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(respondToLinkLabelTapped(_ :)))
        tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(tapGestureRecognizer)
        
        self.setupAttributes()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func respondToLinkLabelTouched(_ gestureRecognizer: TouchGestureRecognizer) {
        if self.linkAttributes.count == 0 {
            return
        }
        
        //Possible states are began or cancelled
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            let indexOfCharacterTouched = gestureRecognizer.indexOfCharacterTouched(label: self)
            
            if indexOfCharacterTouched != nil {
                for linkAttribute in self.linkAttributes {
                    if indexOfCharacterTouched! >= linkAttribute.range.location &&
                        indexOfCharacterTouched! <= linkAttribute.range.location + linkAttribute.range.length {
                            self.highlightedLinkAttribute = linkAttribute
                            return
                    }
                }
            }
        }
        
        self.highlightedLinkAttribute = nil
    }
    
    @objc func respondToLinkLabelTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        if self.linkAttributes.count == 0 {
            return
        }
        
        let indexOfCharacterTouched = gestureRecognizer.indexOfCharacterTouched(label: self)
        
        if indexOfCharacterTouched != nil  {
            for linkAttribute in self.linkAttributes {
                if indexOfCharacterTouched! >= linkAttribute.range.location &&
                    indexOfCharacterTouched! <= linkAttribute.range.location + linkAttribute.range.length {
                    self.interactionDelegate?.linkLabelDidSelectLink(linkLabel: self, url: linkAttribute.url, urlString: linkAttribute.urlString)
                        break
                }
            }
        }
    }
    
    private func setupAttributes() {
        if self.attributedText == nil {
            super.attributedText = nil
            return
        }
        
        let mutableAttributedText = NSMutableAttributedString(attributedString: self.attributedText!)
        
        mutableAttributedText.removeAttributes()
        
        for attribute in self.standardTextAttributes {
            mutableAttributedText.addAttribute(NSAttributedStringKey(rawValue: attribute.attributeName), value: attribute.value, range: attribute.range)
        }
        
        for linkAttribute in self.linkAttributes {
            if linkAttribute === self.highlightedLinkAttribute {
                for (attributeName, value): (String, AnyObject) in self.highlightedLinkTextAttributes {
                    mutableAttributedText.addAttribute(NSAttributedStringKey(rawValue: attributeName), value: value, range: linkAttribute.range)
                }
            } else {
                for (attributeName, value): (String, AnyObject) in self.linkTextAttributes {
                    mutableAttributedText.addAttribute(NSAttributedStringKey(rawValue: attributeName), value: value, range: linkAttribute.range)
                }
            }
        }
        
        super.attributedText = mutableAttributedText
    }
    
    //MARK: UIGestureRecognizerDelegate
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
