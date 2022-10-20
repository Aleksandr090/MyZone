//
//  MessageChatViewController.swift
//  MyZone
//
//  Created by Apple on 23/02/22.
//

import UIKit
import AVKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAnalytics
import DropDown
import SDWebImage
import AVFoundation
import IQKeyboardManagerSwift

class MessageChatViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var MessageChatTableView: UITableView!
    @IBOutlet weak var btnMice: UIButton!
    @IBOutlet weak var txtChatMessage: UITextField!
    @IBOutlet weak var btnAttachment: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    
    @IBOutlet weak var txvMessageViewBottomConstrain: NSLayoutConstraint!
    @IBOutlet weak var viewMainRecordAudio: UIView!
    @IBOutlet weak var btnStopRecording: UIButton!
    @IBOutlet weak var lblRecordingTimer: UILabel!
    @IBOutlet weak var messageTableViewBottomConstraint: NSLayoutConstraint!
    
    var id:String!
    var name:String!
    var databaseChats:DatabaseReference!
    var databseChild:Int!
    var messagesNode:String!
    
    var msgSenderId:String!
    var msgReceiverId:String!
    var msgSenderName:String!
    var msgReceiverName:String!
    
    var arrChatList:NSMutableArray = []
    var imagePicker = UIImagePickerController()
    
    
    var timeCounter = Int(0)
    var totalSecoundCount = Int(0)
    fileprivate var timerTimeDuration: Timer!
   
    var recorder: AVAudioRecorder!
   
    var player:AVAudioPlayer!
    
    var selectedIndex: IndexPath?
    
    var keyboardHeight: CGFloat = 250
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        currentViewController = self
        lblUserName.text = msgReceiverName
        getChatList()
        viewMainRecordAudio.isHidden = true
        
        MessageChatTableView.register(UINib(nibName: "LeftTextTVC", bundle: nil), forCellReuseIdentifier: "LeftTextTVC")
        
        MessageChatTableView.register(UINib(nibName: "TextLeftTVC", bundle: nil), forCellReuseIdentifier: "TextLeftTVC")
        MessageChatTableView.register(UINib(nibName: "TextRightTVC", bundle: nil), forCellReuseIdentifier: "TextRightTVC")
        
        MessageChatTableView.register(UINib(nibName: "ImageLeftTVC", bundle: nil), forCellReuseIdentifier: "ImageLeftTVC")
        MessageChatTableView.register(UINib(nibName: "ImageRightTVC", bundle: nil), forCellReuseIdentifier: "ImageRightTVC")
        
        MessageChatTableView.register(UINib(nibName: "AudioLeftTVC", bundle: nil), forCellReuseIdentifier: "AudioLeftTVC")
        MessageChatTableView.register(UINib(nibName: "AudioRightTVC", bundle: nil), forCellReuseIdentifier: "AudioRightTVC")
        
        //self.txtChatMessage.inputAccessoryView = UIView();  //This will remove toolbar which have done button.
        //self.txtChatMessage.keyboardDistanceFromTextField = 28; //This will modify default distance between textField and keyboard. For exact value, please manually check how far your textField from the bottom of the page. Mine was 8pt.
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       IQKeyboardManager.shared.enableAutoToolbar = false
       IQKeyboardManager.shared.enable = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
        player?.stop()
    }
    
    func getChatList(){
        arrChatList.removeAllObjects()
        let query = databaseChats.child(messagesNode).queryLimited(toLast: 50)
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            if let chatData = snapshot.value as? NSDictionary {
                self?.arrChatList.add(chatData)
                self?.reloadData()
                if let receiverId = chatData["receiverId"] as? String, receiverId == self?.msgSenderId  {
                    if snapshot.childrenCount > 0 {
                        for data in snapshot.children.allObjects as! [DataSnapshot] {
                            if data.key == "isread" {
                                data.ref.runTransactionBlock { currentData in
                                    currentData.value = true
                                    return TransactionResult.success(withValue: currentData)
                               }
                           }
                        }
                    }
                } else if !(currentViewController!.isKind(of: MessageChatViewController.self)){
                    NotificationCenter.default.post(name: Notification.Name("ChatBadge"), object: nil, userInfo: ["badgeCount": 1 as Any])
                }
            }
        })
    }
    
    func reloadData() {
        MessageChatTableView.reloadData()
        DispatchQueue.main.async {            
            self.MessageChatTableView.scrollToBottom()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height

            UIView.animate(withDuration: 1.0, animations: { [self] in
                self.txvMessageViewBottomConstrain.constant = keyboardHeight
                messageTableViewBottomConstraint.constant = 76 + keyboardHeight
                
               
                var frame: CGRect = self.MessageChatTableView.frame
                frame.size.height = frame.size.height - keyboardHeight
                MessageChatTableView.frame = frame;
                MessageChatTableView.scrollToBottom()
                MessageChatTableView.layoutSubviews()
                MessageChatTableView.layoutIfNeeded()
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
       
        UIView.animate(withDuration: 1.0, animations: { [self] in
            self.txvMessageViewBottomConstrain.constant = 0
            messageTableViewBottomConstraint.constant = 76
            
            var frame: CGRect = self.MessageChatTableView.frame
            frame.size.height = frame.size.height + keyboardHeight
            MessageChatTableView.frame = frame;
            MessageChatTableView.scrollToBottom()
            MessageChatTableView.layoutSubviews()
            MessageChatTableView.layoutIfNeeded()
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func btnActionInfo(_ sender: Any) {
        let moreOptionDropDown = DropDown()
        moreOptionDropDown.anchorView = btnInfo
        moreOptionDropDown.bottomOffset = CGPoint(x: -100, y: btnInfo.bounds.height)
        // You can also use localizationKeysDataSource instead. Check the docs.
        moreOptionDropDown.dataSource = ["  Mute","  Delete","  Block"]
        
        // Action triggered on selection
        /* moreOptionDropDown.selectionAction = { [weak self] (index, item) in
         self!.offNotificationBlock!()
         }*/
        
        moreOptionDropDown.show()
    }
    
    @IBAction func btnActionBack(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    func getStringFrom(seconds: Int) -> String {
        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
    
    @IBAction func btnActionMice(_ sender: Any) {
        if recorder != nil, recorder.isRecording {
            stopRecording()
        } else {
            recordWithPermission()
        }
    }
    
    func recordWithPermission() {
        lblRecordingTimer.text = "00:00:00"
        
        AVAudioSession.sharedInstance().requestRecordPermission() { [unowned self] granted in
            if granted {
                viewMainRecordAudio.isHidden = false
                DispatchQueue.main.async { [self] in
                    self.setSession(with: .playAndRecord)
                    self.setupRecorder()
                    self.recorder.record()
                    
                    self.timerTimeDuration = Timer.scheduledTimer(timeInterval: 1.0,
                                                                  target: self,
                                                                  selector: #selector(updateAudioMeter(_:)),
                                                                  userInfo: nil,
                                                                  repeats: true)
                }
            } else {
                print("No recording permission")
            }
        }
        
        if AVAudioSession.sharedInstance().recordPermission == .denied {
            print("Recording permission denied")
        }
    }
    
    func setSession(with category: AVAudioSession.Category) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(category, options: .defaultToSpeaker)
            
        } catch {
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setupRecorder() {
        
        let settings:[String : Any] = [
            AVFormatIDKey:             kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey :      32000,
            AVNumberOfChannelsKey:     2,
            AVSampleRateKey :          44100.0
        ]
        
        do {
            recorder = try AVAudioRecorder(url: getAudiFileURL(), settings: settings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
        } catch {
            recorder = nil
            print(error.localizedDescription)
        }
        
    }
    
    @objc func updateAudioMeter(_ timer:Timer) {
        
        if let recorder = self.recorder {
            if recorder.isRecording {
                
                let timeValue = timeCounter + 1
                timeCounter = timeValue
                
                let hours = timeValue / 3600
                let minutes = (timeValue % 3600) / 60
                let seconds = (timeValue % 3600) % 60
                
                let finalHours = getStringFrom(seconds: hours)
                let finalMinutes = getStringFrom(seconds: minutes)
                let finalSeconds = getStringFrom(seconds: seconds)
                
                let finalTime = finalHours + ":" + finalMinutes + ":" + finalSeconds
                
                totalSecoundCount = (minutes * 60) + seconds
                
                lblRecordingTimer.text = finalTime
                
                recorder.updateMeters()
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
         let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
         let documentsDirectory = paths[0]
         return documentsDirectory
     }
     func getAudiFileURL() -> URL {
         return getDocumentsDirectory().appendingPathComponent(".mp3")
     }
    
    @IBAction func btnActionStopRecording(_ sender: Any) {
        stopRecording()
    }
    
    func stopRecording() {
        viewMainRecordAudio.isHidden = true
        timerTimeDuration?.invalidate()
        timerTimeDuration = nil
        
        timeCounter = 0
        totalSecoundCount = 0
        
        recorder?.stop()
        player?.stop()
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func uploadAudioMedia() {
        MZProgressLoader.show()
        let metadata = StorageMetadata()
        let storageRef = Storage.storage().reference().child("uploads/\(currentTimeMillis()).mp3")
        metadata.contentType = "audio/mp3"
        
        storageRef.putFile(from: getAudiFileURL(), metadata: metadata) { (metadata, error) in
            
            if error != nil {
                MZProgressLoader.hide()
                print("error")
                
                OperationQueue.main.addOperation {
                    // BaseApp.sharedInstance.showAlertNativeDialog(title: BaseApp.sharedInstance.getMessageForCode("app_name") ?? "OnlyFrieends", message: "Error Uploading", controller: self)
                }
            } else {
                storageRef.downloadURL(completion: { (url, error) in
                    print(url?.absoluteString ?? "")
                    MZProgressLoader.hide()
                    
                    self.submitChat(isread: false, msgType:"audio", text:"", uploadUrl:url?.absoluteString ?? "")
                    
                })
            }
        }
    }
    
    @objc func playAudio(_ index: Int) {
        
        let data = arrChatList[index] as! NSDictionary
        let urlString = data["uploadUrl"] as? String ?? ""
        guard let url = URL(string: urlString ) else { return }
        //MZProgressLoader.show()
        downloadFileFromURL(url: url)
    }

    @objc func playerDidFinishPlaying() {
        player?.pause()
    }
    
    func downloadFileFromURL(url: URL) {
        
        var downloadTask: URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { url, response, error in
            //MZProgressLoader.hide()
            self.play(url: url!)
        })
        downloadTask.resume()
    }
    
    func play(url: URL) {
        print("playing \(url)")
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
    
    
    @IBAction func btnActionAttachment(_ sender: Any) {
        selectSeekerProfileImage()
    }
    
    @objc func selectSeekerProfileImage() {
        let actionSheet = UIAlertController(title:"Upload Photo", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title:"Gallery", style: .default, handler: { (UIAlertAction) in
            self.openGallary()
        }))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (UIAlertAction) in
            self.openCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openGallary(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        dismiss(animated: true, completion: nil)
        
        uploadImageMedia(imgData: selectedImage)
        
    }
    
    func currentTimeMillis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    func uploadImageMedia(imgData:UIImage) {
        MZProgressLoader.show()
        let storageRef = Storage.storage().reference().child("uploads/\(currentTimeMillis()).png")
        
        if let uploadData = imgData.jpegData(compressionQuality: 0.5) {
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    MZProgressLoader.hide()
                    print("error")
                    
                    OperationQueue.main.addOperation {
                        // BaseApp.sharedInstance.showAlertNativeDialog(title: BaseApp.sharedInstance.getMessageForCode("app_name") ?? "OnlyFrieends", message: "Error Uploading", controller: self)
                    }
                } else {
                    storageRef.downloadURL(completion: { (url, error) in
                        print(url?.absoluteString ?? "")
                        MZProgressLoader.hide()
                        self.submitChat(isread: false, msgType:"image", text:"", uploadUrl:url?.absoluteString ?? "")
                        //self.submitDataToFirebase(msgType: "image", uploadUrl: url?.absoluteString ?? "", text: "", hideLoader: true)
                    })
                }
            }
        }
    }
    
    func submitChat(isread:Bool , msgType:String, text:String, uploadUrl:String){
        let ref = databaseChats.child(messagesNode).childByAutoId()
        let message = ["dateSent":"",
                       "displayTitle": "",
                       "isread":isread,
                       "msgType": msgType,
                       "receiverId":msgReceiverId!,
                       "receiverName":msgReceiverName!,
                       "receiverPhoto":"",
                       "senderId":msgSenderId!,
                       "senderName":msgSenderName!,
                       "senderPhoto":"",
                       "text":text,
                       "timestamp":String(currentTimeMillis()),
                       "uploadUrl": uploadUrl
        ] as [String : Any]
        
        ref.setValue(message)        
        self.view.endEditing(true)
    }
    
    func sendNotification() {
        
        let param = [
            "receiverId":msgReceiverId!,
            "message":txtChatMessage.text!
        ]
        APIController.makeRequestReturnJSON(.sendNotification(param: param, userId: SharedPreference.getUserData()!.id)) { data, error, headerDic in
        }
    }
    
    @IBAction func btnActionSend(_ sender: Any) {
        if txtChatMessage.text!.isEmpty { return }
        submitChat(isread: false, msgType:"text", text:txtChatMessage.text!, uploadUrl:"")
        sendNotification()
        txtChatMessage.text = ""
    }
    
    @objc func openImage(_ sender: UIButton) {
        let data = arrChatList[sender.tag] as! NSDictionary
        let vc: ImageZoomViewController = UIStoryboard(storyboard: .home).instantiateVC()
        vc.imageURL = data["uploadUrl"] as? String ?? ""
        vc.modalPresentationStyle = .overCurrentContext
        self.tabBarController!.present(vc, animated: true, completion: nil)
    }
    
}

extension MessageChatViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrChatList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = arrChatList[indexPath.row] as! NSDictionary
        let msgType = data["msgType"] as! String
        if(msgType == "text"){
            return UITableView.automaticDimension
        }else if(msgType == "image"){
            return 185
        }else{
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = arrChatList[indexPath.row] as! NSDictionary
        
        let senderId = data["senderId"] as! String
        let msgType = data["msgType"] as! String
        
        if(msgType == "text"){
            if(senderId == msgSenderId){
                let cell = MessageChatTableView.dequeueReusableCell(withIdentifier: "TextRightTVC", for: indexPath) as! TextRightTVC
                
                cell.lblRightText.text = (data["text"] as! String)
                
                if(cell.lblRightText.text!.count < 29){
                    cell.rightViewWidth.constant = 250
                    cell.lblWidth.constant = 230
                }else{
                    cell.rightViewWidth.constant = 50
                    cell.lblWidth.constant = 30
                }
                
                /*let label = UILabel()
                label.text = "This text will not fit into one line and should break"
                label.numberOfLines = 2
                label.translatesAutoresizingMaskIntoConstraints = false
                label.lineBreakMode = .byWordWrapping
                view.addSubview(label)
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
                    label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                    label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
                ])*/
                
                let date = NSDate(timeIntervalSince1970: Double(data["timestamp"] as! String)!)
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "HH:mm"
                cell.lblRightTime.text = dayTimePeriodFormatter.string(from: date as Date)
                
                return cell
            }else{
                let cell = MessageChatTableView.dequeueReusableCell(withIdentifier: "TextLeftTVC", for: indexPath) as! TextLeftTVC
                
                cell.lblleftText.text = (data["text"] as! String)
                
                if(cell.lblleftText.text!.count > 29){
                    cell.leftViewWidth.constant = 250
                    cell.lblLeftWidth.constant = 230
                }else{
                    cell.leftViewWidth.constant = 50
                    cell.lblLeftWidth.constant = 30
                }
                
                let date = NSDate(timeIntervalSince1970: Double(data["timestamp"] as! String)!)
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "HH:mm"
                cell.lblLeftTime.text = dayTimePeriodFormatter.string(from: date as Date)
                
                return cell
            }
        }else if(msgType == "image"){
            if(senderId == msgSenderId){
                let cell = MessageChatTableView.dequeueReusableCell(withIdentifier: "ImageRightTVC", for: indexPath) as! ImageRightTVC
                
                cell.imgChatRight.sd_setImage(with: URL(string:(data["uploadUrl"] as? String ?? "")), placeholderImage: UIImage(named: "dummy"))
                cell.btnImage.tag = indexPath.row
                cell.btnImage.addTarget(self, action: #selector(openImage(_:)), for: .touchUpInside)
                let date = NSDate(timeIntervalSince1970: Double(data["timestamp"] as! String)!)
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "HH:mm"
                cell.lblChatImageRightTime.text = dayTimePeriodFormatter.string(from: date as Date)
                
                return cell
            }else{
                let cell = MessageChatTableView.dequeueReusableCell(withIdentifier: "ImageLeftTVC", for: indexPath) as! ImageLeftTVC
                
                cell.imgChatLeft.sd_setImage(with: URL(string:(data["uploadUrl"] as? String ?? "")), placeholderImage: UIImage(named: "dummy"))
                cell.btnImage.tag = indexPath.row
                cell.btnImage.addTarget(self, action: #selector(openImage(_:)), for: .touchUpInside)
                let date = NSDate(timeIntervalSince1970: Double(data["timestamp"] as! String)!)
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "HH:mm"
                cell.lblChatImageLeftTime.text = dayTimePeriodFormatter.string(from: date as Date)
                
                return cell
            }
        }else{
            if(senderId == msgSenderId){
                let cell = MessageChatTableView.dequeueReusableCell(withIdentifier: "AudioRightTVC", for: indexPath) as! AudioRightTVC
                
                let date = NSDate(timeIntervalSince1970: Double(data["timestamp"] as! String)!)
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "HH:mm"
                cell.lblAudioRightTime.text = dayTimePeriodFormatter.string(from: date as Date)
                return cell
            }else{
                let cell = MessageChatTableView.dequeueReusableCell(withIdentifier: "AudioLeftTVC", for: indexPath) as! AudioLeftTVC
                
                let date = NSDate(timeIntervalSince1970: Double(data["timestamp"] as! String)!)
                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "HH:mm"
                cell.lblAudioLeftTime.text = dayTimePeriodFormatter.string(from: date as Date)
                return cell
            }
        }
    }
    
    private func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0)
        if indexPath.row == lastRowIndex - 1 {
            tableView.scrollToBottom(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = arrChatList[indexPath.row] as! NSDictionary
        
        let msgType = data["msgType"] as! String
        
        if msgType == "audio" {
            self.selectedIndex = indexPath
            self.playAudio(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let data = arrChatList[indexPath.row] as! NSDictionary
        
        let msgType = data["msgType"] as! String
        
        if msgType == "audio" {
            self.playerDidFinishPlaying()
        }
    }
}

extension UITableView {
    func scrollToBottom(animated: Bool = true) {
        let sections = self.numberOfSections
        let rows = self.numberOfRows(inSection: sections - 1)
        if (rows > 0){
            self.scrollToRow(at: IndexPath(row: rows-1, section: sections-1), at: .bottom, animated: animated)
        }
    }
}

extension MessageChatViewController: MZAlertViewDelegate {   
    
    func didSendAudio() {
        uploadAudioMedia()
    }
}

// MARK: AVAudioRecorderDelegate
extension MessageChatViewController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        let vc: MZAlertViewController = UIStoryboard(storyboard: .main).instantiateVC()
        vc.alertType = .sendAudioMessage
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false, completion: nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("\(error.localizedDescription)")
        }
    }
}

// MARK: AVAudioPlayerDelegate
extension MessageChatViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Play ends")
        MessageChatTableView.deselectRow(at: selectedIndex!, animated: false)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("\(error.localizedDescription)")
        }
    }
}
