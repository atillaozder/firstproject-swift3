//
//  ChatVC.swift
//  FirstProject
//
//  Created by FirstProject on 18.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import SlackTextViewController

final class ChatVC: SLKTextViewController, AlertHandling {
    
    // MARK: - Properties
    
    fileprivate var messages = [Message]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override var tableView: UITableView {
        get {
            return super.tableView!
        }
    }
    
    fileprivate var cameraBtn: UIButton!
    fileprivate var callBtn: UIBarButtonItem!
    
    let defaultColor: UIColor = UIColor(red: 0, green: 122/255 , blue: 1.0, alpha:1.0)
    var trailingConstraint: NSLayoutConstraint?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTestData()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.contentInset = UIEdgeInsets.zero
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helpers
    
    private func setupViews() {
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .none
        self.tableView.register(ChatTCell.self, forCellReuseIdentifier: "MessageCell")
        
        shouldScrollToBottomAfterKeyboardShows = true
        setupButtons()
        
        textInputbar.layer.borderColor = UIColor.darkGray.cgColor
        textInputbar.layer.borderWidth = 0.1
        
        textInputbar.autoHideRightButton = false
        textInputbar.maxCharCount = 256
        textInputbar.counterStyle = .none
        textInputbar.counterPosition = .top
        
        textInputbar.editorTitle.textColor = UIColor.black
        textInputbar.editorLeftButton.tintColor = defaultColor
        textInputbar.editorRightButton.tintColor = defaultColor
        
        textInputbar.isTranslucent = false
        textInputbar.barTintColor = CustomColors.bar.value
        
        textView.placeholder = ""
        textView.layer.cornerRadius = textView.intrinsicContentSize.height / 2
        textView.clipsToBounds = true
    }
    
    private func setupButtons() {
        cameraBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        cameraBtn.addTarget(self, action: #selector(cameraBtnTapped), for: .touchUpInside)
        cameraBtn.setImage(#imageLiteral(resourceName: "CameraBar").withRenderingMode(.alwaysTemplate), for: .normal)
        cameraBtn.tintColor = defaultColor
        
        leftButton.setImage(#imageLiteral(resourceName: "PlusBar"), for: .normal)
        leftButton.tintColor = defaultColor
        
        rightButton.setImage(#imageLiteral(resourceName: "Send").withRenderingMode(.alwaysTemplate), for: .normal)
        rightButton.setTitle(nil, for: .normal)
        
        rightButton.tintColor = .white
        rightButton.backgroundColor = defaultColor
        
        rightButton.layer.cornerRadius = rightButton.intrinsicContentSize.width / 2
        rightButton.clipsToBounds = true
        
        callBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "CallBar").withRenderingMode(.alwaysTemplate),
                                  style: .plain,
                                  target: self,
                                  action: #selector(callBtnTapped))
        
        callBtn.tintColor = defaultColor
        self.navigationItem.rightBarButtonItem = callBtn
        
        self.textInputbar.addSubview(cameraBtn)
        setupLayouts()
    }
    
    private func setupLayouts() {
        self.textInputbar.contentInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 8.0)
        
        cameraBtn.translatesAutoresizingMaskIntoConstraints = false
        cameraBtn.centerYAnchor.constraint(equalTo: textInputbar.centerYAnchor).isActive = true
        cameraBtn.trailingAnchor.constraint(equalTo: textInputbar.trailingAnchor, constant: -41).isActive = true
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        trailingConstraint = textView.trailingAnchor.constraint(equalTo: cameraBtn.trailingAnchor, constant: -33)
        trailingConstraint?.isActive = true
    }
    
    // MARK: - Actions
    
    func cameraBtnTapped(_ sender: UIButton) {
        print("cameraBtn Tapped")
    }
    
    func callBtnTapped(_ sender: UIBarButtonItem) {
        print("callBtn Tapped")
    }
    
    override func didPressLeftButton(_ sender: Any!) {
        let openCamera = UIAlertAction(title: "Kamera", style: .default) { (action) in
            let cameraStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            
            switch cameraStatus {
            case .authorized:
                break
            case .denied:
                break
            case .notDetermined:
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
                    if granted {
                        
                    } else {
                        
                    }
                }
            default:
                break
            }
            
            
        }
        
        let openLibrary = UIAlertAction(title: "Fotoğraf ve Video Galerisi", style: .default) { (action) in
            let photoStatus = PHPhotoLibrary.authorizationStatus()
            
            switch photoStatus {
            case .authorized:
                break
            case .denied:
                break
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == .authorized {
                        
                    } else {
                        
                    }
                })
            default: break
            }
        }
        
        super.didPressLeftButton(sender)
        self.dismissKeyboard(true)
        self.showActionSheet(withActions: [openCamera, openLibrary])
    }
    
    override func didPressRightButton(_ sender: Any!) {
        self.textView.refreshFirstResponder()
        
        UIView.animate(withDuration: 0.1) { 
            self.trailingConstraint?.isActive = true
            self.cameraBtn.alpha = 1.0
        }
        
        let message = Message(text: self.textView.text, isSender: true)
        
        let indexPath = IndexPath(row: 0, section: 0)
        let rowAnimation: UITableViewRowAnimation = self.isInverted ? .bottom : .top
        let scrollPosition: UITableViewScrollPosition = self.isInverted ? .bottom : .top
        
        self.tableView.beginUpdates()
        self.messages.insert(message, at: 0)
        self.tableView.insertRows(at: [indexPath], with: rowAnimation)
        self.tableView.endUpdates()
        
        self.tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: true)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        super.didPressRightButton(sender)
    }
    
    override func didPasteMediaContent(_ userInfo: [AnyHashable: Any]) {
        super.didPasteMediaContent(userInfo)
        
        let mediaType = (userInfo[SLKTextViewPastedItemMediaType] as? NSNumber)?.intValue
        let contentType = userInfo[SLKTextViewPastedItemContentType]
        let data = userInfo[SLKTextViewPastedItemData]
        
        print("didPasteMediaContent : \(contentType) (type = \(mediaType) | data : \(data))")
    }
    
    // MARK: - Observers
    
    override func didChangeKeyboardStatus(_ status: SLKKeyboardStatus) {
        switch status {
        case .willShow:
            print("Keyboard Will Show")
        case .didShow:
            print("Keyboard Did Show")
        case .willHide:
            print("Keyboard Will Hide")
        case .didHide:
            print("Keyboard Did Hide")
        }
    }
}

// MARK: - Table View Delegate & Data Source

extension ChatVC {
    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        return .plain
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.messages.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.1) {
                cell.transform = self.tableView.transform.scaledBy(x: 1.0, y: 1.0)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId: String = "MessageCell"
        let cell: ChatTCell = self.tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatTCell
        
        cell.transform = self.tableView.transform
        cell.messageTextView.text = messages[indexPath.row].text
        
        if let messageText = messages[indexPath.row].text {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size,
                                                                            options: options,
                                                                            attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)],
                                                                            context: nil)
            
            let mWidth: CGFloat = estimatedFrame.width + 16
            let mHeight: CGFloat = estimatedFrame.height + 20
            let bWidth: CGFloat = estimatedFrame.width + 16 + 8 + 16
            let bHeight: CGFloat = estimatedFrame.height + 20 + 6
            
            if messages[indexPath.row].isSender == nil || !(messages[indexPath.row].isSender!) {
                
                let mX: CGFloat = 10 + 8 + 8
                cell.messageTextView.frame = CGRect(x: mX, y: 0, width: mWidth, height: mHeight)
                cell.bubbleView.frame = CGRect(x: 10, y: -4, width: bWidth, height: bHeight)
                
                cell.bubbleImgView.image = ChatTCell.grayBubbleImg
                cell.bubbleImgView.tintColor = UIColor(white: 0.95, alpha: 1)
                cell.messageTextView.textColor = UIColor.black
                
            } else {
                
                let mX: CGFloat = view.frame.width - estimatedFrame.width - 16 - 16 - 8
                cell.messageTextView.frame = CGRect(x: mX, y: 0, width: mWidth, height: mHeight)
                
                let bX: CGFloat = view.frame.width - estimatedFrame.width - 16 - 8 - 16 - 10
                cell.bubbleView.frame = CGRect(x: bX, y: -4, width: bWidth, height: bHeight)
                
                cell.bubbleImgView.image = ChatTCell.blueBubbleImg
                cell.bubbleImgView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                cell.messageTextView.textColor = UIColor.white
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let messageText = messages[indexPath.row].text {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size,
                                                                            options: options,
                                                                            attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18)],
                                                                            context: nil)
            
            return (estimatedFrame.height + 20 + 10)
        }
        
        return 100
    }
}

// MARK: - Helpers

extension ChatVC {
    
    override func canShowTypingIndicator() -> Bool {
        return super.canShowTypingIndicator()
    }
    
    override func ignoreTextInputbarAdjustment() -> Bool {
        return super.ignoreTextInputbarAdjustment()
    }
    
    override func forceTextInputbarAdjustment(for responder: UIResponder!) -> Bool {
        guard let _ = responder as? UIAlertController else {
            return UIDevice.current.userInterfaceIdiom == .pad
        }
        return true
    }
}

// MARK: - Text View Delegate

extension ChatVC {
    override func textWillUpdate() {
        super.textWillUpdate()
        if !(rightButton.isEnabled) {
            UIView.animate(withDuration: 0.1) {
                self.trailingConstraint?.isActive = false
                self.cameraBtn.alpha = 0.0
            }
        }
    }
    
    override func textDidUpdate(_ animated: Bool) {
        super.textDidUpdate(animated)
    }
}

extension ChatVC {
    func setupTestData() {
        var msgArray = [Message]()
        let msg1 = Message(text: "Good morning..", isSender: true)
        let msg2 = Message(text: "Hello, how are you? Hope you are having a good morning!", isSender: false)
        let msg3 = Message(text: "Are you interested in buying an Apple device? We have a wide variety of Apple devices that will suit your needs.  Please make your purchase with us.", isSender: true)
        let msg4 = Message(text: "Yes, totally looking to buy an iPhone 7.", isSender: false)
        let msg5 = Message(text: "Totally understand that you want the new iPhone 7, but you'll have to wait until September for the new release. Sorry but thats just how Apple likes to do things.", isSender: true)
        let msg6 = Message(text: "Absolutely, I'll just use my gigantic iPhone 6 Plus until then!!!", isSender: false)
        let msg7 = Message(text: "Love, Peace, and Joy", isSender: true)
        let msg8 = Message(text: "You're fired", isSender: false)
        
        msgArray.append(contentsOf: [msg1, msg2, msg3, msg4, msg5, msg6, msg7, msg8])
        msgArray = msgArray.sorted(by: {$0.date!.compare($1.date! as Date) == .orderedAscending})
        
        let reversed = msgArray.reversed()
        self.messages.append(contentsOf: reversed)
    }
}
