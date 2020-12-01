//
//  NewMatchViewController.swift
//  Woo_v2
//
//  Created by Suparno Bose on 01/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class NewMatchViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var matchImageView: UIImageView!
    
    @IBOutlet weak var otherActivityButtonIcon: UIImageView!
    
    @IBOutlet weak var otherActivityButtonLabel: UILabel!
    
    var matchData : NSDictionary?
    
    var url : URL?
    
    var buttonType : OverlayButtonType = .Keep_Swiping
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.5, delay: 0.5, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.alpha = 1.0
            
            }, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        matchImageView.layer.cornerRadius = matchImageView.frame.size.width/2
        matchImageView.layer.shadowOffset = CGSize(width: 2, height: 2)
        matchImageView.layer.shadowColor = UIColor.black.cgColor
        
        self.updateViewWithMatchData()
    }
    
    func updateViewWithMatchData() {
        if matchData != nil {
            if matchData!["matchEventDto"] != nil {
                matchData = matchData!["matchEventDto"] as? NSDictionary
            }
            
            if let title = matchData!["title"] {
                self.titleLabel.text = title as? String
            }
            else{
                self.titleLabel.text = ""
            }
            if let text = matchData!["text"] {
                var yourString:String = text as! String
                yourString = yourString.replacingOccurrences(of: "/", with: "")
                let componentsArray = yourString.components(separatedBy: "<b>")
                yourString = yourString.replacingOccurrences(of: "<b>", with: "")
                if componentsArray.count > 2 {
                    let boldedString1 = componentsArray[1]
                    let boldedString2 = componentsArray[2]
                    
                    let lAttribute = [ NSAttributedString.Key.font: UIFont(name: "Lato-Bold", size: 17.0)!]
                    let lString = NSMutableAttributedString(string: boldedString1, attributes: lAttribute)
                    let attrString = NSAttributedString(string: boldedString2)
                    lString.append(attrString)
                    
                    self.textLabel.attributedText = lString
                }
                else{
                    self.textLabel.text = yourString
                }
            }
            
            if let url = matchData!["requesterProfilePicture"] {
                matchImageView.sd_setImage(with: URL(string:(url as! String)))
            }
            
            otherActivityButtonLabel.text = buttonType.rawValue
            
            otherActivityButtonIcon.image = UIImage(named: buttonType.buttonIcon())
        }
    }
    
    @IBAction func closeOverlay(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chattingButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func otherActivityButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
