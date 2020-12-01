//
//  WizardScreensCalculator.swift
//  Woo_v2
//
//  Created by Akhil Singh on 09/01/18.
//  Copyright © 2018 Vaibhav Gautam. All rights reserved.
//

import UIKit


class WizardScreensCalculator: NSObject {

    var totalNumberOfWizardScreens = 0
    @objc var currentWizardScreen = 0
    @objc var wizardScreenArray:NSMutableArray = NSMutableArray()
    @objc static let sharedInstance = WizardScreensCalculator()
    
    var lastViewController = UIViewController()
    
    var editProfileApiCompletionHandler : ((Bool) -> ())?

    var wizardScreenNavigationController : UINavigationController?

    
    var isCropperVisible = false
    var cropPickerNavigationController : UINavigationController?
    
    
    func getNextScreenToShowForIndex(_ index:Int) -> String{
        let nextView = wizardScreenArray.object(at: index) as! String
        return nextView
    }
        
    func updateWizardScreenArrayBasedOnDataAlreadyPresent(){
        currentWizardScreen = 0
        if DiscoverProfileCollection.sharedInstance.myProfileData != nil{
            
        if ((LoginModel.sharedInstance()?.userRelationshipTagsAvailable)! && (LoginModel.sharedInstance()?.userLifestyleTagsAvailable)!){
                if wizardScreenArray.contains("MY_TAGS_RELATIONSHIP_LIFESTYLE"){
                    wizardScreenArray.remove("MY_TAGS_RELATIONSHIP_LIFESTYLE")
                }
            }
            
        if ((LoginModel.sharedInstance()?.userZodiacTagsAvailable)!){
                if wizardScreenArray.contains("MY_TAGS_ZODIAC"){
                    wizardScreenArray.remove("MY_TAGS_ZODIAC")
                }
            }
            
            
        if Int(LoginModel.sharedInstance().tagsCountThresholdForWizard) <= (DiscoverProfileCollection.sharedInstance.myProfileData?.tags.count) ?? 0{
                if wizardScreenArray.contains("MY_TAGS"){
                    wizardScreenArray.remove("MY_TAGS")
                }
            }
            
        if Int(LoginModel.sharedInstance().photoCountThresholdForWizard) <= (DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.countOfApprovedPhotos()) ?? 0{
            if wizardScreenArray.contains("MY_PHOTOS"){
                wizardScreenArray.remove("MY_PHOTOS")
            }
        }
        
        if DiscoverProfileCollection.sharedInstance.myProfileData?.personalQuote != nil && (DiscoverProfileCollection.sharedInstance.myProfileData?.personalQuote?.count)! > 0{
            if wizardScreenArray.contains("MY_STORY"){
                wizardScreenArray.remove("MY_STORY")
            }
        }
        
        var selectedReligion = false
        if let religion = DiscoverProfileCollection.sharedInstance.myProfileData?.selectedReligion(){
            if religion.isSelected{
                selectedReligion = true
            }
        }
        
        var selectetEthnicity = false
        if let ethnicity = DiscoverProfileCollection.sharedInstance.myProfileData?.ethnicity.first{
            if ethnicity.isSelected{
                selectetEthnicity = true
            }
        }
        
        if selectedReligion && selectetEthnicity{
            if wizardScreenArray.contains("GLOBAL_CITIZEN"){
                wizardScreenArray.remove("GLOBAL_CITIZEN")
            }
        }
        
        if DiscoverProfileCollection.sharedInstance.myProfileData?.height != nil{
            if wizardScreenArray.contains("MY_HEIGHT"){
                wizardScreenArray.remove("MY_HEIGHT")
            }
        }
            
        var selectedDegree = false
            if let degree = DiscoverProfileCollection.sharedInstance.myProfileData?.selectedDegree(){
                if degree.isSelected{
                    selectedDegree = true
                }
            }
            
            var selectedDesignation = false
            if let designation = DiscoverProfileCollection.sharedInstance.myProfileData?.selectedDesignation(){
                if designation.isSelected{
                    selectedDesignation = true
                }
            }
        
        if selectedDegree && selectedDesignation{
            if wizardScreenArray.contains("MY_WORK"){
                wizardScreenArray.remove("MY_WORK")
            }
        }
            
            if DiscoverProfileCollection.sharedInstance.myProfileData?.phoneNumberDto != nil {
                if ((DiscoverProfileCollection.sharedInstance.myProfileData?.phoneNumberDto?.object(forKey: "phoneNumber")) != nil){
                    if wizardScreenArray.contains("PHONE_NUMBER"){
                        wizardScreenArray.remove("PHONE_NUMBER")
                    }
                }
            }
            
            if DiscoverProfileCollection.sharedInstance.myProfileData?.myQuestionsArray.count ?? 0 >= Int(AppLaunchModel.sharedInstance()?.wooQuestionLimit ?? 0){
                if wizardScreenArray.contains("WOO_QUESTIONS"){
                    wizardScreenArray.remove("WOO_QUESTIONS")
                }
            }
        }
    }
    
    func openEditProfileOnlyForWorkEducation(){
        let controller: EditProfileViewController = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
        controller.isTypeOfWorkEducation = true
        controller.isShownFromWizard = true
        
        /*
        controller.dismissHandler = { (isModified, toClose) in
            self.isCloseTapped = toClose
            if isModified{
                if toClose{
                    self.navigationController?.popToRootViewController(animated: true)
                }
                else{
                    if self.checkIfFlowIsComplete(){
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    else{
                        WizardScreensCalculator.sharedInstance.moveToNextScreenForIndex()
                    }
                }
            }
            else{
                self.back(UIButton())
            }
        }
    */
        
        controller.isRefreshNeeded = true
        wizardScreenNavigationController?.pushViewController(controller, animated: true)
    }
    
    
    func moveToNextScreenForIndex(){
        if wizardScreenArray.count > 0{
            
            if let lastController = wizardScreenNavigationController?.viewControllers.last{
                lastViewController = lastController
            }
           
        switch getNextScreenToShowForIndex(currentWizardScreen) {
        case "MY_TAGS_RELATIONSHIP_LIFESTYLE":
            let relationshipVC = RelationshipViewController.loadNib("Relationship and Lifestyle")

            relationshipVC.setViewsfor(.PCW, tagData: .RelationshipAndLifestyle, closeBtn: true, title: "Relationship and Lifestyle")
            wizardScreenNavigationController?.pushViewController(relationshipVC, animated: true)
            break
        case "MY_TAGS_ZODIAC":
            let zodiacVC = RelationshipViewController.loadNib("Your Zodiac Sign")
            zodiacVC.setViewsfor(.PCW, tagData: .Zodiac, closeBtn: true, title: "Your Zodiac Sign")
            wizardScreenNavigationController?.pushViewController(zodiacVC, animated: true)
            break
        case "MY_TAGS":
            let wizardTagsVC = WizardTagsViewController(nibName: "WizardTagsViewController", bundle: nil)
            wizardScreenNavigationController?.pushViewController(wizardTagsVC, animated: true)
            break
        case "MY_PHOTOS":
            let wizardPhotoScreen = WizardPhotoViewController(nibName: "WizardPhotoViewController", bundle: nil)
            wizardScreenNavigationController?.pushViewController(wizardPhotoScreen, animated: true)
            break
        case "MY_STORY":
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let aboutMeViewController = mainStoryboard.instantiateViewController(withIdentifier: "AboutMeScreenViewController") as! AboutMeScreenViewController
            aboutMeViewController.isOpenedFromWizard = true
            wizardScreenNavigationController?.pushViewController(aboutMeViewController, animated: true)
            break
        case "GLOBAL_CITIZEN":
            let wizardGlobalCitizenVC = WizardGlobalCitizenViewController(nibName: "WizardGlobalCitizenViewController", bundle: nil)
            wizardScreenNavigationController?.pushViewController(wizardGlobalCitizenVC, animated: true)
            break
        case "MY_HEIGHT":
            let wizardHeightVC = WizardHeightViewController(nibName: "WizardHeightViewController", bundle: Bundle.main)
            wizardScreenNavigationController?.pushViewController(wizardHeightVC, animated: true)
            break
        case "MY_WORK":
//            let wizardworkVC = WizardWorkViewController(nibName: "WizardWorkViewController", bundle: Bundle.main)
//            wizardScreenNavigationController.pushViewController(wizardworkVC, animated: true)
            openEditProfileOnlyForWorkEducation()
            break
        case "PHONE_NUMBER":
            let wizardPhoneVerifyVC = WizardPhoneVerifyController(nibName: "WizardPhoneVerifyController", bundle: Bundle.main)
            wizardScreenNavigationController?.pushViewController(wizardPhoneVerifyVC, animated: true)
            break
        case "WOO_QUESTIONS":
            let wooQuestionsVC = WizardQnAViewController(nibName: "WizardQnAViewController", bundle: Bundle.main)
            if let questionDict = AppLaunchModel.sharedInstance()?.templateQuestionsArray.first{
                let questionModel = TargetQuestionModel(data: questionDict as? NSDictionary ?? NSDictionary())
                wooQuestionsVC.dummyQuestionModel = questionModel
            }
            wizardScreenNavigationController?.pushViewController(wooQuestionsVC, animated: true)
            break
        default:
            break
            }
        }
        
        currentWizardScreen = currentWizardScreen + 1
    }
    
    func updateProfileForDictionary(_ profileDataString:String){
        
        let completionHandler : (Any?, Bool, Int32) -> () =
        {(response, success, statusCode) -> Void in
            if success {
                
                (AppLaunchApiClass.sharedManager() as AnyObject).makeAppSyncCallForSidePanelTips()
                
                DiscoverProfileCollection.sharedInstance.myProfileData?.updateData(response as! NSDictionary)
                if self.editProfileApiCompletionHandler != nil{
                    self.editProfileApiCompletionHandler!(success)
                }
                
            }
            else{
                self.handleErrorForResponseCode(Int(statusCode))
            }
        }
        
        ProfileAPIClass.updateMyProfileDataForUser(withPayload: profileDataString,
                                                   andProfilePicID: DiscoverProfileCollection.sharedInstance.myProfileData?.wooAlbum?.profilePicData()?.objectId,
                                                   andCompletionBlock:completionHandler)
    }
    
    func makeDiscoverCallIfRequired(){
        DiscoverProfileCollection.sharedInstance.discoverModelCollection.removeAllObjects()
        DiscoverProfileCollection.sharedInstance.cardCollection.get().removeAllObjects()
        DiscoverEmptyManager.sharedInstance.discoverEmptyModelArray.removeAll()
        DiscoverProfileCollection.sharedInstance.needToMakeDiscoverCallAsPreferencesHasBeenChanged = false
        DiscoverProfileCollection.sharedInstance.collectionScilentlyReloded = true
        DiscoverProfileCollection.sharedInstance.paginationToken = ""
        DiscoverProfileCollection.sharedInstance.paginationIndex = ""
        
        DiscoverAPIClass.fetchDiscoverDataFromServer(withRequestBody: false, andPrefrence: false, isTagSelected: false, andCompletionBlock: { (success, response, statusCode) in
            if success{
            }
        })
        
        (AppLaunchApiClass.sharedManager() as AnyObject).makeAppSyncCallForSidePanelTips()

    }
    
    func showSnackBar(_ text:String){
        let snackBarObj: MDSnackbar = MDSnackbar(text:text, actionTitle: "", duration: 2.0)
        snackBarObj.multiline = true
        snackBarObj.show()
    }
    
    
    fileprivate func handleErrorForResponseCode(_ responseCode: Int) {
        switch responseCode {
        case 401:
            showSnackBar(NSLocalizedString("Something unexpected has happened. Please login again", comment: ""))
            FBSDKLogin.sharedManager().getReadPermissions(FBSDKLogin.sharedManager().fetchReadPermissions(), onParentViewController: wizardScreenNavigationController, with: { (fetchedNewPermissionTokedSuccessfully) in
                if (fetchedNewPermissionTokedSuccessfully == true){
                    //make sync call again
                }
                else{
                    FBSession.active().clearJSONCache()
                    FBSession.active().close()
                    FBSession.active().closeAndClearTokenInformation()
                    FBSession.setActive(nil)
                    FBSDKLogin.sharedManager().logOutUserFromFacebook()
                    
                    UserDefaults.standard.removeObject(forKey: "FBAccessTokenInformationKey")
                    UserDefaults.standard.removeObject(forKey: kIsLoginProcessCompleted)
                    UserDefaults.standard.removeObject(forKey: kWooUserId)
                    UserDefaults.standard.synchronize()
//                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//
//                    let loginViewControllerObj = storyboard.instantiateViewController(withIdentifier: kLoginViewControllerID) as! LoginViewController
//                    loginViewControllerObj.isAuthenticationFailed = true
//                    loginViewControllerObj.authenticationController = self
//                    self.present(loginViewControllerObj, animated: true, completion: {
//                        WooScreenManager.sharedInstance.loadLoginView()
//                    })
                    WooScreenManager.sharedInstance.loadLoginView()
                }
            })
            break
        case 404, 408, 405, 500, 203, 400:      // Not Found,
            //Request Timeout,
            //Method Not Allowed,
            //Internal Server Error
            //Method Not Allowed
            //Method Not Allowed
            showSnackBar(NSLocalizedString("Woo is experiencing heavy traffic.", comment: ""))
            break;
        default:
            break
        }
    }
}
