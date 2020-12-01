//
//  DeleteSubmitFeedbackViewController.swift
//  Woo_v2
//
//  Created by Akhil Singh on 08/02/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit

class DeleteSubmitFeedbackViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var textViewPlaceHolderLabel: UILabel!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var congratsImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        animateCongratsImageView()
        // Do any additional setup after loading the view.
    }

    private func animateCongratsImageView(){
        let image1 = UIImage(named: "congratulations1")
        let image2 = UIImage(named: "congratulations2")
        let arrayOfImages = NSArray(objects: image1!,image2!)
        congratsImageView.animationImages = arrayOfImages as? [UIImage]
        congratsImageView.animationDuration = 1.0
        congratsImageView.animationRepeatCount = 0
        congratsImageView.startAnimating()
        
    }
    
    @IBAction func submitAndDelete(_ sender: Any) {
        deleteAccount()
    }
    
    private func deleteAccount(){
        
        // Srwve Event
        UIApplication.shared.sendAction(#selector(self.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if !(Utilities.sharedUtility() as AnyObject).reachable() {
            self.showSnackBar(NSLocalizedString("No internet connection", comment: "No internet connection"))
            return
        }
        (Utilities.sharedUtility() as AnyObject).sendSwrveEvent(withScreenName: "MyPrefAppSettings", withEventName: "3-MyPreferences.MyPrefAppSettings.MAP_DeleteAccount_Select_Yes")
        
        DiscoverProfileCollection.sharedInstance.myProfileData = nil
        DiscoverProfileCollection.sharedInstance.clearAllData()
        
        let trimmedEmailString = emailTextField.text?.trimmingCharacters(in: .whitespaces)
        let trimmedPhoneNumberString = phoneNumberTextField.text?.trimmingCharacters(in: .whitespaces)
        let trimmedCommentsString = commentsTextView.text.trimmingCharacters(in: .whitespaces)


        AppSettingsApiClass.deleteUser(withUserComment: trimmedCommentsString, withEmail: trimmedEmailString, andPhoneNumber: trimmedPhoneNumberString, andDeleteFeedback: true, withCompletionBlock: {
            (success, response, statusCode) in
        })
        
        (Utilities.sharedUtility() as AnyObject).deleteAccount_Temp{ (success) in
            if(success){
                //                    self.dismiss(animated: true) {
                self.navigationController?.popViewController(animated: true)
                WooScreenManager.sharedInstance.loadLoginView()
                /* Removed Tutorial
                 UserDefaults.standard.set(false, forKey: kIsTutorialShown)
                 */
                //                    }
            }
        }
        
        UserDefaults.standard.removeObject(forKey: "tagTrainingShowExpiry")
        UserDefaults.standard.removeObject(forKey: "hasSeenTutorialForPreferences")
        UserDefaults.standard.removeObject(forKey: "hasSeenIntroductionForSearchTags")
        UserDefaults.standard.removeObject(forKey: "hasVisitedSkippedSection")
        
        UserDefaults.standard.synchronize()
        
    }
    
    private  func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }
    
    internal func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0{
            textViewPlaceHolderLabel.isHidden = true
        }
        else{
            textViewPlaceHolderLabel.isHidden = false
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
