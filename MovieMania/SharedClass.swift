//
//  SharedClass.swift
//  MovieMania
//
//  Created by Jassi on 6/16/22.
//

import Foundation
import MBProgressHUD

struct SharedGlobalVariables {
    static var hud: MBProgressHUD? = nil
}

class SharedFunctions {
    class func showAlertDialog(controller:UIViewController, title: String, message: String, options: String..., completion: @escaping (Int) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (action) in
                completion(index)
            }))
        }
        controller.present(alertController, animated: true, completion: nil)
    }
}


// MARK : Extension of Global Shared functions
class ActivityIndicator{
    func showHudProgress(){
        SharedGlobalVariables.hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        SharedGlobalVariables.hud!.bezelView.color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        SharedGlobalVariables.hud!.bezelView.style = .blur
        SharedGlobalVariables.hud!.isHidden = false
    }
    
    func hideHudProgress(){
        SharedGlobalVariables.hud?.isHidden = true
    }
}
