//
//  SelectInterestViewController.swift
//  MyZone
//

import UIKit

protocol SelectInterestDelegate {
    func selectedInterests(interests: [SubTopicData.Data])
}

class SelectInterestViewController: BaseViewController {
    @IBOutlet weak var searchTextField: MZTextField!
    @IBOutlet weak var typeCollectionView: UICollectionView!
    @IBOutlet weak var doneButton: UIButton!

    var delegate: SelectInterestDelegate?

    var arrData = [SubTopicData.Data]()
    
    var topicId: String!
    
    var selectedInterests = [SubTopicData.Data]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        subTopicList()
        
        self.configureBackButton()

        self.title = "Pick your sub-topic"

        let searchImage = searchTextField.setView(.left, image: UIImage(named: "search"), selectedImage: UIImage(named:"search"), width: 60)
        searchImage.isUserInteractionEnabled = false
        
        typeCollectionView.allowsMultipleSelection = true
        
    }

    @IBAction func doneAction(_ sender:UIButton) {
        selectedInterests = [SubTopicData.Data]()
        if let selectedItems = typeCollectionView.indexPathsForSelectedItems {
            for index in selectedItems {
                selectedInterests.append(arrData[index.item])
            }
            delegate?.selectedInterests(interests: selectedInterests)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func subTopicList() {
        MZProgressLoader.show()
        
        APIController.makeRequestReturnJSON(.subTopicList(language: L102Language.currentAppleLanguage(), userId: SharedPreference.getUserData()!.id, topicId: topicId)) { data, error, headerDic in
            
            MZProgressLoader.hide()
            
            if error == nil {
                guard let responseData = data, let jsonArray = responseData["data"] as? [JSONDictionary] else {
                    return
                }
                print(responseData)
                self.arrData = jsonArray.compactMap{ SubTopicData.Data.init(json: $0) }
                
                self.typeCollectionView.reloadData()
                
            }else{
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
            
        }
    }
}


extension SelectInterestViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostTypeCollectionCell", for: indexPath) as! PostTypeCollectionCell

        cell.contentView.addShadow(color: UIColor.AppTheme.ShadowColor,
                                   opacity: 0.5,
                                   shadowRadius: 4)
        cell.imageView.sd_setImage(with: URL(string: arrData[indexPath.row].icon))
        cell.titleLabel.text = L102Language.currentAppleLanguage() == "en" ?  arrData[indexPath.row].subTopicNameEnglish : arrData[indexPath.row].subTopicNameArabic
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemHeight = (collectionView.frame.size.width/3) - 20
        
        return CGSize(width: itemHeight , height: itemHeight)
    }
    
}
