//
//  CollapsibleTableViewHeader.swift
//  CloseOut
//
//  Created by cgc on 8/25/18.
//  Copyright © 2018 UGEN. All rights reserved.
//

import UIKit

protocol CollapsibleTableViewHeaderDelegate {
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int)
}

class CollapsibleTableViewHeader: UITableViewHeaderFooterView {
    
    var delegate: CollapsibleTableViewHeaderDelegate?
    var section: Int = 0
    
    let titleLabel = UILabel()
    let arrowLabel = UIButton(type: UIButtonType.system)
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Content View
        contentView.backgroundColor = UIColor.appLightGrayColor
        
        let marginGuide = contentView.layoutMarginsGuide
        
        // Arrow label
        contentView.addSubview(arrowLabel)
        arrowLabel.setImage(#imageLiteral(resourceName: "ic_right"), for: .normal)
        arrowLabel.tintColor = UIColor.black
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowLabel.widthAnchor.constraint(equalToConstant: 12).isActive = true
        arrowLabel.heightAnchor.constraint(equalToConstant: 12).isActive = true
        arrowLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        arrowLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        
        // Title label
        contentView.addSubview(titleLabel)
        titleLabel.textColor = UIColor.black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: arrowLabel.trailingAnchor, constant: 16).isActive = true
        
        //
        // Call tapHeader when tapping on this header
        //
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CollapsibleTableViewHeader.tapHeader(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // Trigger toggle section when tapping on the header
    //
    @objc func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? CollapsibleTableViewHeader else {
            return
        }
        
        delegate?.toggleSection(self, section: cell.section)
    }
    
    func setCollapsed(_ collapsed: Bool) {
        if collapsed {
            UIView.animate(withDuration: 0.5) {
                self.arrowLabel.setImage(#imageLiteral(resourceName: "ic_down"), for: .normal)
                self.arrowLabel.tintColor = UIColor.black
                self.titleLabel.textColor = UIColor.appMainColor
            }
        }else{
            UIView.animate(withDuration: 0.5) {
                self.arrowLabel.setImage(#imageLiteral(resourceName: "ic_right"), for: .normal)
                self.arrowLabel.tintColor = UIColor.black
                self.titleLabel.textColor = UIColor.black
            }
        }
    }
    
}
