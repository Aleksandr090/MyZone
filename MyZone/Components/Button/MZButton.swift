//
//  MZButton.swift
//  MyZone
//

import UIKit

class MZButton: UIButton {

    // UI - Metrics & Styling
    let defaultCornerRadiusDivisor: CGFloat = 2.0 // Default corner radius divisor
    var defaultFont = UIFont(name: Fontname.SFProDisplayBold, size: 16)// Default font
    var defaultTextColor = UIColor.AppTheme.TextReverseColor // Default text color
    var defaultCornerRadius: CGFloat = 4.0 // Default Corner Radius
    var defaultBackgroundColor = UIColor.AppTheme.PinkColor // Default text color

    enum MZButtonType {
        case normal
        case emptyWithBorder
        case imageWithText
    }
    
    var type: MZButtonType = .normal
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    // MARK: - Lifecycle
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        switch type {
//        case .normal:
//            break
//        case .emptyWithBorder:
//            break
//        case .imageWithText:
//            break
//        }
//    }

    /// Designated initializer, with theme
    /// background parameter
    ///
    /// - Parameter backgroundColor: Theme background color to set
    convenience init(withBackgroundColor backgroundColor: UIColor) {
        self.init()
        
        // Set provided
        self.backgroundColor = UIColor.AppTheme.PinkColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        // Default Styling
        layer.cornerRadius = defaultCornerRadius
        self.titleLabel?.font = defaultFont
        self.isAccessibilityElement = false
        self.accessibilityLabel = self.titleLabel?.text
        self.setTitleColor(defaultTextColor, for: .normal)
        self.backgroundColor = defaultBackgroundColor

//        if isImageButton {
//            self.titleEdgeInsets.left = 10.0
//        }
    }
}
