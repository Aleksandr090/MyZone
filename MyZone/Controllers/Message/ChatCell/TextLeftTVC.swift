//
//  TextLeftTVC.swift
//  MyZone
//
//  Created by Apple on 25/02/22.
//

import UIKit

class TextLeftTVC: UITableViewCell {
    @IBOutlet weak var chatLeftMainView: UIView!
    @IBOutlet weak var lblleftText: UILabel!
    @IBOutlet weak var lblLeftTime: UILabel!
    
    @IBOutlet weak var leftViewWidth: NSLayoutConstraint!
    @IBOutlet weak var lblLeftWidth: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        chatLeftMainView.layer.cornerRadius = 10

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension UILabel {
    func textWidth() -> CGFloat {
        return UILabel.textWidth(label: self)
    }

    class func textWidth(label: UILabel) -> CGFloat {
        return textWidth(label: label, text: label.text!)
    }

    class func textWidth(label: UILabel, text: String) -> CGFloat {
        return textWidth(font: label.font, text: text)
    }

    class func textWidth(font: UIFont, text: String) -> CGFloat {
        return textSize(font: font, text: text).width
    }

    class func textHeight(withWidth width: CGFloat, font: UIFont, text: String) -> CGFloat {
        return textSize(font: font, text: text, width: width).height
    }

    class func textSize(font: UIFont, text: String, extra: CGSize) -> CGSize {
        var size = textSize(font: font, text: text)
        size.width = size.width + extra.width
        size.height = size.height + extra.height
        return size
    }

    class func textSize(font: UIFont, text: String, width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.numberOfLines = 0
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.size
    }

    class func countLines(font: UIFont, text: String, width: CGFloat, height: CGFloat = .greatestFiniteMagnitude) -> Int {
        // Call self.layoutIfNeeded() if your view uses auto layout
        let myText = text as NSString

        let rect = CGSize(width: width, height: height)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return Int(ceil(CGFloat(labelSize.height) / font.lineHeight))
    }

    func countLines(width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude) -> Int {
        // Call self.layoutIfNeeded() if your view uses auto layout
        let myText = (self.text ?? "") as NSString

        let rect = CGSize(width: width, height: height)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font], context: nil)

        return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
    }
}
