//
//  EditQuoteTableCell.swift
//  Woo_v2
//
//  Created by Suparno Bose on 20/07/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit

class EditQuoteTableCell: UITableViewCell {

    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var quoteTextView: UITextView!
    
    @IBOutlet weak var quoteCounterLabel: UILabel!
    
    var textUpdateHandler : ((String) -> ())?
    
    var personalQouteTappedHandler : (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        LoginModel.sharedInstance().personalQuoteText = "Introduce yourself with your story. Make it genuine and interesting.\n\nKeep it clean! No phone, messenger details, web links, abusive or explicit content please."
        LoginModel.sharedInstance().personalQuoteMaxCharLength = 300
        LoginModel.sharedInstance().personalQuoteMinCharLength = 0
        
        if let hintText = LoginModel.sharedInstance().personalQuoteText{
            hintLabel.text = hintText
        }
        else{
            hintLabel.text = "Introduce yourself with your story. Make it genuine and interesting.\n\nKeep it clean! No phone, messenger details, web links, abusive or explicit content please."
        }
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func closeKeyBoard() {
        quoteTextView.resignFirstResponder()
    }
}

extension EditQuoteTableCell:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        
        let finalTextLength       = quoteTextView.text.count + text.count
        
        if text == "\n" {
            self.quoteTextView.resignFirstResponder()
        }
        LoginModel.sharedInstance().personalQuoteMaxCharLength = KDefaultLengthForQuote
        
        if text.count == 0 {
            return true
            
        }else if finalTextLength <= LoginModel.sharedInstance().personalQuoteMaxCharLength{
            
            let pendingTextLength : Int  = LoginModel.sharedInstance().personalQuoteMaxCharLength - textView.text.count
            
            //  (pendingTextLength != 0 && ![APP_Utilities stringContainsEmoji:text])
            
            if pendingTextLength != 0 && !(Utilities.sharedUtility() as AnyObject).stringContainsEmoji(text) {
                if text.count > pendingTextLength{
                //let tmpText = (Utilities.sharedUtility() as AnyObject).substring(to: pendingTextLength, with:text)
                    let tmptext = (text as NSString).substring(to: pendingTextLength)
                    quoteTextView.text = String(format: "\(quoteTextView.text)\(tmptext)")
                
                quoteCounterLabel.text = "\(LoginModel.sharedInstance().personalQuoteMaxCharLength - quoteTextView.text.utf16.count)"
                }
            }
            return true
        }
        return false
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        personalQouteTappedHandler!()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView){
        if textView.text.count > 0{
            hintLabel.isHidden = true
        }
        else{
            hintLabel.isHidden = false
        }
        quoteCounterLabel.text = "\(LoginModel.sharedInstance().personalQuoteMaxCharLength - quoteTextView.text.count)"
        if textUpdateHandler != nil {
            textUpdateHandler!(quoteTextView.text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.quoteTextView.endEditing(true)
        return false
    }
}
