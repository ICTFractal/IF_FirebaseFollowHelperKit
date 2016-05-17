//
//  IF_FirebaseFollowHelper.swift
//  IF_FirebaseFollowHelper
//
//  Created by 久保島 祐磨 on 2016/04/21.
//  Copyright © 2016年 ICT Fractal Inc. All rights reserved.
//

import UIKit
import Firebase

/*
Firebaseデータ構造
 root
  +IFFollowHelper
   +Follow				(フォロー情報ノード）
    +autoID
     -uid				(ログインユーザのuid)
     -followID			(フォロー対象ユーザのuid)
     -notifiedUser		(ログインユーザに通知したか)
     -notifiedFollower	(フォロー対象ユーザに通知したか)
     -timestamp			(レコードを作成したサーバー日時)
    +autoID
    ...

   +Block				(ブロック情報ノード)
    +autoID
     -uid				(ログインユーザのuid)
     -blockID			(ブロック対象ユーザのuid)
     -notifiedUser		(ログインユーザに通知したか)
     -notifiedBlockUser	(ブロック対象ユーザに通知したか)
     -timestamp			(レコードを作成したサーバー日時)
	+autoID
	...
*/

/// IF_FirebaseFollowHelper間でやり取りされるユーザ情報Tupleの別名定義
public typealias IF_FirebaseFollowHelperBasicUserInfo = (uid: String, timestamp: NSDate)

/**
	IF_FirebaseFollowHelperからNSNotificationCenterへ発行されるメッセージ
	
	notification.userInfoから詳細な情報を得る事ができます。   
*/
public struct IF_FirebaseFollowHelperMessage {
	/**
		ログインユーザが他ユーザをフォローした際に通知されます  
	
		notification.userInfoから詳細な情報を得る事ができます。   
	
		- parameter uid:		対象のuid
		- parameter timestamp:	処理日時（server)
	*/
	public static let AddedFollow = "IF_FirebaseFollowHelperMessage_AddedFollow"
	
	/**
		フォロー追加処理に失敗した際に通知されます  
	
		notification.userInfoから詳細な情報を得る事ができます。  
	
		- parameter uid:		対象のuid
		- parameter timestamp:	処理日時(local)
		- parameter error:		エラー情報
	*/
	public static let FailedFollow = "IF_FirebaseFollowHelperMessage_FailedFollow"
	
	/**
		フォロー追加処理完了時に通知されます  
	
		- attention : ローカルの処理完了通知であり、サーバからの応答タイミングは保証しません。
	*/
	public static let DidAddFollowProc = "IF_FirebaseFollowHelperMessage_DidAddFollowProc"
	
	/**
		ログインユーザが他ユーザのフォローを解除した際に通知されます
		
		notification.userInfoから詳細な情報を得る事ができます。  
	
		- parameter uid:		対象のuid
		- parameter timestamp:	フォロー日時
	*/
	public static let RemovedFollow = "IF_FirebaseFollowHelperMessage_RemovedFollow"
	
	/**
		フォロー解除処理に失敗した際に通知されます  
	
		notification.userInfoから詳細な情報を得る事ができます。   

		- parameter uid:		対象のuid
		- parameter timestamp:	処理日時(local)
		- parameter error:		エラー情報
	*/
	public static let FailedRemoveFollow = "IF_FirebaseFollowHelperMessage_FailedRemoveFollow"
	
	/**
		フォロー解除処理完了時に通知されます
	
		- attention : ローカルの処理完了通知であり、サーバからの応答タイミングは保証しません。
	*/
	public static let DidRemoveFollowProc = "IF_FirebaseFollowHelperMessage_DidRemoveFollowProc"
	
	/**
		他ユーザがログインユーザをフォローした際に通知されます

		notification.userInfoから詳細な情報を得る事ができます。   
	
		- parameter uid:		対象のuid
		- parameter timestamp:	フォロー日時
	*/
	public static let AddedFollower = "IF_FirebaseFollowHelperMessage_AddedFollower"
	
	/**
		他ユーザがログインユーザのフォローを解除した際に通知されます

		notification.userInfoから詳細な情報を得る事ができます。   
	
		- parameter uid:		対象のuid
		- parameter timestamp:	フォロー日時
	*/
	public static let RemovedFollower = "IF_FirebaseFollowHelperMessage_RemovedFollower"
	
	/**
		ログインユーザが他ユーザをブロックした際に通知されます

		notification.userInfoから詳細な情報を得る事ができます。   
	
		- parameter uid:		対象のuid
		- parameter timestamp:	処理日時(server)
	*/
	public static let AddedBlock = "IF_FirebaseFollowHelperMessage_AddedBlock"
	
 	/**
		ブロック追加処理に失敗した際に通知されます
	
		notification.userInfoから詳細な情報を得る事ができます。   
		
	
		- parameter uid:		対象のuid
		- parameter timestamp:	処理日時(local)
		- parameter error:		エラー情報
	*/
	public static let FailedBlock = "IF_FirebaseFollowHelperMessage_FailedBlock"
	
	/**
		ブロック追加処理完了時に通知されます
	
		- attention : ローカルの処理完了通知であり、サーバからの応答タイミングは保証しません。
	*/
	public static let DidAddBlockProc = "IF_FirebaseFollowHelperMessage_DidAddBlockProc"
	
 	/**
		ログインユーザが他ユーザのブロックを解除した際に通知されます  
	
		notification.userInfoから詳細な情報を得る事ができます。   
	
		- parameter uid:		対象のuid
		- parameter timestamp:	ブロック日時
	*/
	public static let RemovedBlock = "IF_FirebaseFollowHelperMessage_RemovedBlock"
	
	/**
		ブロック解除処理に失敗した際に通知されます

		notification.userInfoから詳細な情報を得る事ができます。   
	
		- parameter uid:		対象のuid
		- parameter timestamp:	処理日時(local)
		- parameter error:		エラー情報
	*/
	public static let FailedRemoveBlock = "IF_FirebaseFollowHelperMessage_FailedRemoveBlock"
	
	/**
		ブロック解除処理完了時に通知されます
	
		- attention : ローカルの処理完了通知であり、サーバからの応答タイミングは保証しません。
	*/
	public static let DidRemoveBlockProc = "IF_FirebaseFollowHelperMessage_DidRemoveBlockProc"
	
	/**
		他ユーザがログインユーザをブロックした際に通知されます

		notification.userInfoから詳細な情報を得る事ができます。   
	
		- parameter uid:		対象のuid
		- parameter timestamp:	ブロック日時
	*/
	public static let BlockedFromSomeone = "IF_FirebaseFollowHelperMessage_BlockedFromSomeone"
	
	/**
		他ユーザがログインユーザのブロックを解除した際に通知されます

		notification.userInfoから詳細な情報を得る事ができます。   
	
		- parameter uid:		対象のuid
		- parameter timestamp:	ブロック日時
	*/
	public static let RemoveBlockFromSomeone = "IF_FirebaseFollowHelperMessage_RemoveBlockFromSomeone"
}

/**
Firebaseにフォロー/フォロワー管理機能を追加すヘルパークラス

主な特徴は次の通りです。  
1. Firebaseのデータ構造を意識せずに、フォロー関連の機能を利用できます  
2. 他ユーザがログインユーザに関わる操作を行った場合、リアルタイムに通知を受け取る事ができます

- important: イベントはリアルタイムにNSNotificationCenterから通知されます。  
			 通知は１つのイベントにつき１回のみです。  
             すべての通知を受け取りたい場合は初回インスタンス生成以降、常にいずれかのインスタンスにオブザーバを設定してください。
*/
public class IF_FirebaseFollowHelper {

	private var firebaseRef: Firebase!
	private var followRef: Firebase!
	private var blockRef: Firebase!
	private let followHelperPath		= "IFFollowHelper"
	private let followPath				= "Follow"
	private let blockPath				= "Block"
	
	// firebase項目
	private let item_uid				= "uid"
	private let item_followID			= "followID"
	private let item_notifiedUser		= "notifiedUser"
	private let item_notifiedFollower	= "notifiedFollower"
	private let item_timestamp			= "timestamp"
	private let item_blockID			= "blockID"
	private let item_notifiedBlockUser	= "notifiedBlockUser"
	
	// オブザーバ登録
	private var observeUID = ""
	private var observeHandles = [(FQuery, UInt)]()
	
	// NSNotification.userInfo項目
	private let notifyInfo_uid			= "uid"
	private let notifyInfo_timestamp	= "timestamp"
	private let notifyInfo_error		= "error"
	
	/// error domain
	public static let errorDomain		= "IF_FirebaseFollowHelper"
	
	/// error code
	public enum errorCode: Int {
		/// 不明
		case Unknown			= 0
		
		/// ブロック由来の処理失敗
		case FailureByBlock
	}
	
	/// デバッグ情報出力設定
	public static var outputDebug = true
	
	private init() {
		self.firebaseRef = nil
	}
	
	/**
	- parameter firebaseRef: ユーザ認証済みであり、URLの設定されたFirebaseオブジェクト
	*/
	public init(firebaseRef: Firebase) {
		self.firebaseRef = firebaseRef
		self.followRef	= self.firebaseRef.childByAppendingPath(self.followHelperPath).childByAppendingPath(self.followPath)
		self.blockRef	= self.firebaseRef.childByAppendingPath(self.followHelperPath).childByAppendingPath(self.blockPath)
		assert(self.firebaseRef.authData != nil, "no user is signed in.")
		
		self.observeUID = self.firebaseRef.authData.uid
		self.observe()
		
		// ユーザ切り替えに対応
		self.firebaseRef.observeAuthEventWithBlock() { authData in
			if self.observeUID != authData.uid {
				self.observeUID = authData.uid
				self.observe()
			}
		}
		
	}
	
	/**
	オブザーバ登録
	*/
	private func observe() {
		self.debugLog("add observe [\(self.firebaseRef.authData.uid)]")
		
		self.observeHandles.forEach() {
			$0.removeObserverWithHandle($1)
		}
		self.observeHandles.removeAll()
		
		// Followノードの監視対象
		let targetFollowRef		= self.followRef.queryOrderedByChild(item_uid).queryEqualToValue(self.firebaseRef.authData.uid)
		let targetFollowerRef	= self.followRef.queryOrderedByChild(item_followID).queryEqualToValue(self.firebaseRef.authData.uid)
		
		// フォロー追加の監視
		self.observeHandles.append((targetFollowRef,
		targetFollowRef.observeEventType(.ChildAdded, withBlock: { data in
			if let isNotified = data.value[self.item_notifiedUser] as? Bool {
				if isNotified == false {
					let updateRef = self.followRef.childByAppendingPath(data.key)
					let dic: [String: AnyObject] = [self.item_notifiedUser: true]
					updateRef.updateChildValues(dic)
					
					if let uid = data.value[self.item_followID] as? String,
						let timestamp = data.value[self.item_timestamp] as? NSTimeInterval {
						let userInfo: [String: AnyObject] = [self.notifyInfo_uid: uid, self.notifyInfo_timestamp: self.convertToNSDate(timestamp)]
						NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.AddedFollow, object: self, userInfo: userInfo)
					}
				}
			}
			
		})))
		
		// フォロー削除の監視
		self.observeHandles.append((targetFollowRef,
		targetFollowRef.observeEventType(.ChildRemoved, withBlock: { data in
			if let uid = data.value[self.item_followID] as? String,
				let timestamp = data.value[self.item_timestamp] as? NSTimeInterval {
				let userInfo: [String: AnyObject] = [self.notifyInfo_uid: uid, self.notifyInfo_timestamp: self.convertToNSDate(timestamp)]
				NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.RemovedFollow, object: self, userInfo: userInfo)
			}
		})))
		
		// フォロワー追加の監視
		self.observeHandles.append((targetFollowerRef,
		targetFollowerRef.observeEventType(.ChildAdded, withBlock: { data in
			if let isNotified = data.value[self.item_notifiedFollower] as? Bool {
				if isNotified == false {
					let updateRef = self.followRef.childByAppendingPath(data.key)
					let dic: [String: AnyObject] = [self.item_notifiedFollower: true]
					updateRef.updateChildValues(dic)
					
					if let uid = data.value[self.item_uid] as? String,
						let timestamp = data.value[self.item_timestamp] as? NSTimeInterval {
						let userInfo: [String: AnyObject] = [self.notifyInfo_uid: uid, self.notifyInfo_timestamp: self.convertToNSDate(timestamp)]
						NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.AddedFollower, object: self, userInfo: userInfo)
					}
				}
			}
		})))
		
		// フォロワー削除の監視
		self.observeHandles.append((targetFollowerRef,
		targetFollowerRef.observeEventType(.ChildRemoved, withBlock: { data in
			if let uid = data.value[self.item_uid] as? String,
				let timestamp = data.value[self.item_timestamp] as? NSTimeInterval {
				let userInfo: [String: AnyObject] = [self.notifyInfo_uid: uid, self.notifyInfo_timestamp: self.convertToNSDate(timestamp)]
				NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.RemovedFollower, object: self, userInfo: userInfo)
			}
		})))
		
		
		// Blockノードの監視対象
		let targetBlockRef		= self.blockRef.queryOrderedByChild(item_uid).queryEqualToValue(self.firebaseRef.authData.uid)
		let targetBlockerRef	= self.blockRef.queryOrderedByChild(item_blockID).queryEqualToValue(self.firebaseRef.authData.uid)
		
		// ブロック追加の監視
		self.observeHandles.append((targetBlockRef,
		targetBlockRef.observeEventType(.ChildAdded, withBlock: { data in
			if let isNotified = data.value[self.item_notifiedUser] as? Bool {
				if isNotified == false {
					let updateRef = self.blockRef.childByAppendingPath(data.key)
					let dic: [String: AnyObject] = [self.item_notifiedUser: true]
					updateRef.updateChildValues(dic)
					
					if let uid = data.value[self.item_blockID] as? String,
						let timestamp = data.value[self.item_timestamp] as? NSTimeInterval {
						
						let userInfo: [String: AnyObject] = [self.notifyInfo_uid: uid, self.notifyInfo_timestamp: self.convertToNSDate(timestamp)]
						NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.AddedBlock, object: self, userInfo: userInfo)
					}
				}
			}
		})))
		
		// ブロック削除の監視
		self.observeHandles.append((targetBlockRef,
		targetBlockRef.observeEventType(.ChildRemoved, withBlock: { data in
			if let uid = data.value[self.item_blockID] as? String,
				let timestamp = data.value[self.item_timestamp] as? NSTimeInterval {
				
				let userInfo: [String: AnyObject] = [self.notifyInfo_uid: uid, self.notifyInfo_timestamp: self.convertToNSDate(timestamp)]
				NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.RemovedBlock, object: self, userInfo: userInfo)
			}
		})))
		
		// 被ブロック追加の監視
		self.observeHandles.append((targetBlockerRef,
		targetBlockerRef.observeEventType(.ChildAdded, withBlock: { data in
			if let isNotified = data.value[self.item_notifiedBlockUser] as? Bool {
				if isNotified == false {
					let updateRef = self.blockRef.childByAppendingPath(data.key)
					let dic: [String: AnyObject] = [self.item_notifiedBlockUser: true]
					updateRef.updateChildValues(dic)
					
					if let uid = data.value[self.item_uid] as? String,
						let timestamp = data.value[self.item_timestamp] as? NSTimeInterval {
						
						let userInfo: [String: AnyObject] = [self.notifyInfo_uid: uid, self.notifyInfo_timestamp: self.convertToNSDate(timestamp)]
						NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.BlockedFromSomeone, object: self, userInfo: userInfo)
					}
				}
			}
		})))
		
		// 被ブロック削除の監視
		self.observeHandles.append((targetBlockerRef,
		targetBlockerRef.observeEventType(.ChildRemoved, withBlock: { data in
			if let uid = data.value[self.item_uid] as? String,
				let timestamp = data.value[self.item_timestamp] as? NSTimeInterval {
				
				let userInfo: [String: AnyObject] = [self.notifyInfo_uid: uid, self.notifyInfo_timestamp: self.convertToNSDate(timestamp)]
				NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.RemoveBlockFromSomeone, object: self, userInfo: userInfo)
			}
		})))
	}
	
	/**
	Firebase.TimeStampをNSDateに変換する
	
	- parameter timestamp: タイムスタンプ
	
	- returns: NSDateインスタンス
	*/
	private func convertToNSDate(timestamp: NSTimeInterval) -> NSDate {
		return NSDate(timeIntervalSince1970: timestamp / 1000)
	}
	
	/**
	NSErrorインスタンスを得る
	
	- parameter code:    エラーコード
	- parameter message: エラーメッセージ
	
	- returns: NSErrorインスタンス
	*/
	private func error(code: errorCode, message: String) -> NSError {
		let userInfo: [String: AnyObject] = [NSLocalizedDescriptionKey: message]
		return NSError(domain: IF_FirebaseFollowHelper.errorDomain, code: code.rawValue, userInfo: userInfo)
	}
	
	/**
	デバッグログの出力
	
	- parameter message: メッセージ
	*/
	private func debugLog(message: String) {
		if IF_FirebaseFollowHelper.outputDebug == true {
			print("IF_FirebaseFollowHelper debug: \(message)")
		}
	}
	
	/**
	ログインユーザがフォローしているユーザ一覧を取得します
	
	- parameter completion: 取得完了時に実行するClosure
	
	Closureでは取得したユーザのuidと登録日時の一覧を使用できます。  
	*/
	public func getFollowList(completion: (([IF_FirebaseFollowHelperBasicUserInfo]) -> Void)?) {
		self.followRef.queryOrderedByChild(item_uid).queryEqualToValue(self.firebaseRef.authData.uid).observeSingleEventOfType(.Value, withBlock: { data in
			// Array形式に変換する
			var followList = [IF_FirebaseFollowHelperBasicUserInfo]()
			data.children.forEach() {
				let user = $0 as! FDataSnapshot
				if let followID = user.value[self.item_followID] as? String,
				   let timestamp = user.value[self.item_timestamp] as? NSTimeInterval {
					
					followList.append((followID, self.convertToNSDate(timestamp)))
				}
			}
			
			// 最新順に並び替える
			followList = followList.sort() { $0.1.timeIntervalSince1970 > $1.1.timeIntervalSince1970 }
			
			completion?(followList)
		})
	}
	
	/**
	ログインユーザをフォローしているユーザ一覧を取得します
	
	- parameter completion: 取得完了時に実行するClosure
	
	Closureでは取得したユーザのuidと登録日時の一覧を使用できます。
	*/
	public func getFollowerList(completion: (([IF_FirebaseFollowHelperBasicUserInfo]) -> Void)?) {
		self.followRef.queryOrderedByChild(item_followID).queryEqualToValue(self.firebaseRef.authData.uid).observeSingleEventOfType(.Value, withBlock: { data in
			// Array形式に変換する
			var followerList = [IF_FirebaseFollowHelperBasicUserInfo]()
			data.children.forEach() {
				let user = $0 as! FDataSnapshot
				if let followerID = user.value[self.item_uid] as? String,
				   let timestamp = user.value[self.item_timestamp] as? NSTimeInterval {
					
					followerList.append((followerID, self.convertToNSDate(timestamp)))
				}
			}
			
			completion?(followerList)
		})
	}
	
	/**
	ログインユーザがブロックしているユーザ一覧を取得します
	
	- parameter completion: 取得完了時に実行するClosure
	
	Closureでは取得したユーザのuidと登録日時の一覧を使用できます。
	*/
	public func getBlockList(completion: (([IF_FirebaseFollowHelperBasicUserInfo]) -> Void)?) {
		self.blockRef.queryOrderedByChild(item_uid).queryEqualToValue(self.firebaseRef.authData.uid).observeSingleEventOfType(.Value, withBlock: { data in
			// Array形式に変換する
			var blockList = [(uid: String, timestamp: NSDate)]()
			data.children.forEach() {
				let user = $0 as! FDataSnapshot
				if let blockID = user.value[self.item_blockID] as? String,
				   let timestamp = user.value[self.item_timestamp] as? NSTimeInterval {
					
					blockList.append((blockID, self.convertToNSDate(timestamp)))
				}
			}
			
			// 最新順に並び替える
			blockList = blockList.sort() { $0.1.timeIntervalSince1970 > $1.1.timeIntervalSince1970 }
			
			completion?(blockList)
		})
	}
	
	/**
	ログインユーザをブロックしているユーザ一覧を取得します
	
	- parameter completion: 取得完了時に実行するClosure
	
	Closureでは取得したユーザのuidと登録日時の一覧を使用できます。
	*/
	public func getBlockerList(completion: (([IF_FirebaseFollowHelperBasicUserInfo]) -> Void)?) {
		self.blockRef.queryOrderedByChild(item_blockID).queryEqualToValue(self.firebaseRef.authData.uid).observeSingleEventOfType(.Value, withBlock: { data in
			// Array形式に変換する
			var blockerList = [(uid: String, timestamp: NSDate)]()
			data.children.forEach() {
				let user = $0 as! FDataSnapshot
				if let blockerID = user.value[self.item_uid] as? String,
				   let timestamp = user.value[self.item_timestamp] as? NSTimeInterval {
					
					blockerList.append((blockerID, self.convertToNSDate(timestamp)))
				}
			}
			
			completion?(blockerList)
		})
	}
	
	/**
	対象ユーザをフォローします
	
	- parameter userID: 対象ユーザのuid
	
	フォローに成功した場合、*IF_FirebaseFollowHelperMessage.AddedFollow*が通知されます。  
	フォローに失敗した場合、*IF_FirebaseFollowHelperMessage.FailedFollow*が通知されます。  
	すでにフォロー済みかフォローに失敗した場合、何も通知されません。  
	処理完了時に、*IF_FirebaseFollowHelperMessage.DidAddFollowProc*が通知されます。
	*/
	public func follow(userID: String) {
		self.follow([userID])
	}
	
	/**
	対象ユーザ（複数）をフォローします
	
	- parameter userIDs: 対象ユーザのuid一覧
	
	フォローに成功した場合、*IF_FirebaseFollowHelperMessage.AddedFollow*が通知されます。  
	フォローに失敗した場合、*IF_FirebaseFollowHelperMessage.FailedFollow*が通知されます。  
	すでにフォロー済みかフォローに失敗した場合、何も通知されません。  
	処理完了時に、*IF_FirebaseFollowHelperMessage.DidAddFollowProc*が通知されます。
	*/
	public func follow(userIDs: [String]) {
		self.getFollowList() { followList in
			let addList = userIDs.filter() { !followList.map() { $0.0 }.contains($0) }
			let timestamp = NSDate()	// 処理失敗時にメッセージに載せる
			var procCount = 0
			addList.forEach() {
				let userRef = self.followRef.childByAutoId()
				let followID = $0
				let dic: [String: AnyObject] = [self.item_uid: self.firebaseRef.authData.uid, self.item_followID: followID, self.item_notifiedUser: false, self.item_notifiedFollower: false, self.item_timestamp: FirebaseServerValue.timestamp()]
				userRef.updateChildValues(dic, withCompletionBlock: { error, firebaseRef in
					if error != nil {
						self.debugLog("follow failed [\(followID)]")
						let userInfo: [String: AnyObject] = [self.notifyInfo_uid: followID, self.notifyInfo_error: error, self.notifyInfo_timestamp: timestamp]
						NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.FailedFollow, object: self, userInfo: userInfo)
					}
					else {
						self.debugLog("following [\(followID)]")
					}
					
					procCount += 1
					if procCount >= addList.count {
						NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.DidAddFollowProc, object: self, userInfo: nil)
					}
				})
			}
			
			if addList.count == 0 {
				NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.DidAddFollowProc, object: self, userInfo: nil)
			}
		}
	}
	
	/**
	対象ユーザのフォローを解除します	
	
	- parameter userID: 対象ユーザのuid
	
	フォロー解除に成功した場合、*IF_FirebaseFollowHelperMessage.RemovedFollow*が通知されます。 
	フォロー解除に失敗した場合、*IF_FirebaseFollowHelperMessage.FailedRemoveFollow*が通知されます。  
	フォローしていないユーザをフォロー解除した場合かフォロー解除に失敗した場合、何も通知されません。  
	処理完了時に*IF_FirebaseFollowHelperMessage.DidRemoveFollowProc*が通知されます。
	*/
	public func unFollow(userID: String) {
		self.unFollow([userID])
	}
	
	/**
	対象ユーザ（複数）のフォローを解除します
	
	- parameter userIDs: 対象ユーザのuid一覧
	
	フォロー解除に成功した場合、*IF_FirebaseFollowHelperMessage.RemovedFollow*が通知されます。  
	フォロー解除に失敗した場合、*IF_FirebaseFollowHelperMessage.FailedRemoveFollow*が通知されます。  
	フォローしていないユーザをフォロー解除した場合かフォロー解除に失敗した場合、何も通知されません。  
	処理完了時に*IF_FirebaseFollowHelperMessage.DidRemoveFollowProc*が通知されます。
	*/
	public func unFollow(userIDs: [String]) {
		self.followRef.queryOrderedByChild(item_uid).queryEqualToValue(self.firebaseRef.authData.uid).observeSingleEventOfType(.Value, withBlock: { data in
			var removeList = [FDataSnapshot]()
			data.children.forEach() {
				let user = $0 as! FDataSnapshot
				if let followID = user.value[self.item_followID] as? String {
					if userIDs.contains(followID) {
						removeList.append(user)
					}
				}
			}
			
			let timestamp = NSDate()	// 処理失敗時にメッセージに載せる
			var procCount = 0
			removeList.forEach() {
				if let followID = $0.value[self.item_followID] as? String {
					let removeRef = self.followRef.childByAppendingPath($0.key)
					removeRef.removeValueWithCompletionBlock({ error, firebaseRef in
						if error != nil {
							self.debugLog("remove follow failed [\(followID)]")
							let userInfo: [String: AnyObject] = [self.notifyInfo_uid: followID, self.notifyInfo_error: error, self.notifyInfo_timestamp: timestamp]
							NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.FailedRemoveFollow, object: self, userInfo: userInfo)
						}
						else {
							self.debugLog("remove follow [\(followID)]")
						}
						
						procCount += 1
						if procCount >= removeList.count {
							NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.DidRemoveFollowProc, object: self, userInfo: nil)
						}
					})
				}
			}
			
			if removeList.count == 0 {
				NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.DidRemoveFollowProc, object: self, userInfo: nil)
			}
		})
	}
	
	/**
	対象ユーザをブロックします
	
	- parameter userID: 対象ユーザのuid
	
	ブロックに成功した場合、*IF_FirebaseFollowHelperMessage.AddedBlock*が通知されます。  
	ブロックに失敗した場合、*IF_FirebaseFollowHelperMessage.FailedBlock*が通知されます。  
	すでにブロック済みのuidを指定した場合、何も通知されません。  
	処理完了時に、*DIF_FirebaseFollowHelperMessage.idAddBlockProc*が通知されます。
	*/
	public func block(userID: String) {
		self.block([userID])
	}
	
	/**
	対象ユーザ（複数）をブロックします
	
	- parameter userIDs: 対象ユーザのuid一覧
	
	ブロックに成功した場合、*IF_FirebaseFollowHelperMessage.AddedBlock*が通知されます。  
	ブロックに失敗した場合、*IF_FirebaseFollowHelperMessage.FailedBlock*が通知されます。  
	すでにブロック済みのuidを指定した場合、何も通知されません。  
	処理完了時に、*DIF_FirebaseFollowHelperMessage.DidAddBlockProc*が通知されます。
	*/
	public func block(userIDs: [String]) {
		self.getBlockList() { blockList in
			let addList = userIDs.filter() { !blockList.map() { $0.0 }.contains($0) }
			let timestamp = NSDate()	// 処理失敗時にメッセージに載せる
			var procCount = 0
			addList.forEach() {
				let userRef = self.blockRef.childByAutoId()
				let blockID = $0
				let dic: [String: AnyObject] = [self.item_uid: self.firebaseRef.authData.uid, self.item_blockID: blockID, self.item_notifiedUser: false, self.item_notifiedBlockUser:false, self.item_timestamp: FirebaseServerValue.timestamp()]
				userRef.updateChildValues(dic, withCompletionBlock: { error, firebaseRef in
					if error != nil {
						self.debugLog("blocking failed [\(blockID)]")
						let userInfo: [String: AnyObject] = [self.notifyInfo_uid: blockID, self.notifyInfo_error: error, self.notifyInfo_timestamp: timestamp]
						NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.FailedBlock, object: self, userInfo: userInfo)
					}
					else {
						self.debugLog("blocking [\(blockID)]")
					}
					
					procCount += 1
					if procCount >= addList.count {
						NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.DidAddBlockProc, object: self, userInfo: nil)
					}
				})
			}
			
			if addList.count == 0 {
				NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.DidAddBlockProc, object: self, userInfo: nil)
			}
		}
	}
	
	
	/**
	対象ユーザのブロックを解除します
	
	- parameter userID: 対象ユーザのuid一覧
	
	ブロックの解除に成功した場合、*IF_FirebaseFollowHelperMessage.RemovedBlock*が通知されます。  
	ブロックの解除に失敗した場合、*IF_FirebaseFollowHelperMessage.FailedRemoveBlock*が通知されます。   
	ブロックしていないユーザをブロック解除した場合、何も通知されません。  
	処理完了時に、*IF_FirebaseFollowHelperMessage.DidRemoveBlockProc*が通知されます。
	*/
	public func unBlock(userID: String) {
		self.unBlock([userID])
	}
	
	/**
	対象ユーザ（複数）のブロックを解除します
	
	- parameter userIDs: 対象ユーザのuid一覧
	
	ブロックの解除に成功した場合、*IF_FirebaseFollowHelperMessage.RemovedBlock*が通知されます。  
	ブロックの解除に失敗した場合、*IF_FirebaseFollowHelperMessage.FailedRemoveBlock*が通知されます。   
	ブロックしていないユーザをブロック解除した場合、何も通知されません。  
	処理完了時に、*IF_FirebaseFollowHelperMessage.DidRemoveBlockProc*が通知されます。
	*/
	public func unBlock(userIDs: [String]) {
		self.blockRef.queryOrderedByChild(item_uid).queryEqualToValue(self.firebaseRef.authData.uid).observeSingleEventOfType(.Value, withBlock: { data in
			var removeList = [FDataSnapshot]()
			data.children.forEach() {
				let user = $0 as! FDataSnapshot
				if let blockID = user.value[self.item_blockID] as? String {
					if userIDs.contains(blockID) {
						removeList.append(user)
					}
				}
			}
			
			let timestamp = NSDate()	// 処理失敗時にメッセージに載せる
			var procCount = 0
			removeList.forEach() {
				if let blockID = $0.value[self.item_blockID] as? String {
					let removeRef = self.blockRef.childByAppendingPath($0.key)
					removeRef.removeValueWithCompletionBlock() { error, firebaseRef in
						if error != nil {
							self.debugLog("remove block failed [\(blockID)]")
							let userInfo: [String: AnyObject] = [self.notifyInfo_uid: blockID, self.notifyInfo_error: error, self.notifyInfo_timestamp: timestamp]
							NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.FailedRemoveBlock, object: self, userInfo: userInfo)
						}
						else {
							self.debugLog("remove block [\(blockID)]")
						}
						
						procCount += 1
						if procCount >= removeList.count {
							NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.DidRemoveBlockProc, object: self, userInfo: nil)
						}
					}
				}
			}
			
			if removeList.count == 0 {
				NSNotificationCenter.defaultCenter().postNotificationName(IF_FirebaseFollowHelperMessage.DidRemoveBlockProc, object: self, userInfo: nil)
			}
		})
	}
}
