//
//  ViewController.swift
//  SIRIDemo
//
//  Created by dharmendra valiya on 22/04/20.
//  Copyright © 2020 dharmendra valiya. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController , AVAudioRecorderDelegate{

    var audioRec: AVAudioRecorder?
    var recURL: URL!
    var audioPlayer : AVAudioPlayer?
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPerission()
        // Do any additional setup after loading the view.
    }
    @IBAction func recordClicked(_ sender: Any) {
        guard (audioRec != nil) else {
            recordAudio()
            return
        }
        if(audioRec?.isRecording)! {
            audioRec?.stop()
        }else{
            recordAudio()
        }
    }
    
    func checkPerission(){
        let recordingAuthorised = AVAudioSession.sharedInstance().recordPermission == .granted
        if !recordingAuthorised {
            requestRecordPermissions()
        }
        
        let transcribeAuthorised = SFSpeechRecognizer.authorizationStatus() == .authorized
        if !transcribeAuthorised {
            requestTranscribePermissions()
        }
    }
    
    func requestRecordPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { [unowned self] allowed in
            if allowed {
                
            }else{
                
            }
        }
    }
    
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { [unowned self] authStatus in
            if authStatus == .authorized {
                
            }else{
                
            }
        }
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.recordingLabel.alpha = 0
        if !flag {
            
        }else{
            playAudio()
            transcribeAudio()
        }
    }
    
    func recordAudio () {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        recURL = path[0].appendingPathComponent("temp.mp4")
        
        if FileManager.default.fileExists(atPath: recURL.absoluteString) {
            do {
                try FileManager.default.removeItem(atPath: recURL.absoluteString)
            }catch {
                
            }
        }
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true)
            
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey:44100,
                            AVNumberOfChannelsKey:2,
                            AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue]
            
            audioRec = try AVAudioRecorder(url: recURL, settings: settings)
            audioRec?.delegate = self
            audioRec?.record()
            self.recordingLabel.alpha = 1
            
        }catch {
            
        }
    }
    
    func playAudio() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: recURL)
            audioPlayer?.play()
            
        }catch{
            
        }
    }
    
    func transcribeAudio() {
        let recogniser = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: recURL)
        
        recogniser?.recognitionTask(with: request) { [unowned self] (result , error) in
            
            guard let result = result else {
                return
            }
            
            let text = result.bestTranscription.formattedString
            self.textView.text = text
            
            if result.isFinal {
                let text = result.bestTranscription.formattedString
                self.textView.text = text
            }
            
        }
    }
}

