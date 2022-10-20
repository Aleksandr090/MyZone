//
//  AudioRecorder.swift
//  MyZone
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject {
    
    //MARK: - Instance
    static let shared = AudioRecorder()
    
    //MARK: - Variables ( Private )
    private var audioSession : AVAudioSession = AVAudioSession.sharedInstance()
    private var audioRecorder : AVAudioRecorder!
    private var audioPlayer : AVAudioPlayer = AVAudioPlayer()
    
    private var settings =   [  AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                                AVSampleRateKey: 12000,
                                AVNumberOfChannelsKey: 1,
                                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue ]
    
    fileprivate var timer: Timer!
//    private var myRecordings = [String]()
    public var myRecordings = [MyRecording]()
    private var fileName : String?

    
    //MARK: - Public Variables
    /// Can be changed by user
    var isRecording : Bool = false
    var isPlaying : Bool = false
    var duration = CGFloat()
    var recordingName : String?
    var numberOfLoops : Int?
    
    
    //MARK: - Set Rate Limits
    var rate : Float?{
        didSet{
            if (rate! < 0.5) {
                rate = 0.5
                print("Rate cannot be less than 0.5")
            } else if (rate! > 2.0) {
                rate = 2.0
                print("Rate cannot exceed 2")
            }
        }
    }
    

    //MARK: - Pre - Recording Setup
    private func InitialSetup(){
        fileName = NSUUID().uuidString   ///  unique string value
        let audioFilename = getDocumentsDirectory().appendingPathComponent((recordingName?.appending(".m4a") ?? fileName!.appending(".m4a")))
        let myRec = MyRecording(fileName: recordingName ?? fileName!, duration: "", url: audioFilename)
        myRecordings.append(myRec)
//        if !checkRepeat(name: recordingName ?? fileName!) { print("Same name reused, recording will be overwritten")}
        
        do{ /// Setup audio player
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioPlayer.stop()
        } catch let audioError as NSError {
            print ("Error setting up: %@", audioError)
        }
    }
    
    
    //MARK: - Record
    func record(){
        InitialSetup()
        if let audioRecorder = audioRecorder{
            if !isRecording {
                do{
                    try audioSession.setActive(true)
                    duration = 0
                    isRecording = true
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateDuration), userInfo: nil, repeats: true) /// start  timer
                    audioRecorder.record() /// start recording
                    debugLog("Recording")
                } catch let recordingError as NSError{
                    print ("Error recording : %@", recordingError.localizedDescription)
            }
        }
    }
}
    
    
    //MARK: - Stop Recording
    func stopRecording(completion: (() -> Void)? = nil){
        if audioRecorder != nil{
            audioRecorder.stop() /// stop recording
            audioRecorder = nil
            do {
                try audioSession.setActive(false)
                isRecording = false
                debugLog("Recording Stopped")
                
                if !myRecordings.isEmpty {
                    myRecordings[myRecordings.count-1].duration = getDuration()
                }
            } catch {
                print("stop()",error.localizedDescription)
            }
        }
    }
    
    
    //MARK: - Play recording
    func play(completion: @escaping (Bool) -> ()){
        if !isRecording && !isPlaying {
            if let fileName = fileName {
             let path = getDocumentsDirectory().appendingPathComponent(fileName+".m4a")
                       do{
                        audioPlayer = try AVAudioPlayer(contentsOf: path)
                        (rate == nil) ? (audioPlayer.enableRate = false) : (audioPlayer.enableRate = true)
                        audioPlayer.rate = rate ?? 1.0   /// set rate
                        audioPlayer.delegate = self
                        audioPlayer.numberOfLoops = numberOfLoops ?? 0   /// set numberofloops
                        audioPlayer.play()   /// play
                        isPlaying = true
                        debugLog("Playing")
                        completion(true)
                       }catch{
                           print(error.localizedDescription)
                        }}else{
                        completion(false)
                        print("no file exists")
            }
        }else{
            completion(false)
            return
        }
    }
    
    
    //MARK: - Play by name
    func play(name:String) {
        
        let fileName = name + ".m4a"
        
        let path = getDocumentsDirectory().appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: path.path) && !isRecording && !isPlaying {
            audioPlayer.prepareToPlay()
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: path)
                audioPlayer.delegate = self
                audioPlayer.play()  /// play
                isPlaying = true
                debugLog("Playing")
            } catch {
                print("play(with name:), ",error.localizedDescription)
            }
        } else {
            print("File Does not Exist")
            return
        }
    }
    
    
    //MARK: - Stop Playing
    func stopPlaying(){
        audioPlayer.stop()   ///stop
        isPlaying = false
        debugLog("Stopped playing")
    }
    
    
    //MARK: - Delete Recording
    func deleteRecording(recordingData: MyRecording){
        let path = getDocumentsDirectory().appendingPathComponent(recordingData.fileName.appending(".m4a"))
        let manager = FileManager.default
        
        if manager.fileExists(atPath: path.path) {
            
            do {
                try manager.removeItem(at: path)
                removeRecordingFromArray(recordingData: recordingData)
                debugLog("Recording Deleted")
            } catch {
                print("delete()",error.localizedDescription)
            }
        } else {
            print("File is not exist.")
        }
    }
    
    
    //MARK: - remove recroding name instance
    private func removeRecordingFromArray(recordingData: MyRecording) {
        if let index = myRecordings.firstIndex(where: { $0.fileName == recordingData.fileName}) {
            myRecordings.remove(at: index)
        }
    }
    
    //MARK: - Remove ALL Recordings
    public func removeAllRecordings() {
        myRecordings.removeAll()
    }
    
    
    //MARK: - Restart
    func restartPlayer(){
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        audioPlayer.play()
        isPlaying = true
    }
    
    
    //MARK: - Get duration of recording
    func getDuration() -> String {
        return duration.timeStringFormatter
    }
    
    
    //MARK: - Live time
    func getCurrentTime() -> Double {
        return audioPlayer.currentTime
    }
    
    
    //MARK: - Check for overwritten files
//    private func checkRepeat(name: String) -> Bool{
//        var count = 0
//        if myRecordings.contains(name){
//            count = myRecordings.filter{$0 == name}.count
//        if count > 1{
//            while count != 1{
//                let index = myRecordings.firstIndex(of: name)
//                myRecordings.remove(at: index!)
//                count -= 1
//            }
//            return false
//        }
//        }
//        return true
//    }

    
    //MARK: - Track time
    @objc func updateDuration() {
        if isRecording && !isPlaying{
            duration += 1
        }else{
            timer.invalidate()
        }
    }
    
    //MARK: - Get path
    func getDocumentsDirectory() -> URL {
         let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
         return paths[0]
     }
}


//MARK: - AVAudioRecorder Delegate functions
extension AudioRecorder : AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        timer.invalidate()
        
        switch flag {
        case true:
            debugLog("record finish")
        case false:
            debugLog("record erorr")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        isRecording = false
        debugLog(error?.localizedDescription ?? "Error occured while encoding recorder")
    }
}


//MARK: - AVAudioPlayer Delegate functions
extension AudioRecorder: AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        debugLog("playing finish")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        isPlaying = false
        debugLog(error?.localizedDescription ?? "Error occured while encoding player")
    }
}


//MARK: - Convert Time to String
extension CGFloat{
    var timeStringFormatter : String {
        let format : String?
        let hours = Int(((self) / 60) / 60) % 60
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        format = "%02d : %02d : %02d"
        return String(format: format!, hours, minutes, seconds)
    }
}


//MARK: - Computed property to get list of recordings
extension AudioRecorder{
    var getRecordings : [MyRecording]{
        return self.myRecordings
    }
}


//MARK: - Easy debugging
public func debugLog(_ message: String) {
    #if DEBUG
    debugPrint("=================================================")
    debugPrint(message)
    debugPrint("=================================================")
    #endif
}

struct MyRecording {
    var fileName: String
    var duration: String
    var audioURL: URL
    
    init(fileName: String, duration: String, url: URL) {
        self.fileName = fileName
        self.duration = duration
        self.audioURL = url
    }
}
