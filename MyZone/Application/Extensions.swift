//
//  Extensions.swift
//  MyZone
//

import Foundation
import UIKit

// MARK: - UIView extension for instantiating views from .xib files
extension UIView {
    class func instantiateFromNib() -> Self {
        return loadFromNib(viewType: self)
    }
    
    @IBInspectable var cornerRadiusValue: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidthValue: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColorValue: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    private class func loadFromNib<T: UIView>(viewType: T.Type) -> T {
        let url: NSURL! = NSURL(string: NSStringFromClass(viewType))
        return Bundle.main.loadNibNamed(url.pathExtension!, owner: nil, options: nil)?.first as! T
    }
    
    func addShadow(color: UIColor = .black,
                   opacity: Float = 0.1,
                   shadowRadius: CGFloat = 8.0,
                   shadowOffset: CGSize = CGSize(width: 1, height: 1)) {
        
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = shadowOffset
        self.layer.masksToBounds = false
    }
    
    func addShadow(cornerRadius: CGFloat = 6.5, offsets: CGSize = CGSize(width: 0, height: 8.0), shadowOpacity: Float = 0.2, color: CGColor = UIColor.black.cgColor, shadowRadius: CGFloat = 5.0) {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowColor = color
        self.layer.shadowOffset = offsets
        self.layer.shadowRadius = shadowRadius
    }
    
    func addShadow(top: Bool,
                   left: Bool,
                   bottom: Bool,
                   right: Bool,
                   opacity: Float = 0.2,
                   shadowRadius: CGFloat = 13.0,
                   showTopDim: Bool = false,
                   widthOffset: CGFloat = 0.0) {
        
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = opacity
        
        let path = UIBezierPath()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var viewWidth = self.frame.width
        var viewHeight = self.frame.height
        
        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if (!top) {
            y+=(shadowRadius + 9.0)
        }
        if showTopDim {
            y = 0
            y+=(7)
        }
        if (!bottom) {
            viewHeight-=(shadowRadius + 1.0)
        }
        if (!left) {
            x+=(shadowRadius + 1.0)
        }
        if (!right) {
            viewWidth-=(shadowRadius + 1.0)
        }
        
        // selecting top most point
        path.move(to: CGPoint(x: x, y: y))
        path.addLine(to: CGPoint(x: x, y: viewHeight))
        path.addLine(to: CGPoint(x: viewWidth+widthOffset, y: viewHeight))
        path.addLine(to: CGPoint(x: viewWidth+widthOffset, y: y))
        path.close()
        self.layer.shadowPath = path.cgPath
    }
    
    func setupCircularView() {
        //Numeric View Setup
        self.layer.cornerRadius = self.frame.height/2
        self.backgroundColor = UIColor.AppTheme.PinkColor
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}

/// Extend UITextView and implemented UITextViewDelegate to listen for changes
extension UITextView: UITextViewDelegate {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !self.text.isEmpty
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = !self.text.isEmpty
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
    
}

// MARK: - Bundle
extension Bundle {
    static var versionNumber: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    static var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

// MARK: - UITextField
extension UITextField {
    enum ViewType {
        case left, right
    }
    
    // (1)
    func setView(_ type: ViewType, with view: UIView) {
        if type == ViewType.left {
            leftView = view
            leftViewMode = .always
        } else if type == .right {
            rightView = view
            rightViewMode = .always
        }
    }
    
    @discardableResult
    func setView(_ view: ViewType, image: UIImage?, selectedImage: UIImage?, width: CGFloat = 70) -> UIButton {
        
        let containerVw : UIView = UIView(frame: CGRect(x:0, y:0, width: width, height: frame.height))
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: width - 10, height: frame.height))
        button.setImage(image, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.imageView!.contentMode = .scaleAspectFit
        containerVw.addSubview(button)
        setView(view, with: containerVw)
        return button
    }
}

extension String {
    func isEmail() -> Bool {
        if self.contains("..") || self.contains("@@") || self.contains(".@")
            || self.hasPrefix(".") || self.hasSuffix(".con") || self.hasSuffix(".") {
            return false
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    // MARK - Parse into NSDate
    
    func dateFromFormat(_ format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: self)
    }
   
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }    
    
}

extension Date {
    func getFormattedDate(_ format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
//
//extension Date {
//    /// 时间戳
//    /// - Usage:
//    /// - let ticks = Date().ticks
//    /// - print(ticks) // 636110903202288256
//    /// - let sticks = String(Date().ticks)
//    var ticks: UInt64 {
//        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
//    }
//
//    /// 用时间戳初始化
//    /// - parameter ticks: UInt64
//    /// - Usage:
//    /// - let date = Date(ticks: 636110903202288256)
//    init(ticks: UInt64) {
//        self.init(timeIntervalSince1970: Double(ticks)/10_000_000 - 62_135_596_800)
//    }
//}
