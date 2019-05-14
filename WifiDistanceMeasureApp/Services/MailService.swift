//
//  MailService.swift
//  WifiDistanceMeasureApp
//
//  Created by Steven Hernandez on 5/14/19.
//  Copyright © 2019 MoWiNG Lab. All rights reserved.
//

import Foundation
import MessageUI

class MailService: NSObject, MFMailComposeViewControllerDelegate {
    var data: [String]!
    
    func send(data: [String], viewController: ViewController) {
        self.data = data
        let emailViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            viewController.present(emailViewController, animated: true, completion: nil)
        }
    }
    
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let emailController = MFMailComposeViewController()
        
        emailController.mailComposeDelegate = self
        
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        emailController.setSubject("WiFiDistanceMeasureApp Experiments")
        emailController.setMessageBody("From: \(deviceId).", isHTML: false)
        
        let content = data.joined(separator: "\n")
        let uniqueName = String(describing: Date().millisecondsSince1970())
        emailController.addAttachmentData(content.data(using: .utf8)!, mimeType: "text/csv", fileName: "\(deviceId).\(uniqueName).csv")
        
        return emailController
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
