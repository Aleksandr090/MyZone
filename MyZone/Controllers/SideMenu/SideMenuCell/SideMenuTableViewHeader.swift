//
//  SideMenuTableViewHeader.swift
//  MyZone
//

import UIKit

protocol SideMenuTableViewHeaderDelegate {
    func toggleSection(_ header: SideMenuTableViewHeader, section: Int)
}

class SideMenuTableViewHeader: UITableViewHeaderFooterView {

    var delegate: SideMenuTableViewHeaderDelegate?
    var section: Int = 0
    
    let lineView = UIView()
    let titleLabel = UILabel()
    let arrowImageView = UIImageView()
    let primaryImageView = UIImageView()

    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Content View
        contentView.backgroundColor = UIColor.AppTheme.MainBackground
        
        let marginGuide = contentView.layoutMarginsGuide
        
        // Line View
        lineView.backgroundColor = .darkGray
        lineView.contentMode = .scaleAspectFit
        contentView.addSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true

        // Primary Image
        primaryImageView.contentMode = .scaleAspectFit
        primaryImageView.tintColor = UIColor.AppTheme.TextColor
        contentView.addSubview(primaryImageView)
        primaryImageView.translatesAutoresizingMaskIntoConstraints = false
        primaryImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        primaryImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        primaryImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        primaryImageView.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
        
        // Arrow label
        arrowImageView.image = UIImage(named: "arrow")
        arrowImageView.tintColor = UIColor.AppTheme.TextColor
        arrowImageView.contentMode = .scaleAspectFit
        contentView.addSubview(arrowImageView)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        arrowImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        arrowImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        arrowImageView.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        
        // Title label
        contentView.addSubview(titleLabel)
        titleLabel.textColor = UIColor.AppTheme.TextColor
        titleLabel.font = UIFont(name: Fontname.SFProDisplayMedium, size: 16)
        titleLabel.textAlignment = L102Language.isRTL ? .right : .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: 10).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: primaryImageView.trailingAnchor, constant: 10).isActive = true
        
        //
        // Call tapHeader when tapping on this header
        //
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SideMenuTableViewHeader.tapHeader(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // Trigger toggle section when tapping on the header
    //
    @objc func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? SideMenuTableViewHeader else {
            return
        }
        
        delegate?.toggleSection(self, section: cell.section)
    }
    
    func setCollapsed(_ collapsed: Bool) {
        //
        // Animate the arrow rotation (see Extensions.swf)
        //
        if L102Language.isRTL {
            arrowImageView.rotate(collapsed ? 0.0 : -(.pi / 2))
        } else {
            arrowImageView.rotate(collapsed ? 0.0 : .pi / 2)
        }
    }
}

extension UIView {

    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")

        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards

        self.layer.add(animation, forKey: nil)
    }

}
