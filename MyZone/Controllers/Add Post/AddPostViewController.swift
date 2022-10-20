//
//  AddPostViewController.swift
//  MyZone
//

import UIKit
import CoreLocation
import Alamofire

class AddPostViewController: BaseViewController {

    @IBOutlet weak var conatinerView: UIView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var postTypeImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var mediaContantTableView: UITableView!
    @IBOutlet weak var mediaContantTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var subTypeButton: UIButton!
    @IBOutlet weak var postButton: MZButton!
    
    @IBOutlet weak var audioRecorderView: UIView!
    @IBOutlet weak var audioRecodingTimerLabel: UILabel!

    var recorder = AudioRecorder.shared
    var duration : CGFloat = 0.0
    var timer : Timer!
    
    var videoPicker: VideoPicker!
    var imagePicker: ImagePicker!

    var selectedDate: Date?
    var phoneNumber: String!
    var address: String!
    var selectedAddress: String!
    var city: String!
    var radius: Float!
    var selectedLocation: CLLocationCoordinate2D!
    var selectedSubTopic = ""
    var selectedImages = [UIImage]()
    var selectedImagesData = [Data]()
    var selectedVideoData = [Data]()
    var selectedAudioData = [Data]()
    var selectedVideo: URL?
    var selectedAudios = [URL]()
    var postDate = ""
    var postTime = ""
    var time = ""
    var contentArray = [ContantTypeData]()
    var selectTopic: TopicData.Data!
    var postId = ""
    var postDetail: PostData.Data?
    var from: Int = 0 // 0: add, 1: update
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        postButton.defaultTextColor = UIColor.white
        
        setupInitData()
        
        setupUIComponent()
        
        requestReviewIfAppropriate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        let height = UIScreen.main.bounds.height - 450
        //let height: CGFloat = 480
        //print("height===\(height)")
        //print("heightcontent===\(mediaContantTableView.contentSize.height)")
        super.viewDidLayoutSubviews()
        if mediaContantTableView.contentSize.height > 0 {
            mediaContantTableViewHeight.constant = (mediaContantTableView.contentSize.height < height) ? height : mediaContantTableView.contentSize.height
            self.conatinerView.layoutIfNeeded()
        } else {
            mediaContantTableViewHeight.constant = height
            self.conatinerView.layoutIfNeeded()
        }
    }
    
    
    func setupNavigationBar() {
        let cancelButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "cancel"), style: .plain, target:  self, action: #selector(didTapBackButton))
        
        let logoButtonItem = UIBarButtonItem(image:UIImage(named: "AppIcon"), style: .plain, target:  self, action: #selector(didTouchLogoButton))
        logoButtonItem.tintColor = UIColor.clear

        self.title = "New Community Post"
        navigationItem.rightBarButtonItem = cancelButtonItem
        navigationItem.leftBarButtonItem = logoButtonItem
    }

    @objc func didTapBackButton() {
        self.navigationController!.dismiss(animated: true, completion: nil)
    }
    
    @objc func didTouchLogoButton() {
        self.navigationController!.dismiss(animated: true, completion: nil)
    }
    
    func setupInitData() {
        if from == 0 { return }
        if let post = postDetail {
            selectTopic = post.topicId
            titleTextView.text = post.postTitle
            descriptionTextView.text = post.postDescription
            selectedVideo = post.video.count > 0 ? URL(string: post.video[0].videos) : nil
            phoneNumber = post.contactNo != "" ? post.contactNo : nil
            if post.time != "" {
                getSelectedDate(post: post)
            }
            city = post.city
            address = city != "" ? city : nil
            selectedAddress = address ?? ""
            print(post.location.coordinates)
            if post.location.coordinates.count > 0 {
                selectedLocation = CLLocationCoordinate2D(latitude: post.location.coordinates[1], longitude: post.location.coordinates[0])
            } else {
                selectedLocation = nil
            }
            
            if post.image.count > 0 {
                for img in post.image {
                    getData(from: URL(string: img.img)!) { data, response, error in
                        guard let data = data, error == nil else { return }
                        DispatchQueue.main.async {
                            self.selectedImages.append(UIImage(data: data)!)
                            self.mediaContantTableView.reloadData()
                        }
                    }
                }                
            }
            if post.audio.count > 0 {
                for audio in post.audio {
                    if audio.audios != "" {
                        let recording = MyRecording(fileName: "", duration: "", url: URL(string: audio.audios)!)
                        self.recorder.myRecordings.append(recording)
                    }
                }
            }
            postButton.setTitle("Update", for: .normal)
            otherContentRowCount()
            mediaContantTableView.reloadData()
            mediaContantTableView.layoutIfNeeded()
            self.viewDidLayoutSubviews()
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func getSelectedDate(post: PostData.Data) {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd/MM/y HH:mm"
        selectedDate = dateformatter.date(from: post.time)
    }
    
    func setupUIComponent() {
        postTypeImageView.sd_setImage(with: URL(string: selectTopic.icon))
        titleTextView.placeholder = "Title..."
        descriptionTextView.placeholder = "Content..."
        
        self.mediaContantTableView.tableFooterView = UIView(frame: .zero)
        
        self.mediaContantTableView?.register(UINib(nibName: "AddImageCell", bundle: nil), forCellReuseIdentifier: "AddImageCell")

        self.mediaContantTableView?.register(UINib(nibName: "AddVideoCell", bundle: nil), forCellReuseIdentifier: "AddVideoCell")

        self.mediaContantTableView?.register(UINib(nibName: "AddAudioCell", bundle: nil), forCellReuseIdentifier: "AddAudioCell")
        
        self.mediaContantTableView?.register(UINib(nibName: "AddOtherContantCell", bundle: nil), forCellReuseIdentifier: "AddOtherContantCell")
        
        self.audioRecorderView.isHidden = true
        self.audioRecorderView.layer.borderWidth = 1
        self.audioRecorderView.layer.borderColor = UIColor.black.cgColor
        if from == 0 {
            self.recorder.removeAllRecordings()
        }
        
        self.mediaContantTableView.delegate = self
        self.mediaContantTableView.dataSource = self
//        self.mediaContantTableView.reloadData()
        
        subTypeButton.addShadow()
    }

    func otherContentRowCount(){
        contentArray = [ContantTypeData]()
        if selectedDate != nil {
            contentArray.append( ContantTypeData(type: .date, data: selectedDate ?? Date()))
        }
        if phoneNumber != nil {
            contentArray.append( ContantTypeData(type: .phone, data: phoneNumber ?? ""))
        }
        if address != nil {
            contentArray.append( ContantTypeData(type: .address, data: address ?? ""))
        }
        self.mediaContantTableView.reloadData()
        self.viewDidLayoutSubviews()
    }
    
    
    func setTimer(){
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateDuration), userInfo: nil, repeats: true)
    }

    @objc func updateDuration() {
        if recorder.isRecording && !recorder.isPlaying{
            duration += 1
            self.audioRecodingTimerLabel.text = duration.timeStringFormatter
        }else{
            timer.invalidate()
            duration = 0
            self.audioRecodingTimerLabel.text = "00 : 00 : 00"
        }
    }
    
    @IBAction func addAudioAction(_ sender:UIButton) {
        if recorder.isRecording{
            audioRecorderView.isHidden = true
            recorder.stopRecording()
            self.mediaContantTableView.reloadData()
            self.viewDidLayoutSubviews()
        } else{
            audioRecorderView.isHidden = false
            recorder.record()
            setTimer()
        }
        print(recorder.getRecordings)
    }
    
    @IBAction func addVideoAction(_ sender:UIButton) {
        self.videoPicker = VideoPicker(presentationController: self, delegate: self)
        self.videoPicker.present(from: sender)
    }
    
    @IBAction func addImageAction(_ sender:UIButton) {
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func addLocationAction(_ sender:UIButton) {
        let vc: FilterLocationViewController = UIStoryboard(storyboard: .home).instantiateVC()
        vc.forPost = true
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func addPhoneAction(_ sender:UIButton) {
        let vc: MZAlertViewController = UIStoryboard(storyboard: .main).instantiateVC()
        vc.alertType = .phone
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func addDateAction(_ sender:UIButton) {
        let vc: MZAlertViewController = UIStoryboard(storyboard: .main).instantiateVC()
        vc.alertType = .date
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func addSubTypeAction(_ sender:UIButton) {
        let vc: SelectInterestViewController = UIStoryboard(storyboard: .home).instantiateVC()
        vc.topicId = selectTopic.id
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func addPostAction(_ sender:UIButton) {
        if from == 0 {
            let validation = checkFormValidation()
            if !validation.status {
                let alert = UIAlertController(title: "", message: validation.message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            getPostDateTime()
            MZProgressLoader.show()
            
            let params = [
                "country":  "Saudi Arabic",
                "city" : "\(city ?? "")",
                "neighborehood":  "Bhopal",
                "radius": radius ?? 10,
                "post_type": L102Language.currentAppleLanguage() == "en" ? selectTopic.topicNameEnglish : selectTopic.topicNameArabic,
                "topicId": selectTopic.id,
                "post_title": titleTextView.text!,
                "post_description": descriptionTextView.text!,
                "contact_no": "\(phoneNumber ?? "")",
                "sub_subject": selectedSubTopic,
                "place_name": "\(selectedAddress ?? "")",
                "latitude": selectedLocation.latitude,
                "longitude": selectedLocation.longitude,
                "date": Int(Date().timeIntervalSince1970 * 1000),
                "time": time,
                "postDate": postDate,
                "postTime": postTime] as [String : Any]
            
            APIController.makeRequestReturnJSON(.addPost(param: params, images: selectedImagesData, userId: SharedPreference.getUserData()!.id)) { [self] data, error, headerDic in
                
                if error == nil {
                    guard let responseData = data, let json = responseData["data"] as? JSONDictionary else {
                        return
                    }
                    print(responseData)
                    postId = json["_id"] as! String

                    if selectedVideo != nil {
                        uploadMedia(mediaType: "Video")
                    }
                    if recorder.getRecordings.count > 0 {
                        uploadMedia(mediaType: "Audio")
                    }
                    if selectedVideo == nil && recorder.getRecordings.count == 0 {
                        MZProgressLoader.hide()
                        gotoHome()
                    }
                }else{
                    MZProgressLoader.hide()
                    MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
                }
            }
        } else {
            editPost()
        }
    }
    
    func editPost() {
        
        let validation = checkFormValidation()
        if !validation.status {
            let alert = UIAlertController(title: "", message: validation.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        getPostDateTime()
        MZProgressLoader.show()
        
        let params = [
            "post_id": postId,
            "country":  "Saudi Arabic",
            "city" : "\(city ?? "")",
            "neighborehood":  "Bhopal",
            "radius": radius ?? 10,
            "post_type": L102Language.currentAppleLanguage() == "en" ? selectTopic.topicNameEnglish : selectTopic.topicNameArabic,
            "topicId": selectTopic.id,
            "post_title": titleTextView.text!,
            "post_description": descriptionTextView.text!,
            "contact_no": "\(phoneNumber ?? "")",
            "sub_subject": selectedSubTopic,
            "place_name": "\(city ?? "")",
            "latitude": selectedLocation.latitude,
            "longitude": selectedLocation.longitude,
            "date": Int(Date().timeIntervalSince1970 * 1000),
            "time": time,
            /*"postDate": postDate,
            "postTime": postTime*/
            ] as [String : Any]
        
        APIController.makeRequestReturnJSON(.editPost(param: params, images: selectedImagesData, userId: SharedPreference.getUserData()!.id)) { [self] data, error, headerDic in
            
            if error == nil {
                guard let responseData = data, let status = responseData["status"] as? Int else {
                    return
                }
                print(responseData)
                if status != 200 {
                    MZProgressLoader.hide()
                    MZUtilManager.showAlertWith(vc: self, title: "", message: responseData["message"] as! String, actionTitle: "OK")
                    return
                }
                
                if selectedVideo != nil {
                    uploadMedia(mediaType: "Video")
                }
//                if recorder.getRecordings.count > 0 {
//                    uploadMedia(mediaType: "Audio")
//                }
                if selectedVideo == nil /*&& recorder.getRecordings.count == 0 */{
                    MZProgressLoader.hide()
                    gotoHome()
                }
            }else{
                MZProgressLoader.hide()
                MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
            }
        }
        
    }
    
    func checkFormValidation() -> (status: Bool, message: String){
        var message = ""
        var status = true
        if (titleTextView.text?.trimmingCharacters(in: .whitespaces).isEmpty)!{
            status = false
            message = "Title should not be empty."
        } /*else if (descriptionTextView.text?.trimmingCharacters(in: .whitespaces).isEmpty)!{
            status = false
            message = "Description should not be empty."
        } else if selectedImages.count == 0{
            status = false
            message = "Photo should not be empty."
        } else if postDate == "" || postTime == "" {
            status = false
            message = "Post Date should not be empty."
        }*/
        return (status, message)
    }
    
    func getPostDateTime() {
        guard let selectedDate = selectedDate else {
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/y"
        postDate = dateFormatter.string(from: selectedDate)
        
        dateFormatter.dateFormat = "HH:mm"
        postTime = dateFormatter.string(from: selectedDate)
        
        dateFormatter.dateFormat = "dd MMM, y HH:mm"
        time = dateFormatter.string(from: selectedDate)
        
        //change24Formated()
    }
    
    func change24Formated() {
        let dateAsString = postTime
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        let date = dateFormatter.date(from: dateAsString)
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        postTime = dateFormatter.string(from: date!)
    }
    
    func uploadMedia(mediaType: String) {
        
        do {
            
            if mediaType == "Video" {
                let videoData = try Data(contentsOf: selectedVideo!.asURL())
                selectedVideoData.append(videoData)
            } else {
                for audio in recorder.getRecordings {
                    let audioData = try Data(contentsOf: audio.audioURL.asURL())
                    selectedAudioData.append(audioData)
                }
            }
            
            if mediaType == "Video" {
                APIController.makeRequestReturnJSON(.addPostVideo(media: selectedVideoData, userId: SharedPreference.getUserData()!.id, postId: postId)) { [self] data, error, headerDic in
                    
                    if error == nil {
                        if recorder.getRecordings.count > 0 {
                            uploadMedia(mediaType: "Audio")
                        } else {
                            gotoHome()
                        }
                    } else {
                        MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
                    }
                }
            } else {
                APIController.makeRequestReturnJSON(.addPostAudio(media: selectedAudioData, userId: SharedPreference.getUserData()!.id, postId: postId)) { [self] data, error, headerDic in
                    if error == nil {
                        gotoHome()
                    } else {
                        MZUtilManager.showAlertWith(vc: self, title: "", message: (error?.desc)!, actionTitle: "OK")
                    }
                }
            }
            
        } catch {
            print ("loading file error")
        }
    }
    
    func gotoHome() {
        
        if let window = UIApplication.shared.windows.first {
            let vc: TabBarController = UIStoryboard(storyboard: .main).instantiateVC()
            window.rootViewController = vc
            window.makeKeyAndVisible()
        }
    }
}
extension AddPostViewController: MZAlertViewDelegate {
    
    func didSelectDate(date: Date?) {
        guard let date = date else {
            return
        }
        self.selectedDate = date
        
        otherContentRowCount()
    }
    
    func didSelectPhoneNumber(phone: String?) {
        guard let phone = phone else {
            return
        }
        self.phoneNumber = phone
        otherContentRowCount()
    }
}

extension AddPostViewController: FilterLocationDelegate {

    func locationForPost(location: CLLocationCoordinate2D, city: String, address: String, radius: Float) {
        
        self.city = city
        self.selectedLocation = location
        self.address = address
        self.selectedAddress = address
        self.radius = radius
        
        otherContentRowCount()
    }
}

extension AddPostViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        guard let image = image else {
            return
        }
        selectedImages.append(image)
        selectedImagesData.append(image.jpegData(compressionQuality: 0.75)!)
        self.mediaContantTableView.reloadData()
        self.mediaContantTableView.layoutIfNeeded()
    }
}

extension AddPostViewController: VideoPickerDelegate {
    
    func didSelect(url: URL?) {
        guard let url = url else {
            return
        }
        selectedVideo = url
        self.mediaContantTableView.reloadData()
        self.mediaContantTableView.layoutIfNeeded()
//        self.videoView.url = url
//        self.videoView.player?.play()
//        self.mediaContantTableView.reloadData()
        self.viewDidLayoutSubviews()
    }

}

extension AddPostViewController: SelectInterestDelegate {
    func selectedInterests(interests: [SubTopicData.Data]) {
        
        if interests.count > 0 {
            selectedSubTopic = interests.map { ($0.id) }.joined(separator: "|")
        }
        print("selectedInterests - \(selectedSubTopic)")
        subTypeButton.setTitle(String(interests.count) + " Slected", for: .normal)
        
        subTypeButton.setTitleColor(UIColor.white, for: .normal)
        subTypeButton.backgroundColor = UIColor.AppTheme.LightBlueColor
    }
}

extension AddPostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // video
            return (selectedVideo == nil ? 0 : 1)
        case 1: // Image
            return (selectedImages.isEmpty ? 0 : 1)
        case 2: // Audio
            return  recorder.getRecordings.count
        case 3: // Other Contant
            return contentArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddVideoCell") as! AddVideoCell
            cell.videoView.configureWithControl(url: selectedVideo)
            cell.removeVideoClosure = { [weak self] in
                self!.selectedVideo = nil
                self!.mediaContantTableView.reloadData()
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddImageCell") as! AddImageCell
            cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddAudioCell") as! AddAudioCell
            let cellData = recorder.getRecordings[indexPath.row]
            cell.audioTitleLabel.text =  "Voice note: \(cellData.duration)"

            cell.removeAudioClosure = { [weak self] in
                self!.recorder.deleteRecording(recordingData: cellData)
                self!.mediaContantTableView.reloadData()
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddOtherContantCell") as! AddOtherContantCell
            
            let cellData = contentArray[indexPath.row]
            cell.otherContantType = cellData.type
           
            switch cellData.type {
            case .phone:
                cell.optionTextLabel.text = cellData.data as? String ?? ""
            case .date:
                let date: Date = cellData.data as? Date ?? Date()
                cell.optionTextLabel.text = date.getFormattedDate("dd:MM:yy hh:mm:ss a")
            case .address:
                cell.optionTextLabel.text = cellData.data as? String ?? ""
            }
            cell.removeContantClosure = { [weak self] in 
                switch cellData.type {
                case .phone:    self!.phoneNumber = nil
                case .date:     self!.selectedDate = nil
                case .address:  self!.address = nil
                }
                self!.otherContentRowCount()
            }
            cell.configureCell()
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { // Video collection
            return tableView.frame.size.width / 2
        }
        if indexPath.section == 1 { // Video collection
            return tableView.frame.size.width / 3
        }
        return UITableView.automaticDimension
    }
}

extension AddPostViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddImageCollectionCell", for: indexPath) as! AddImageCollectionCell

        cell.imageView.backgroundColor = UIColor.AppTheme.PinkColor
        cell.imageView.image = selectedImages[indexPath.item]
        
        cell.removeImageClosure = { [weak self] in
            self!.selectedImages.remove(at: indexPath.row)
            self!.mediaContantTableView.reloadData()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemHeight = collectionView.frame.size.width/3
        
        return CGSize(width: itemHeight , height: itemHeight)
    }
}


struct ContantTypeData {
    var type: OtherContantType
    var data: Any
    
    init(type: OtherContantType, data: Any) {
        self.type = type
        self.data = data
    }
}
  
