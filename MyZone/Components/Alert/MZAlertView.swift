//
//  MZAlertView.swift
//  MyZone
//

import UIKit

// MARK: - Enums and data objects

enum MZAlertViewType {
    case none
    case error
    case notification
    case twoFactorAuthentication
    case forgotPassword
    case scanLimitReached
}

enum MZAlertViewActionType {
    case primary
    case secondary
    case secondaryRounded
}

enum MZAlertViewDisplayMode {
    case popUp
    case fullScreen
}

enum MZAlertViewBackgroundColorType {
    case lightDark
    case dark

}

struct MZAlertViewActionItem {
    let title: String
    let type: MZAlertViewActionType
    let action: (() -> Void)?
    
    init(title: String, type: MZAlertViewActionType, action: (() -> Void)? = nil) {
        self.title = title
        self.type = type
        self.action = action
    }
}

struct MZAlertViewDataObject {
    let title: String
    let message: String
    let type: MZAlertViewType
    let shouldHideWhenTappingOutside: Bool
    let code: String?
    var isAlertThemeChanged = false
    let textHighlightRange: NSRange?
    let displayMode: MZAlertViewDisplayMode
    let backgroundColorType: MZAlertViewBackgroundColorType

    init(title: String?, message: String?, type: MZAlertViewType, code: String?, isAlertThemeChanged: Bool? = false, textHighlightRange: NSRange? = nil, shouldHideWhenTappingOutside: Bool, displayMode: MZAlertViewDisplayMode, backgroundColorType: MZAlertViewBackgroundColorType) {
        self.title = title ?? ""
        self.message = message ?? ""
        self.type = type
        self.code = code
        self.isAlertThemeChanged = isAlertThemeChanged ?? false
        self.textHighlightRange = textHighlightRange
        self.shouldHideWhenTappingOutside = shouldHideWhenTappingOutside
        self.displayMode = displayMode
        self.backgroundColorType = backgroundColorType
    }
}

// MARK: - AlertView

final class MZAlertView: UIView {
    
    // MARK: - Outlets
    @IBOutlet private weak var tapGestureView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet private weak var buttonStackView: UIStackView!

    // MARK: - Properties
    
    private var actions = [MZAlertViewActionItem]()
    
    private var dataObject: MZAlertViewDataObject? {
        didSet {
            if let dataObject = dataObject {

//                if dataObject.type == .notification {
////                    let attributedString = PAMUtilManager.shared.getAttributedString(withFont: .app_theme_bold20_medium20, textColor: .tealColor, lineHeight: 28, characterSpace: PAMDefaultTheme.getCharacterSpace(withName: .app_theme_minus_pointEight_minus_pointTwo), alignment: .center)
//                    self.titleLabel?.attributedText = NSAttributedString(string: dataObject.title, attributes: attributedString)
//                }
//                else {
                    let attributedString = NSMutableAttributedString(string: dataObject.title)
                    let paragraphStyle = NSMutableParagraphStyle()

//                    paragraphStyle.lineSpacing = PAMDefaultTheme.getLineSpacing(withName: .medium)
                    paragraphStyle.alignment = .center
                    attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
                    self.titleLabel?.attributedText = attributedString
//                }

                self.setupMessageLabel(message: dataObject.message, type: dataObject.type, highlightRange: dataObject.textHighlightRange)

                //Alert element theme for new market
                if dataObject.isAlertThemeChanged {
                    messageLabel.font = UIFont(name: Fontname.SFProDisplayRegular, size: 15)
                    titleLabel.font = UIFont(name: Fontname.SFProDisplayBold, size: 15)
                }

                if dataObject.displayMode == .fullScreen {
//                    containerView.snp.updateConstraints { make in
//                        make.leading.equalToSuperview().offset(0)
//                        make.trailing.equalToSuperview().offset(0)
//                    }
                }
            }
        }
    }
    
    // MARK: - Initialization
    
    private override init(frame: CGRect) {
        super.init(frame: .zero)
        
    }
    
    private init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// This method creates an alertview and sets up the ui of it from the given parameters
    /// pop up type, title, message, code(it's for a unique design for warnings in code scanning screens)
    /// and an option if the pop up should be dismissed by tapping on the background
    ///
    /// Parameters:
    ///     - type: MZAlertViewType
    ///     - title: String
    ///     - message: String
    ///     - code: String
    ///     - shouldHideWhenTappingOutside: String

    class func createAlertView(type: MZAlertViewType, title: String? = nil, message: String? = nil, code: String? = nil, isAlertThemeChanged: Bool? = false, textHighlightRange: NSRange? = nil, shouldHideWhenTappingOutside: Bool? = true, displayMode: MZAlertViewDisplayMode? = .popUp, backgroundColorType: MZAlertViewBackgroundColorType? = .lightDark) -> MZAlertView {
        let alertView = MZAlertView.instantiateFromNib()
        alertView.dataObject = MZAlertViewDataObject(title: title, message: message, type: type, code: code, isAlertThemeChanged: isAlertThemeChanged, textHighlightRange: textHighlightRange, shouldHideWhenTappingOutside: shouldHideWhenTappingOutside ?? false, displayMode: displayMode ?? .popUp, backgroundColorType: backgroundColorType ?? .lightDark)
        return alertView
    }
    
    // MARK: - setting up UI details
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.containerView?.cornerRadiusValue = 24
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOutOfPopUp))
        tapGestureView?.addGestureRecognizer(tapGestureRecognizer)
        
        self.titleLabel?.textColor = UIColor.AppTheme.TextColor
        self.titleLabel?.font = UIFont(name: Fontname.SFProDisplayBold, size: 15)
        
    }
    
    // MARK: - Private helper methods for setting up UI
    private func setupMessageLabel(message: String, type: MZAlertViewType, highlightRange: NSRange?) {
        guard let messageLabel = self.messageLabel else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        let attributedString = NSMutableAttributedString(string: message)
//        paragraphStyle.lineSpacing = PAMDefaultTheme.getLineSpacing(withName: .medium)
       
//        if type == .forgotPassword {
//            messageLabel.font = PAMDefaultTheme.getFont(withName: .subtitle)
//            messageLabel.textColor = PAMDefaultTheme.getColor(withName: .blackColor)
//        } else if PAMUtilManager.checkVariant {
//            messageLabel.textColor = PAMDefaultTheme.getColor(withName: .app_theme_black_indigo)
//            if dataObject?.displayMode == .fullScreen {
//                messageLabel.font = PAMDefaultTheme.getFont(withName: .app_theme_regular12_regular15)
//            } else {
//                messageLabel.font = PAMDefaultTheme.getFont(withName: .titleMenu)
//            }
//        } else if PAMUtilManager.shared.isSpainMarket() {
//            messageLabel.font = PAMDefaultTheme.getFont(withName: .titleMenu)
//            messageLabel.textColor = PAMDefaultTheme.getColor(withName: .blackColor)
//            paragraphStyle.lineSpacing = PAMDefaultTheme.getLineSpacing(withName: .extraSmall)
//        } else {
            messageLabel.font = UIFont(name: Fontname.SFProDisplayRegular, size: 15)
        messageLabel.textColor = UIColor.AppTheme.TextColor
//        }
       
        paragraphStyle.alignment = .center
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        // check if highlight range exists
        if let highlightRange = highlightRange {
            // define highlight range for attributed string
            attributedString.addAttributes(
                [
                    NSAttributedString.Key.foregroundColor: UIColor.AppTheme.TextColor,
                    NSAttributedString.Key.font: UIFont(name: Fontname.SFProDisplayRegular, size: 15)
                ],
                range: highlightRange
            )
        }
        messageLabel.attributedText = attributedString
    }
    
    private func addButton(actionItem: MZAlertViewActionItem) {
        var button: MZButton
        
//        if actionItem.type == .primary {
//            button = PAMButtonCTA(withBackgroundColor: .orangeColor)
//            button.setTitleColor(PAMDefaultTheme.getColor(withName: .whiteColor), for: .normal)
//        } else if actionItem.type == .secondaryRounded {
//            button = PAMButtonCTA()
//            button.defaultTextColor =  PAMDefaultTheme.getColor(withName: .tealColor)
//            button.layer.borderColor = PAMDefaultTheme.getColor(withName: .lightestTealColor).cgColor
//            button.layer.borderWidth = 2.0
//        } else {
            button = MZButton()
//            button.backgroundColor = PAMDefaultTheme.getColor(withName: .clearColor)
//            button.defaultTextColor =  PAMDefaultTheme.getColor(withName: .tealColor)
//            button.setTitleColor(PAMDefaultTheme.getColor(withName: .tealColor).withAlphaComponent(PAMDefaultTheme.highlightedButtonTitleAlpha), for: .highlighted)
//        }
        
        button.setTitle(actionItem.title, for: .normal)
        button.titleLabel?.font = UIFont(name: Fontname.SFProDisplayBold, size: 15)
        button.tag = actions.count - 1
        button.addTarget(self, action: #selector(actionButtonPressed(sender:)), for: .touchUpInside)
        
        // add the button to stackView
        buttonStackView?.addArrangedSubview(button)
    }

    @objc private func actionButtonPressed(sender: UIButton) {
        let actionItem = actions[sender.tag]
        
        if sender.title(for: .normal) == actionItem.title, let action = actionItem.action {
            action()
        }
        
        self.hide()
    }
    
    @objc private func tapOutOfPopUp() {
        if let isCancelAvailable = dataObject?.shouldHideWhenTappingOutside, isCancelAvailable, dataObject?.displayMode == .popUp {
            self.hide()
        }
    }
    
    // MARK: - Public methods
    
    func addAction(actionItem: MZAlertViewActionItem) {
        self.actions.append(actionItem)
        addButton(actionItem: actionItem)
    }
    
    private func updateFocusOnSameField(in field: UIView? = nil) {
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: field)
        }
    }
    
    func show(alertShownCallback: (() -> Void)? = nil, customBackground: UIColor? = nil) {
        // get all application windows
        tapGestureView.isAccessibilityElement = true
        updateFocusOnSameField(in: tapGestureView )
//        PAMUtilManager.shared.postVoiceOverNotification(message: "\(self.titleLabel.text ?? "") \(self.messageLabel.text ?? "") ", delay: 1.0)
        let windows = UIApplication.shared.windows
        
        // by default set first app window, which will be UIWindow
        var appWindow = windows.first
        
        // iterate through all windows
//        for windowItem in windows {
//            if !(windowItem is ABKInAppMessageWindow) {
//                // and select the one which is not ABKInAppMessageWindow
//                appWindow = windowItem
//                break
//            }
//        }
        if let window = appWindow {
            translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(self)
//            self.snp.makeConstraints { make in
//                make.top.equalToSuperview()
//                make.bottom.equalToSuperview()
//                make.leading.equalToSuperview()
//                make.trailing.equalToSuperview()
//            }
        }
        if self.dataObject?.displayMode == .popUp {
            self.backgroundColor = .clear
            self.containerView?.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        } else {
            self.backgroundColor = .white
            self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }
        
        UIView.animate(withDuration: self.dataObject?.displayMode == .popUp ? 0.2 : 0.0, animations: {
            if self.dataObject?.displayMode == .popUp {
                self.backgroundColor = customBackground ?? (self.dataObject?.backgroundColorType == MZAlertViewBackgroundColorType.dark ? UIColor(white: 0.0, alpha: 0.6) : UIColor(white: 0.0, alpha: 0.2))
            }
        }, completion: { finished in
            if finished {
                UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: .curveEaseIn, animations: {
                    if self.dataObject?.displayMode == .popUp {
                        self.containerView?.transform = CGAffineTransform.identity
                    } else {
                        self.transform = CGAffineTransform.identity
                    }
                }, completion: { finished in
                    if finished, let callBack = alertShownCallback {
                        callBack()
                    }
                })
            }
        })
    }
    
    func hide() {
        UIView.animate(withDuration: 0.12, animations: {
            self.containerView?.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            self.backgroundColor = .clear
        }, completion: { finished in
            if finished {
                self.removeFromSuperview()
            }
        })
    }
}
