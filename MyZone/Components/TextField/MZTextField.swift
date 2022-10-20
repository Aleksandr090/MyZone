//
//  MZTextField.swift
//  MyZone
//

import UIKit

class MZTextField: UITextField {

    private let placeholderTextLayer: CATextLayer = CATextLayer()
    private var placeHolderOriginalPosition: CGPoint = CGPoint.zero
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.textColor = UIColor.AppTheme.TextColor
        self.font = UIFont(name: Fontname.SFProDisplayRegular , size: 15)
        self.tintColor = UIColor.AppTheme.PinkColor
        self.setLeftPaddingPoints(20)
        self.setRightPaddingPoints(20)
        
        placeholderTextLayer.font = UIFont(name: Fontname.SFProDisplayRegular , size: 15)
//        placeholderTextLayer.fontSize = PAMDefaultTheme.FontSize.app_theme_sixteen_seventeen.rawValue
//        placeholderTextLayer.string = self.customPlaceholderText
        placeholderTextLayer.foregroundColor = UIColor.AppTheme.PlaceholderColor.cgColor
        placeholderTextLayer.contentsScale = UIScreen.main.scale
        placeholderTextLayer.frame = CGRect(x: 0.0, y: (self.frame.height - 18.0) / 2.0, width: self.bounds.width, height: 18.0)
        placeHolderOriginalPosition = placeholderTextLayer.position
        self.layer.addSublayer(placeholderTextLayer)
                
        // Add background Shadow
//        self.backgroundColor = UIColor.white
        self.layer.masksToBounds = false
        //self.layer.shadowColor = UIColor.AppTheme.ShadowColor.cgColor
        //self.layer.shadowOffset = CGSize(width: 0, height: 0)
        //self.layer.shadowOpacity = 1.0
        self.layer.cornerRadius = 4
    }

}


// MARK: - UITextField Extensions
extension UITextField {

    // add left padding to UITextField
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    // add right padding to UITextField
    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
}
