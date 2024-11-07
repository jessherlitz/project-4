//
//  ViewController.swift
//  project-4
//
//  Created by Jessica Sampaio-Herlitz on 11/6/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var StartStopButton: UIButton!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    private var clockTimer: Timer?
    private var countdownTimer: Timer?
    private var totalTimeInSeconds: Int = 0
    private var audioPlayer: AVAudioPlayer?
    private var isTimerRunning = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAudioSession()
        startClock()
        updateUI()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio - \(error)")
        }
    }
    
    private func startClock() {
        clockTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        updateTime()
    }
    
    @objc private func updateTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium 
        dateFormatter.timeStyle = .medium
        date.text = dateFormatter.string(from: Date())
        
        dateFormatter.dateFormat = "a"
        let period = dateFormatter.string(from: Date())
        
        if period == "AM" {
            background.image = UIImage(named: "sun_background")
        } else {
            background.image = UIImage(named: "sun_background")
        }
    }
    
    deinit {
        clockTimer?.invalidate()
        countdownTimer?.invalidate()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        if sender.currentTitle == "Start Timer" {
            startTimer()
        } else if sender.currentTitle == "Stop Timer" && getTimeRemainingInSeconds() > 0 {
            updateUI()
        } else if sender.currentTitle == "Stop Music" {
            stopMusic()
        }
    }
    
    private func startTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        totalTimeInSeconds = Int(datePicker.countDownDuration)
        StartStopButton.setTitle("", for: .normal)
        StartStopButton.setTitle("Stop Timer", for: .normal)
        updateLabelWithTime(totalTimeInSeconds)
        
        datePicker.isEnabled = false
        isTimerRunning = true
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    @objc private func updateCountdown() {
        if totalTimeInSeconds > 0 {
            totalTimeInSeconds -= 1
            updateLabelWithTime(totalTimeInSeconds)
        } else if totalTimeInSeconds == 0 && isTimerRunning {
            countdownTimer?.invalidate()
            countdownTimer = nil
            isTimerRunning = false
            playSound()
            StartStopButton.setTitle("Stop Music", for: .normal)
        }
    }
    
    private func playSound() {
        guard let url = Bundle.main.url(forResource: "London", withExtension: "mp3") else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("Unable to play sound: \(error)")
        }
    }
    
    private func updateLabelWithTime(_ seconds: Int) {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        timeRemainingLabel.text = String(format: "Time remaining: %02d:%02d:%02d", hours, minutes, remainingSeconds)
    }
    
    private func stopMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
        updateUI()
    }
    
    private func updateUI() {
        view.backgroundColor = UIColor.white
        isTimerRunning = false
        datePicker.countDownDuration = 0
        timeRemainingLabel.text = "Time remaining: 00:00:00"
        StartStopButton.setTitle("Start Timer", for: .normal)
        totalTimeInSeconds = 0
        datePicker.isEnabled = true
    }
    
    func getTimeRemainingInSeconds() -> Int {
        guard let timeText = timeRemainingLabel.text else { return 0 }

        let timeComponents = timeText.split(separator: ":")
        
        let hours = Int(timeComponents[1]) ?? 0
        let minutes = Int(timeComponents[2]) ?? 0
        let seconds = Int(timeComponents[3]) ?? 0

        if hours > 0 {
            return hours
        } else if minutes > 0 {
            return minutes
        } else if seconds > 0 {
            return seconds
        } else {
            return 0
        }
    }
}

