//
//  UsersViewController.swift
//  IF_FirebaseFollowHelper
//
//  Created by 久保島 祐磨 on 2016/05/08.
//  Copyright © 2016年 ICT Fractal Inc. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UserInfoCellDelegate {
	
	// ************************************
	// Please set the firebaseURL.
	// ************************************
	let firebaseURL = ""
	
	
	let usersPath = "users"
	var firebaseRef: Firebase!
	var usersRef: Firebase!
	var followHelper: IF_FirebaseFollowHelper!
	
	let defaultUserMail = "user01@test.com"
	let userMaxNo = 20
	
	var usersInfo		= [(name: String, uid: String)]()
	var followList		= [IF_FirebaseFollowHelperBasicUserInfo]()
	var followerList	= [IF_FirebaseFollowHelperBasicUserInfo]()
	var blockList		= [IF_FirebaseFollowHelperBasicUserInfo]()
	var blockerList		= [IF_FirebaseFollowHelperBasicUserInfo]()
	
	var indicatorView: UIAlertController?
	var chooseAccountRow = 0
	
	var treatedStartingProc = false

	@IBOutlet weak var userInfoButton: UIButton!
	@IBOutlet weak var tableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let nib = UINib(nibName: "UserInfoCell", bundle: nil)
		self.tableView.registerNib(nib, forCellReuseIdentifier: "Cell")
		self.tableView.rowHeight = 102
		
		assert(self.firebaseURL != "", "Please set the firebaseURL.")
		self.firebaseRef = Firebase(url: self.firebaseURL)
		self.usersRef = self.firebaseRef.childByAppendingPath(self.usersPath)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UsersViewController.handleNotification(_:)), name: nil, object: nil)
		
		if let controller = self.parentViewController as? UITabBarController {
			controller.selectedIndex = 1
			controller.selectedIndex = 0
		}
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		func createOtherAccount(userNo: Int, maxNo: Int, isAddedOtherAccount: Bool, completion: ((isAddedOtherAccount: Bool) -> Void)?) {
			let userName = String(format: "user%02d", userNo)
			let exist = self.usersInfo.map(){ $0.0 }.filter(){ $0 == userName }
			if exist.count == 0 {
				self.indicatorView?.message = "Create other account. [\(userName)]"
				self.createAccount("\(userName)@test.com", pass: "pass", auth: true, completion: {
					self.addUserData(userName, uid: self.firebaseRef.authData.uid)
					self.userInfoButton.setTitle(userName, forState: .Normal)
					if userNo < maxNo {
						createOtherAccount(userNo + 1, maxNo: maxNo, isAddedOtherAccount: true, completion: completion)
					}
					else {
						completion?(isAddedOtherAccount: true)
					}
				})
			}
			else {
				if userNo < maxNo {
					createOtherAccount(userNo + 1, maxNo: maxNo, isAddedOtherAccount: isAddedOtherAccount, completion: completion)
				}
				else {
					completion?(isAddedOtherAccount: isAddedOtherAccount)
				}
			}
		}
		
		if self.treatedStartingProc == false {
			self.treatedStartingProc = true
			
			self.indicatorView = self.createIndicatorView("processing.", message: "Sign in.")
			self.presentViewController(self.indicatorView!, animated: true, completion: nil)
			
			self.auth(self.defaultUserMail, pass: "pass", completion: {
				self.followHelper = IF_FirebaseFollowHelper(firebaseRef: self.firebaseRef)
				self.addUserData("user01", uid: self.firebaseRef.authData.uid)
				self.userInfoButton.setTitle("user01", forState: .Normal)
				
				self.indicatorView?.message = "Retrieving users information."
				self.createUsersInfo() {
					createOtherAccount(2, maxNo: self.userMaxNo, isAddedOtherAccount: false, completion: { isAddedOtherAccount in
						self.indicatorView?.message = "Sign in."
						self.auth(self.defaultUserMail, pass: "pass", completion: {
							self.addUserData("user01", uid: self.firebaseRef.authData.uid)
							self.createDataSourcesProc() {
								self.indicatorView?.dismissViewControllerAnimated(true, completion: nil)
								self.tableView.reloadData()
							}
						})
					})
				}
			})
		}
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func addUserData(name: String, uid: String) {
		self.usersRef.queryOrderedByChild("uid").queryEqualToValue(uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
			if snapshot.childrenCount == 0 {
				let autoIdPath = self.usersRef.childByAutoId()
				let dic = ["name": name, "uid": uid]
				autoIdPath.updateChildValues(dic)
			}
		})
	}
	
	func createAccount(mail: String, pass: String, auth: Bool, completion: (() -> Void)?) {
		self.firebaseRef.createUser(mail, password: pass, withCompletionBlock: {
			if $0 != nil {
				print($0)
			}
			else {
				if auth == true {
					self.auth(mail, pass: pass, completion: completion)
				}
				else {
					completion?()
				}
			}
		})
	}
	
	func auth(mail: String, pass: String, completion: (() -> Void)?) {
		self.firebaseRef.authUser(mail, password: pass, withCompletionBlock: { error, authData in
			if error != nil {
				self.createAccount(mail, pass: pass, auth: true, completion: completion)
			}
			else {
				completion?()
			}
		})
	}
	
	func createUsersInfo(completion: (() -> Void)?) {
		self.usersRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
			self.usersInfo.removeAll()
			snapshot.children.forEach() {
				let child = $0 as! FDataSnapshot
				if let name = child.value["name"] as? String, let uid = child.value["uid"] as? String {
					if uid != self.firebaseRef.authData.uid {
						self.usersInfo.append((name, uid))
					}
				}
				else {
					print("Incorrect data. [\(child)]")
				}
			}
			
			self.usersInfo = self.usersInfo.sort() { $0.0 < $1.0 }
			completion?()
		})
	}
	
	func createDataSourcesProc(completion: (() -> Void)?) {
		self.indicatorView?.message = "Retrieving users information."
		self.createUsersInfo() {
			self.indicatorView?.message = "Retrieving follow list."
			self.followHelper.getFollowList() { 
				self.followList = $0
				self.indicatorView?.message = "Retrieving follower list."
				self.followHelper.getFollowerList() { 
					self.followerList = $0
					self.indicatorView?.message = "Retrieving block list."
					self.followHelper.getBlockList() {
						self.blockList = $0
						self.indicatorView?.message = "Retrieving blocker list."
						self.followHelper.getBlockerList() {
							self.blockerList = $0
							completion?()
						}
					}
				}
			}
		}
	}
	
	func createIndicatorView(title: String?, message: String?) -> UIAlertController {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		let contentViewController = UIViewController()
		
		let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
		indicator.color = UIColor.blackColor()
		indicator.startAnimating()
		
		contentViewController.view .addSubview(indicator)
		
		contentViewController.view.addConstraint(NSLayoutConstraint(item: indicator, attribute: .CenterX, relatedBy: .Equal, toItem: contentViewController.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
		
		contentViewController.view.addConstraint(NSLayoutConstraint(item: indicator, attribute: .CenterY, relatedBy: .Equal, toItem: contentViewController.view, attribute: .CenterY, multiplier: 1.0, constant: -10.0))
		
		alert.setValue(contentViewController, forKey: "contentViewController")
		
		return alert
	}
	
	func createAccountListView() -> UIAlertController {
		let alert = UIAlertController(title: "Sign in", message: "Choose account.", preferredStyle: .Alert)
		let contentViewController = UIViewController()
		
		let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 130, height: 130))
		pickerView.dataSource = self
		pickerView.delegate = self
		contentViewController.view.addSubview(pickerView)
		
		contentViewController.view.addConstraint(NSLayoutConstraint(item: pickerView, attribute: .CenterX, relatedBy: .Equal, toItem: contentViewController.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
		
		contentViewController.view.addConstraint(NSLayoutConstraint(item: pickerView, attribute: .CenterY, relatedBy: .Equal, toItem: contentViewController.view, attribute: .CenterY, multiplier: 1.0, constant: -10.0))
		
		alert.setValue(contentViewController, forKey: "contentViewController")
		
		let okAction = UIAlertAction(title: "Choose", style: .Default) { action in
			let mail = String(format: "user%02d@test.com", self.chooseAccountRow + 1)
			self.indicatorView = self.createIndicatorView("processing.", message: "Sign in.")
			self.presentViewController(self.indicatorView!, animated: true, completion: nil)
			self.auth(mail, pass: "pass") {
				self.userInfoButton.setTitle(String(format: "user%02d", self.chooseAccountRow + 1), forState: .Normal)
				self.createDataSourcesProc() {
					self.indicatorView?.dismissViewControllerAnimated(true, completion: nil)
					self.tableView.reloadData()
				}
			}
		}
		alert.addAction(okAction)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
			
		}
		alert.addAction(cancelAction)
		
		self.chooseAccountRow = 0
		return alert
	}

	@IBAction func handleUserInfoButton_Tap(sender: AnyObject) {
		let alert = self.createAccountListView()
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	// MARK: TableView
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.usersInfo.count
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UserInfoCell
		cell.delegate = self
		cell.selectionStyle = .None
		
		let userInfo = self.usersInfo[indexPath.row]
		cell.userNameLabel.text = userInfo.name
		
		let followerCheck = self.followerList.filter() { $0.0 == userInfo.uid }
		cell.setHasFollowState(followerCheck.count > 0)
		
		let blockerCheck = self.blockerList.filter() { $0.0 == userInfo.uid }
		cell.setHasBlockedState(blockerCheck.count > 0)
		
		let followCheck = self.followList.filter() { $0.0 == userInfo.uid }
		cell.setFollowState(followCheck.count > 0)
		
		let blockCheck = self.blockList.filter() { $0.0 == userInfo.uid }
		cell.setBlockState(blockCheck.count > 0)
		
		return cell
	}
	
	func updateCellFromUid(uid: String) {
		if let row = self.usersInfo.indexOf({ $0.uid == uid }) {
			self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: 0)], withRowAnimation: .Middle)
		}
	}
	
	// MARK: PickerView
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return self.userMaxNo
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return String(format: "user%02d", row + 1)
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		self.chooseAccountRow = row
	}
	
	
	// MARK: UserInfoCellDelegate
	
	func userInfoCell(cell: UserInfoCell, requestFollowStateTo: Bool) {
		if let indexPath = self.tableView.indexPathForCell(cell) {
			self.indicatorView = self.createIndicatorView("processing.", message: "updateing follow state.")
			self.presentViewController(self.indicatorView!, animated: true, completion: nil)
			
			let userInfo = self.usersInfo[indexPath.row]
			if requestFollowStateTo == true {
				self.followHelper.follow(userInfo.uid)
			} else {
				self.followHelper.unFollow(userInfo.uid)
			}
		}
	}
	
	func userInfoCell(cell: UserInfoCell, requestBlockStateTo: Bool) {
		if let indexPath = self.tableView.indexPathForCell(cell) {
			self.indicatorView = self.createIndicatorView("processing.", message: "updateing block state.")
			self.presentViewController(self.indicatorView!, animated: true, completion: nil)
			
			let userInfo = self.usersInfo[indexPath.row]
			if requestBlockStateTo == true {
				self.followHelper.block(userInfo.uid)
			} else {
				self.followHelper.unBlock(userInfo.uid)
			}
		}
	}
	
	// MARK: NSNotificationCenter.messasge
	
	func handleNotification(notification: NSNotification) {
		switch notification.name {
		case IF_FirebaseFollowHelperMessage.AddedFollow:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String, let timestamp = userInfo["timestamp"] as? NSDate {
					if self.followList.contains({ $0.uid == uid }) == false {
						self.followList.append((uid, timestamp))
						self.updateCellFromUid(uid)
					}
				}
			}
		case IF_FirebaseFollowHelperMessage.FailedFollow:
			break
		case IF_FirebaseFollowHelperMessage.DidAddFollowProc:
			self.indicatorView?.dismissViewControllerAnimated(true, completion: nil)
		case IF_FirebaseFollowHelperMessage.RemovedFollow:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String {
					if let index = self.followList.indexOf({ $0.uid == uid }) {
						self.followList.removeAtIndex(index)
						self.updateCellFromUid(uid)
					}
				}
			}
		case IF_FirebaseFollowHelperMessage.FailedRemoveFollow:
			break
		case IF_FirebaseFollowHelperMessage.DidRemoveFollowProc:
			self.indicatorView?.dismissViewControllerAnimated(true, completion: nil)
		case IF_FirebaseFollowHelperMessage.AddedFollower:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String, let timestamp = userInfo["timestamp"] as? NSDate {
					if self.followerList.contains({ $0.uid == uid }) == false {
						self.followerList.append((uid, timestamp))
						self.updateCellFromUid(uid)
					}
				}
			}
		case IF_FirebaseFollowHelperMessage.RemovedFollower:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String {
					if let index = self.followerList.indexOf({ $0.uid == uid }) {
						self.followerList.removeAtIndex(index)
						self.updateCellFromUid(uid)
					}
				}
			}
		case IF_FirebaseFollowHelperMessage.AddedBlock:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String, let timestamp = userInfo["timestamp"] as? NSDate {
					if self.blockList.contains({ $0.uid == uid }) == false {
						self.blockList.append((uid, timestamp))
						self.updateCellFromUid(uid)
					}
				}
			}
		case IF_FirebaseFollowHelperMessage.FailedBlock:
			break
		case IF_FirebaseFollowHelperMessage.DidAddBlockProc:
			self.indicatorView?.dismissViewControllerAnimated(true, completion: nil)
		case IF_FirebaseFollowHelperMessage.RemovedBlock:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String {
					if let index = self.blockList.indexOf({ $0.uid == uid }) {
						self.blockList.removeAtIndex(index)
						self.updateCellFromUid(uid)
					}
				}
			}
		case IF_FirebaseFollowHelperMessage.FailedRemoveBlock:
			break
		case IF_FirebaseFollowHelperMessage.DidRemoveBlockProc:
			self.indicatorView?.dismissViewControllerAnimated(true, completion: nil)
		case IF_FirebaseFollowHelperMessage.BlockedFromSomeone:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String, let timestamp = userInfo["timestamp"] as? NSDate {
					if self.blockerList.contains({ $0.uid == uid }) == false {
						self.blockerList.append((uid, timestamp))
						self.updateCellFromUid(uid)
					}
				}
			}
		case IF_FirebaseFollowHelperMessage.RemoveBlockFromSomeone:
			if let userInfo = notification.userInfo {
				if let uid = userInfo["uid"] as? String {
					if let index = self.blockerList.indexOf({ $0.uid == uid }) {
						self.blockerList.removeAtIndex(index)
						self.updateCellFromUid(uid)
					}
				}
			}
		default:
			break
		}
	}
}
