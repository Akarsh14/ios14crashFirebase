//
//  ActionButtonTableViewCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 23/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class ActionButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    
    var urlToOpen:URL?
    
    var tapHandler : ((String) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        button.layer.cornerRadius = 2.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func buttonTapped(_ sender: AnyObject) {
       
        if self.tapHandler != nil {
            self.tapHandler!((urlToOpen?.absoluteString)!)
        }
        return
        
        
        
        if UIApplication.shared.canOpenURL(urlToOpen!) {
            UIApplication.shared.openURL(urlToOpen!)
        }
        else{
            if self.tapHandler != nil {
                self.tapHandler!((urlToOpen?.absoluteString)!)
            }
        }
    }
    
}
