//
//  UserInfoCell.swift
//  IF_FirebaseFollowHelper
//
//  Created by 久保島 祐磨 on 2016/05/10.
//  Copyright © 2016年 ICT Fractal Inc. All rights reserved.
//

import UIKit

protocol UserInfoCellDelegate {
	func userInfoCell(cell: UserInfoCell, requestFollowStateTo: Bool)
	func userInfoCell(cell: UserInfoCell, requestBlockStateTo: Bool)
}

extension UserInfoCellDelegate {
	func userInfoCell(cell: UserInfoCell, requestFollowStateTo: Bool) {}
	func userInfoCell(cell: UserInfoCell, requestBlockStateTo: Bool) {}
}

class UserInfoCell: UITableViewCell {
	
	var delegate: UserInfoCellDelegate? = nil
	private var hasFollowState: Bool = false
	private var hasBlockedState: Bool = false
	private var followState: Bool = false
	private var blockState:Bool = false

	@IBOutlet weak var userNameLabel: UILabel!
	@IBOutlet weak var hasFollowStateLabel: UILabel!
	@IBOutlet weak var hasBlockedStateLabel: UILabel!
	@IBOutlet weak var followButton: UILabel!
	@IBOutlet weak var blockButton: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        
		func setLabelDesign(view: UILabel) {
			view.layer.masksToBounds = true
			view.layer.cornerRadius = 5
		}
		
		func setButtonDesign(view: UILabel, borderColor: UIColor) {
			view.layer.masksToBounds = true
			view.layer.cornerRadius = 10
			view.layer.borderWidth = 1
			view.layer.borderColor = borderColor.CGColor
		}
		
		setButtonDesign(self.followButton, borderColor: UIColor.blueColor())
		setButtonDesign(self.blockButton, borderColor: UIColor.redColor())
		setLabelDesign(self.hasFollowStateLabel)
		setLabelDesign(self.hasBlockedStateLabel)
		
		self.followButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserInfoCell.handleFollowButton_Tap(_:))))
		self.blockButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserInfoCell.handleBlockButton_Tap(_:))))
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func setHasFollowState(state: Bool) {
		self.hasFollowState = state
		
		if state == true {
			self.hasFollowStateLabel.backgroundColor = UIColor.greenColor()
			self.hasFollowStateLabel.textColor = UIColor.blackColor()
		} else {
			self.hasFollowStateLabel.backgroundColor = UIColor.clearColor()
			self.hasFollowStateLabel.textColor = UIColor ( red: 0.498, green: 0.498, blue: 0.498, alpha: 0.3 )
		}
	}
	
	func setHasBlockedState(state: Bool) {
		self.hasBlockedState = state
		
		if state == true {
			self.hasBlockedStateLabel.backgroundColor = UIColor.redColor()
			self.hasBlockedStateLabel.textColor = UIColor.blackColor()
		} else {
			self.hasBlockedStateLabel.backgroundColor = UIColor.clearColor()
			self.hasBlockedStateLabel.textColor = UIColor ( red: 0.498, green: 0.498, blue: 0.498, alpha: 0.3 )
		}
	}
	
	func setFollowState(state: Bool) {
		self.followState = state
		
		if state == true {
			self.followButton.textColor = UIColor.whiteColor()
			self.followButton.backgroundColor = UIColor(CGColor: self.followButton.layer.borderColor!)
			self.followButton.text = "Following"
		} else {
			self.followButton.textColor = UIColor.blackColor()
			self.followButton.backgroundColor = UIColor.clearColor()
			self.followButton.text = "Follow"
		}
	}
	
	func setBlockState(state: Bool) {
		self.blockState = state
		
		if state == true {
			self.blockButton.textColor = UIColor.whiteColor()
			self.blockButton.backgroundColor = UIColor(CGColor: self.blockButton.layer.borderColor!)
			self.blockButton.text = "Blocking"
		} else {
			self.blockButton.textColor = UIColor.blackColor()
			self.blockButton.backgroundColor = UIColor.clearColor()
			self.blockButton.text = "Block"
		}
	}

	func handleFollowButton_Tap(sender: AnyObject) {
		self.delegate?.userInfoCell(self, requestFollowStateTo: !self.followState)
	}
	
	func handleBlockButton_Tap(sender: AnyObject) {
		self.delegate?.userInfoCell(self, requestBlockStateTo: !self.blockState)
	}
}
