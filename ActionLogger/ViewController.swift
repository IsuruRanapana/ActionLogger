//
//  ViewController.swift
//  ActionLogger
//
//  Created by Isuru Ranapana on 12/27/24.
//

import UIKit
import ReplayKit

class ViewController: UIViewController {
    //for logging
    private var isLogging = false
    private var logData: [String] = []
    
    // for screen record
    let screenRecorder = RPScreenRecorder.shared()
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func startLogging(_ sender: UIButton) {
        guard !isLogging else { return }
        isLogging = true
        logData.removeAll()
        logMessage("Logging started")
        for number in 1...25 {
            logMessage("Loop on numbers \(number)")
        }
        startScreenRecord()
        
    }
    
    @IBAction func stopLogging(_ sender: UIButton) {
        guard isLogging else { return }
        stopScreenRecord()
        logMessage("Logging stopped")
        isLogging = false
        saveLogToFile()
    }
    
    private func logMessage(_ message: String) {
        let timestamp = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = formatter.string(from:timestamp)
        let logEntry = "[\(formattedDate)] \(message)"
        logData.append(logEntry)
        print(logEntry)
    }
    
    private func saveLogToFile() {
        let logs = logData.joined(separator: "\n")
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to find documents directory")
            return
        }
        
        let fileURL = directory.appendingPathComponent("log.txt")
        
        do {
            try logs.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Logs saved to \(fileURL.path)")
        } catch {
            print("Failed to save logs: \(error.localizedDescription)")
        }
    }
    
    private func startScreenRecord(){
        guard !isRecording else { return } // Prevent multiple starts
        isRecording = true
        
        // Start screen recording
        screenRecorder.startRecording { [weak self] error in
            if let error = error {
                self?.isRecording = false
                print("Failed to start recording: \(error.localizedDescription)")
                return
            }
            print("Started recording successfully!")
        }
    }
    
    private func stopScreenRecord(){
        guard isRecording else { return } // Prevent stop if not recording
        isRecording = false
        
        // Stop recording and save to local storage
        screenRecorder.stopRecording { [weak self] previewController, error in
            if let error = error {
                print("Failed to stop recording: \(error.localizedDescription)")
                return
            }
            print("Stopped recording successfully!")
            
            // Save recording to local storage
            previewController?.modalPresentationStyle = .fullScreen
            previewController?.previewControllerDelegate = self
            self?.present(previewController!, animated: true)
        }
    }
}

extension ViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }
}

