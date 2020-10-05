//
//  UIViewControllerExtension.swift
//  reignposts
//
//  Created by Daniel Durán Schütz on 2/10/20.
//

import Foundation
import UIKit

extension UIViewController{
    
    internal class func instantiateFromXIB<T:UIViewController>() -> T{
        let xibName = T.stringRepresentation
        let vc = T(nibName: xibName, bundle: nil)
        return vc
    }
    
    func pushVc(uiViewController: UIViewController, animated:Bool = true, navigationBarIsHidden:Bool, presentStyle:UIModalPresentationStyle = .fullScreen, transitionStyle:UIModalTransitionStyle = .coverVertical){
        
        uiViewController.modalPresentationStyle = presentStyle
        self.navigationController?.modalPresentationStyle = presentStyle
        self.navigationController?.modalTransitionStyle = transitionStyle
        
        if navigationBarIsHidden{
            self.navigationController?.navigationBar.isHidden = true
        }else{
            self.navigationController?.navigationBar.isTranslucent = false
        }
        self.navigationController?.pushViewController(uiViewController, animated: animated)
    }
    
    @objc internal func backButton(image:String = "back", text:String = "Back"){
        let buttonImage = UIButton(type: .system)
        buttonImage.tintColor = UIColor.lightGray
        var backImage = UIImage(named: image)
        backImage = resizeImage(image: backImage!, newWidth: 16)
        buttonImage.setImage(backImage, for: .normal)
        buttonImage.addTarget(self, action: #selector(navigateBack), for: .touchUpInside)
        let menuBarItemImage = UIBarButtonItem(customView: buttonImage)
        menuBarItemImage.customView?.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonText = UIButton(type: .system)
        buttonText.setTitle(text, for: .normal)
        buttonText.tintColor = self.traitCollection.userInterfaceStyle == .dark ? .white : .black
        buttonText.titleLabel?.font = UIFont(name: "Arial", size: 19)
        buttonText.addTarget(self, action: #selector(navigateBack), for: .touchUpInside)
        let menuBarItemText = UIBarButtonItem(customView: buttonText)
        
        navigationItem.setLeftBarButtonItems([menuBarItemImage, menuBarItemText], animated: false)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    @objc internal func navigateBack(){
        if isModal {
            dismiss(animated: true, completion: nil)
        }else{
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    var isModal:Bool {
        if presentingViewController != nil {
            return true
        }
        if presentingViewController?.presentedViewController == self {
            return true
        }
        if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        }
        if tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
}
