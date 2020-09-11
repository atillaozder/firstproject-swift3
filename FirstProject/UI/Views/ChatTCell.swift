//
//  ChatTCell.swift
//  FirstProject
//
//  Created by FirstProject on 18.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

class ChatTCell: UITableViewCell {
    
    let bubbleImgView: UIImageView = {
        let imgView = UIImageView()
        return imgView
    }()
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.text = ""
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.backgroundColor = .clear
        return textView
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(bubbleView)
        addSubview(messageTextView)
        
        bubbleView.addSubview(bubbleImgView)
        bubbleView.addConstraintsWithFormat("H:|[v0]|", views: bubbleImgView)
        bubbleView.addConstraintsWithFormat("V:|[v0]|", views: bubbleImgView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let grayBubbleImg = #imageLiteral(resourceName: "BubbleReceiver").resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
    static let blueBubbleImg = #imageLiteral(resourceName: "BubbleSender").resizableImage(withCapInsets: UIEdgeInsetsMake(22, 26, 22, 26)).withRenderingMode(.alwaysTemplate)
    
}
