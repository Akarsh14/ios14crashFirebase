//
//  QuestionsViewController.swift
//  QNA
//
//  Created by Kuramsetty Harish on 08/04/19.
//  Copyright © 2019 Woo. All rights reserved.
//

import UIKit

class QuestionsViewController: UIViewController {
    
    let questionsModel = AppLaunchModel.sharedInstance()?.templateQuestionsArray
    var questions = [TargetQuestionModel]()
    var myProfileModel:MyProfileModel?
    var type:ansType?
    let  qnaCellIndentifier = "qnaCell"
    var selectedQuestion: TargetQuestionModel?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateQuestionsToShowInGrid()
        collectionView.register(UINib(nibName: "QNACell", bundle: nil), forCellWithReuseIdentifier: qnaCellIndentifier)
        
        self.collectionView.register(QNACell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "QNACell")

        
        (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).footerReferenceSize = CGSize(width: collectionView.bounds.width, height: 150)

        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        if let layout = collectionView?.collectionViewLayout as? QNACollectionViewManager {
            layout.delegate = self
            layout.headerReferenceSize =  CGSize(width: self.collectionView.frame.size.width, height: 100);
        }
    }
    
    fileprivate func updateQuestionsToShowInGrid(){
        if let model = questionsModel{
            for items in model{
                let individualQuestion = TargetQuestionModel(data: items as! NSDictionary)
                self.questions.append(individualQuestion)
            }
        }
        if let addedQuestions = myProfileModel?.myQuestionsArray{
            for items in addedQuestions{
                if let row = self.questions.firstIndex(where: {$0.questionId == items.questionId}){
                    self.questions.remove(at: row)
                }
            }
        }
        collectionView.reloadData()
    }
    
    @IBAction func btnClose(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setReplacementQuestion(question:TargetQuestionModel, type:ansType){
        self.selectedQuestion = question
        self.type = type
    }
    
    override func viewWillAppear(_ animated: Bool) {
        colorTheStatusBar(withColor: UIColor(red: (221.0/255.0), green: (241.0/255.0), blue: (246.0/255.0), alpha: 1.0))
    }
}

// MARK: - CollectionView Delegate

extension QuestionsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questions.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: qnaCellIndentifier, for: indexPath) as! QNACell
        let indQuestions = questions[indexPath.row]
        cell.txtLbl.text = indQuestions.question
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let QNAAnswrScreen : QNAanswersScreenViewController = QNAanswersScreenViewController(nibName: "QNAanswersScreenViewController", bundle: Bundle.main)
        if(type == .replace){
            QNAAnswrScreen.setAnswerTypeWithData(answerType: .replace, question:  questions[indexPath.row])
            QNAAnswrScreen.setReplacementQuestion(question:selectedQuestion ?? TargetQuestionModel())
        }else{
        QNAAnswrScreen.setAnswerTypeWithData(answerType: .new, question:  questions[indexPath.row])
        }
        QNAAnswrScreen.questionAddedHandler = {(profileModel) in
            self.myProfileModel = profileModel
            self.updateQuestionsToShowInGrid()
        }
        QNAAnswrScreen.myProfileModel = self.myProfileModel
        self.navigationController?.pushViewController(QNAAnswrScreen, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width:collectionView.frame.size.width, height:50.0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeadView", for: indexPath)
            
            headerView.backgroundColor = UIColor.blue;
            return headerView
            
        default:
            
            fatalError("Unexpected element kind")
        }
    }
   
    
}

extension QuestionsViewController : QNACollectionViewManagerDelegate {
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
        let font = UIFont(name: "Lato-Regular", size: 21.0)
        let indQuestions = questions[indexPath.row]
        var width:CGFloat = 0
        if(UIScreen.main.nativeBounds.width <= 640){
            width =  (self.collectionView.frame.size.width)/2.4
        }else if (UIScreen.main.nativeBounds.width <= 750){
            width =  (self.collectionView.frame.size.width)/2.3
        }
        else{
            width =  (self.collectionView.frame.size.width)/2
        }
        let height = heightForView(text: indQuestions.question, font: font!, width: width)
        return CGFloat(height+30)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, heightFortextAtIndexPath indexPath:IndexPath) -> CGFloat {
        let font = UIFont(name: "Lato-Regular", size: 21.0)
        let indQuestions = questions[indexPath.row]
        var width:CGFloat = 0
        if(UIScreen.main.nativeBounds.width <= 640){
            width =  (self.collectionView.frame.size.width)/2.4
        }else if (UIScreen.main.nativeBounds.width <= 750){
             width =  (self.collectionView.frame.size.width)/2.3
        }
        else{
            width =  (self.collectionView.frame.size.width)/2
        }
        let height = heightForView(text: indQuestions.question, font: font!, width: CGFloat(width))
        return CGFloat(height+40)
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
}

