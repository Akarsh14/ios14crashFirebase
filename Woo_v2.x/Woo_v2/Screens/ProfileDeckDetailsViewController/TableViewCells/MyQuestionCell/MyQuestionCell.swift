//
//  MyQuestionCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 22/08/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit

class MyQuestionCell: UITableViewCell {

    var mangeHandler : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func manage(_ sender: AnyObject) {
        if mangeHandler != nil {
            mangeHandler!()
        }
    }
}
