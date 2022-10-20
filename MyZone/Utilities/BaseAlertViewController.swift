//
//  BaseAlertViewController.swift
//  PrivateLocator
//
//  Created by Admin on 28/10/20.
//  Copyright © 2020 Gaurav Kive. All rights reserved.
//

import UIKit

enum CustomAlertAnimationType {
    case    dissolve
    case    transform
    case    spring
}

class BaseAlertViewController: BaseViewController {
    
    //MARK:- On your custom alert's action you just need to call dismiss with completion block, in this completion block do your need full delegate calls or completion handler, no need to remove any alert's view in your main view controller's class.
    
    //MARK:- You have to connect this IBOutlet into your custom container view in storyboard in oreder to deal with animation apart from dissolve type as this class will inherited by your custom Alert class.
    @IBOutlet weak var viewPopUp        :   UIView!
    @IBOutlet weak var blurView           :   UIVisualEffectView!
    
    var selectedAnimationType   :   CustomAlertAnimationType =   .dissolve
    public var onClickActionOK:(Bool)->() = {_ in}
    public var onClickActionWithValue:(String)->() = { _ in}
    
    //MARK:- Life Cycel Methods
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.providesPresentationContextTransitionStyle  = true
        self.definesPresentationContext            = true
        self.modalPresentationStyle  = .overFullScreen // .overFullScreen as it will cover tab Bar too, otherwise use overCurrentContext or according to your need
        self.modalTransitionStyle                                              = .crossDissolve
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.blurView != nil {
            self.blurView.alpha = 0.4//1.0
            self.blurView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        }
        
        switch selectedAnimationType {
        case .transform:
            self.showTransformAnimation()
            break
        case .spring:
            self.showSpringAnimation()
            break
        default:
            print("Dissolve")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        switch selectedAnimationType {
        case .transform:
            self.hideTransformAnimation()
            break
        case .spring:
            self.hideSpringAnimation()
            break
        default:
            print("Dissolve")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//MARK:- Show Alert Methods
//MARK:-
extension BaseAlertViewController {
    
    func presentAlertViewControllerOn(vc : UIViewController, with animationType : CustomAlertAnimationType){
        
        selectedAnimationType   = animationType
        
        DispatchQueue.main.async {
            switch animationType {
            case .dissolve:
                self.showAlertWithDissolveAnimationOn(vc: vc)
                break
            case  .transform :
                self.showAlertWithTransformAnimationOn(vc: vc)
                break
            case   .spring :
                self.showAlertWithSpringAnimationOn(vc: vc)
                break
            }
        }
    }
    
    func presentAlertViewControllerOn(vc : UIViewController , and animationType : CustomAlertAnimationType , with backgroundColor : UIColor = .white , and alpha : CGFloat = 0.0){
        
        selectedAnimationType   = animationType
        
        DispatchQueue.main.async {
            switch animationType {
            case .dissolve:
                self.showAlertWithDissolveAnimationOn(vc: vc, with: backgroundColor, and: alpha)
                break
            case  .transform :
                self.showAlertWithTransformAnimationOn(vc: vc, with: backgroundColor, and: alpha)
                break
            case   .spring :
                self.showAlertWithSpringAnimationOn(vc: vc, with: backgroundColor, and: alpha)
                break
            }
        }
        
    }
    
    
    //MARK:- Show Dissolve Animation Alert on View Controller
    private func showAlertWithDissolveAnimationOn(vc : UIViewController){
        self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
        vc.present(self, animated: true, completion: nil)
    }
    
    //MARK:- Show Custom Dissolve Animation Alert on View Controller
    private func showAlertWithDissolveAnimationOn(vc : UIViewController, with backgroundColor : UIColor = .black , and alpha : CGFloat = 0.15){
        self.view.backgroundColor = backgroundColor.withAlphaComponent(alpha)
        vc.present(self, animated: true, completion: nil)
    }
    
    //MARK:- Show TransformAnimation Alert on View Controller
    private func showAlertWithTransformAnimationOn(vc : UIViewController){
        self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
        vc.present(self, animated: true, completion: nil)
    }
    
    //MARK:- Show Custom TransformAnimation Alert on View Controller
    private func showAlertWithTransformAnimationOn(vc : UIViewController, with backgroundColor : UIColor = .black , and alpha : CGFloat = 0.15){
        self.view.backgroundColor = backgroundColor.withAlphaComponent(alpha)
        vc.present(self, animated: true, completion: nil)
    }
    
    //MARK:- Show Spring Animation Alert on View Controller
    private func showAlertWithSpringAnimationOn(vc : UIViewController ){
        self.view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
        vc.present(self, animated: true, completion: nil)
    }
    
    //MARK:- Show Custom Spring Animation Alert on View Controller
    private func showAlertWithSpringAnimationOn(vc : UIViewController, with backgroundColor : UIColor = .black , and alpha : CGFloat = 0.15){
        self.view.backgroundColor = backgroundColor.withAlphaComponent(alpha)
        vc.present(self, animated: true, completion: nil)
    }
    
}

//MARK:- Helper Methods for Transform Animation
//MARK:-
extension BaseAlertViewController {
    
    //MARK:- Show / Hide TransformAnimation
    private func showTransformAnimation(){
        if selectedAnimationType == .transform {
            
            if let animatedView    =   self.viewPopUp {
                animatedView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01);
                UIView.animate(withDuration: 0.25 ,
                               animations: {
                                animatedView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                                animatedView.alpha = 1
                },completion: { finish in
                    self.viewPopUp.isHidden = false
                    
                    UIView.animate(withDuration: 0.15){
                        animatedView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        UIView.animate(withDuration: 0.15){
                            animatedView.transform = CGAffineTransform.identity
                        }
                    }
                })
            } else {
                print("viewPopUp outlet is not connected , desired animation will not appear")
            }
        }
    }
    
    private func hideTransformAnimation(){
        
        if selectedAnimationType == .transform {
            if let animatedView = self.viewPopUp  {
                
                UIView.animate(withDuration: 0.1 ,
                               animations: {
                                animatedView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                },completion: { finish in
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
                        animatedView.alpha = 0.0
                        animatedView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                    }, completion: { (finished) in
                        UIView.animate(withDuration: 0.1, animations: {
                            animatedView.alpha = 0.0
                        }, completion: { (finished) in
                            animatedView.isHidden = true;
                        })
                    })
                })
            } else {
                print("viewPopUp outlet is not connected , desired animation will not appear")
            }
        }
    }
    
    
    //MARK:- Show / Hide Spring Animation
    private func showSpringAnimation(){
        
        if selectedAnimationType == .spring {
            
            if let animatedView    =   self.viewPopUp {
                
                animatedView.center   =   CGPoint(x: self.view.center.x, y: self.view.frame.height + animatedView.frame.height/2)
                
                UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIView.AnimationOptions(rawValue: 0), animations: {
                    animatedView.center   =   self.view.center
                }) { (success) in
                }
            } else {
                print("viewPopUp outlet is not connected , desired animation will not appear")
            }
        }
    }
    
    private func hideSpringAnimation(){
        
        if selectedAnimationType == .spring {
            if let animatedView    =   self.viewPopUp {
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.alpha = 0
                }, completion: { (completed) in
                })
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: UIView.AnimationOptions(rawValue: 0), animations: {
                    animatedView.center = CGPoint(x: self.view.center.x, y: self.view.frame.height + animatedView.frame.height/2)
                }, completion: { (completed) in
                })
            } else {
                print("viewPopUp outlet is not connected , desired animation will not appear")
            }
        }
    }
}
