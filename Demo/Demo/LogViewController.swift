//
//  LogViewController.swift
//  IF_FirebaseFollowHelper
//
//  Created by 久保島 祐磨 on 2016/05/08.
//  Copyright © 2016年 ICT Fractal Inc. All rights reserved.
//

import UIKit

class LogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	var log = [(message: String, date: NSDate)]()
	
	@IBOutlet weak var tableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogViewController.handleNotification(_:)), name: nil, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	func addLog(message: String) {
		self.log.insert((message, NSDate()), atIndex: 0)
		self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
	}

    // MARK: TableView
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return log.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
		let message = self.log[indexPath.row]
		cell.textLabel?.text = message.message
		
		let formatter = NSDateFormatter()
		formatter.locale = NSLocale.systemLocale()
		formatter.dateStyle = .NoStyle
		formatter.timeStyle = .LongStyle
		cell.detailTextLabel?.text = formatter.stringFromDate(message.date)
		
		return cell
	}

	// MARK: NSNotificationCenter.messasge
	
	func handleNotification(notification: NSNotification) {
		switch notification.name {
		case IF_FirebaseFollowHelperMessage.AddedFollow:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String {
					self.addLog("added follow [\(uid)]")
				}
			}
		case IF_FirebaseFollowHelperMessage.FailedFollow:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String {
					self.addLog("failed follow [\(uid)]")
				}
			}
		case IF_FirebaseFollowHelperMessage.DidAddFollowProc:
			self.addLog("did add follow proc.")
		case IF_FirebaseFollowHelperMessage.RemovedFollow:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String {
					self.addLog("removed follow [\(uid)]")
				}
			}
		case IF_FirebaseFollowHelperMessage.FailedRemoveFollow:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String {
					self.addLog("failed remove follow [\(uid)]")
				}
			}
		case IF_FirebaseFollowHelperMessage.DidRemoveFollowProc:
			self.addLog("did remove follow proc.")
		case IF_FirebaseFollowHelperMessage.AddedFollower:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String {
					self.addLog("[\(uid)] followed you")
				}
			}
		case IF_FirebaseFollowHelperMessage.RemovedFollower:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String {
					self.addLog("[\(uid)] unfollowed you")
				}
			}
		case IF_FirebaseFollowHelperMessage.AddedBlock:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String {
					self.addLog("added block [\(uid)]")
				}
			}
		case IF_FirebaseFollowHelperMessage.FailedBlock:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String {
					self.addLog("failed add block [\(uid)]")
				}
			}
		case IF_FirebaseFollowHelperMessage.DidAddBlockProc:
			self.addLog("did add block proc.")
		case IF_FirebaseFollowHelperMessage.RemovedBlock:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String {
					self.addLog("removed block [\(uid)]")
				}
			}
		case IF_FirebaseFollowHelperMessage.FailedRemoveBlock:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String {
					self.addLog("failed remove block [\(uid)]")
				}
			}
		case IF_FirebaseFollowHelperMessage.DidRemoveBlockProc:
			self.addLog("did remove block proc.")
		case IF_FirebaseFollowHelperMessage.BlockedFromSomeone:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String {
					self.addLog("[\(uid)] blocked you")
				}
			}
		case IF_FirebaseFollowHelperMessage.RemoveBlockFromSomeone:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String {
					self.addLog("[\(uid)] unblocked you")
				}
			}
		default:
			break
		}
	}
}
