//
//  FriendsTCell.swift
//  FirstProject
//
//  Created by AtillaOzder on 24.03.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

final class OnlineView: UIView, Roundable {}
final class ProfileImgView: UIImageView, Roundable {}

final class FriendsTCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var profileImgView: ProfileImgView!
    @IBOutlet weak var lastMessageLbl: UILabel!
    @IBOutlet weak var isOnlineView: OnlineView!
    @IBOutlet weak var usernameLbl: UILabel!
    
    var isOnlineBackgroundColor: UIColor!
    
    // MARK: - Table Cell Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        isOnlineBackgroundColor = isOnlineView.backgroundColor
        super.setSelected(selected, animated: animated)
        if selected {
            isOnlineView.backgroundColor = isOnlineBackgroundColor
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        isOnlineBackgroundColor = isOnlineView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            isOnlineView.backgroundColor = isOnlineBackgroundColor
        }
    }
    
    // MARK: - Helpers
    
    private func setupViews() {
        contentView.backgroundColor = .clear
        isOnlineView.setRounded()
        profileImgView.setRounded()
    }
    
    func configureCell(withFriend friend: Person) {
        usernameLbl.text = friend.username
        lastMessageLbl.text = "Son Mesaj"
        
        if friend.isOnline {
            isOnlineView.backgroundColor = CustomColors.flatGreen.value
        } else {
            isOnlineView.backgroundColor = CustomColors.flatGray.value
        }

    }
    
    func getLeftInsets() -> CGFloat {
        return profileImgView.layer.frame.size.width + stackView.layoutMargins.left + stackView.spacing
    }
}
