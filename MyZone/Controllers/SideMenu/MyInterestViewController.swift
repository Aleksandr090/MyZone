//
//  MyInterestViewController.swift
//  MyZone
//

import UIKit

class MyInterestViewController: BaseViewController {
    
    @IBOutlet weak var searchTextField: MZTextField!
    @IBOutlet weak var typeCollectionView: UICollectionView!
    @IBOutlet weak var doneButton: UIButton!

    var arrData = [SubTopicData.Data]()
    
    var topicId: String!
    
    var selectedInterests = [String]()
    
    var isSelecting = false

    override func viewDidLoad() {
        super.viewDidLoad()

        allSubTopicList()
        
        self.configureBackButton()

        self.title = "Pick your interests"

        let searchImage = searchTextField.setView(.left, image: UIImage(named: "search"), selectedImage: UIImage(named:"search"), width: 60)
        searchImage.isUserInteractionEnabled = false
        
        typeCollectionView.allowsMultipleSelection = true
        
        setupNextButton(isEnable: false)
        
    }
    
    func setupNextButton(isEnable:Bool) {
        doneButton.isUserInteractionEnabled = isEnable
        
        let textColor = isEnable ? UIColor.AppTheme.PostNextButtonSelectTitleColor : UIColor.AppTheme.PostNextButtonTitleColor
        let backgroundColor = isEnable ? UIColor.AppTheme.PinkColor :UIColor.AppTheme.PostNextButtonBgColor
        
        doneButton.setTitleColor(textColor, for: .normal)
        doneButton.backgroundColor = backgroundColor
        
    }
    

    @IBAction func doneAction(_ sender:UIButton) {
        selectedInterests.removeAll()
        if let selectedItems = typeCollectionView.indexPathsForSelectedItems {
            for index in selectedItems {
                selectedInterests.append(arrData[index.item].id)
            }
        }
        
        addInterest()
    }
    
    func addInterest() {
        MZProgressLoader.show()
        
        let param = [
            "myinterests": selectedInterests
        ]
        APIController.makeRequestReturnJSON(.saveInterest(param: param, userId: SharedPreference.getUserData()!.id)) { [self] data, error, headerDic in
            
            MZProgressLoader.hide()
            
            if error == nil {
                guard let responseData = data else {
                    return
                }
                ApplicationPreference.sharedManager.write(type: .userInterest, value: selectedInterests)
                MZUtilManager.showAlertWith(vc: self, title: "", message: (responseData["message"])! as! String, actionTitle: "OK")
                
            }else{
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
    }
    
    func allSubTopicList() {
        MZProgressLoader.show()
        
        APIController.makeRequestReturnJSON(.allSubTopicList(language: L102Language.currentAppleLanguage(), userId: SharedPreference.getUserData()!.id)) { data, error, headerDic in
            
            MZProgressLoader.hide()
            
            if error == nil {
                guard let responseData = data, let jsonArray = responseData["data"] as? [JSONDictionary] else {
                    return
                }
                
                self.arrData = jsonArray.compactMap{ SubTopicData.Data.init(json: $0) }
                let savedInterests = ApplicationPreference.sharedManager.read(type: .userInterest)
                if ("\(savedInterests)" != "") {
                    if let savedInterestsArray = savedInterests as? [String] {
                        for interest in savedInterestsArray {
                            if let index = self.arrData.firstIndex(where: { interest == $0.id }) {
                                self.arrData[index].isSelected = true
                            }
                        }
                    }
                }

                self.typeCollectionView.reloadData()
                
            }else{
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
    }

}

extension MyInterestViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostTypeCollectionCell", for: indexPath) as! PostTypeCollectionCell

        // cell.contentView.addShadow(color: UIColor.AppTheme.ShadowColor, opacity: 0.5, shadowRadius: 4)
        cell.imageView.sd_setImage(with: URL(string: arrData[indexPath.row].icon))
        cell.titleLabel.text = L102Language.currentAppleLanguage() == "en" ?  arrData[indexPath.row].subTopicNameEnglish : arrData[indexPath.row].subTopicNameArabic
        
        cell.isSelected = arrData[indexPath.row].isSelected
        if arrData[indexPath.row].isSelected {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
        }
        else {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.indexPathsForSelectedItems!.count > 0 {
            setupNextButton(isEnable: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.indexPathsForSelectedItems!.count == 0 {
            setupNextButton(isEnable: false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemHeight = (collectionView.frame.size.width/3) - 20
        
        return CGSize(width: itemHeight , height: itemHeight)
    }
    
}
