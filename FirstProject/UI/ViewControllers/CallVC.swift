//
//  CallVC.swift
//  FirstProject
//
//  Created by AtillaOzder on 21.03.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit
import AVFoundation

final class RemainingView: UIView, Roundable, Gradientable {}
final class CallButton: UIButton, Roundable, Gradientable, Shadowable, Rotatable {}

final class CallVC: UIViewController, HideableBars {
    
    // MARK: - Properties
    @IBOutlet weak var remainingView: RemainingView!
    @IBOutlet weak var remainingImgView: UIImageView!
    @IBOutlet weak var remainingCallLbl: UILabel!
    @IBOutlet weak var callBtn: CallButton!

    let ripple = RippleEffect()
    let pulse = RippleEffect()
    
    var player: AVAudioPlayer?
    var btnIsSelected: Bool = false
    
    override var prefersStatusBarHidden: Bool {
        return AppDelegate.isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    weak var personDelegate: PersonDelegate?
    fileprivate var currentPerson: Person?
    var personHolder: Person {
        get { return self.currentPerson! }
        set { currentPerson = newValue }
    }

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupAnimations()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleBackground),
                                               name: .UIApplicationDidEnterBackground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleBackground),
                                               name: .UIApplicationWillResignActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        remainingView.alpha = 1.0
        callBtn.scale(angle: 0, canRepeat: false)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pulse.position = callBtn.layer.position
        ripple.position = callBtn.layer.position
        callBtn.getGradientLayer().frame = callBtn.bounds
        view.layoutIfNeeded()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueIdentifier = "toMicPopOverVC"
        if segue.identifier == segueIdentifier {
            if let popOverVC = segue.destination as? MicPopOverVC {
                popOverVC.modalPresentationCapturesStatusBarAppearance = true
            }
        }
    }
    
    // MARK: - Observers
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleBackground() {
        if (btnIsSelected) {
            setAnimations()
        }
    }
    
    func willEnterForeground() {
        callBtn.scale(angle: 0, canRepeat: false)
    }
    
    // MARK: - View Methods
    
    fileprivate func setupViews() {
        AppDelegate.isStatusBarHidden = false
        
        callBtn.setRounded()
        callBtn.addShadow()
        callBtn.setGradientLayer(angleInDegs: 90, colors: CustomColors.call.gradientValue, hasBorder: false)
         
        remainingView.setCornersRounded()
        remainingView.setGradientLayer(angleInDegs: 270, colors: CustomColors.call.gradientValue, hasBorder: true)
        remainingCallLbl.text = String(describing: personHolder.callCount)
    }
    
    fileprivate func setupAnimations() {
        view.layer.insertSublayer(ripple, below: callBtn.layer)
        view.layer.insertSublayer(pulse, below: callBtn.layer)
        
        pulse.radius = view.bounds.size.width / 2
        pulse.opacityValues = [0.6, 0.3, 0.0]
        pulse.animationKey = "Pulse"
        pulse.animationDuration = 3.0
        pulse.interval = 3.0
        pulse.numberOfLayers = 3
        pulse.initialLayerScale = 0.4
        
        ripple.radius = view.bounds.size.width
        ripple.opacityValues = [1.0, 0.5, 0.0]
        ripple.animationKey = "Ripple"
        ripple.interval = 1.8
        ripple.numberOfLayers = 3
        ripple.initialLayerScale = 0.5
        
        ripple.setColorAndBorder(color: UIColor.clear.cgColor, borderColor: UIColor.darkGray.cgColor, borderWidth: 4)
        pulse.setColorAndBorder(color: CustomColors.flatRed.value.cgColor)
    }
    
    // MARK: - Helpers

    fileprivate func setAnimations() {
        if !(btnIsSelected) {
            showHealthBar(withOption: .curveEaseOut, alpha: 0.0)
            animateBars()
            ripple.start()
            pulse.start()
            
            playCallSound()
            
            callBtn.rotate(toDegrees: 136)
            setBtnSelection()
            
        } else {
            showHealthBar(withOption: .curveEaseIn, alpha: 1.0)
            animateBars()
            ripple.stop()
            pulse.stop()
            
            if player != nil {
                player!.stop()
                player = nil
            }
            
            callBtn.rotateInitialPosition()
            setBtnSelection()
        }
    }
    
    private func setBtnSelection() {
        UIApplication.shared.isIdleTimerDisabled = !btnIsSelected
        btnIsSelected = !btnIsSelected
    }
    
    private func animateBars() {
        changeStatusBarVisibility(withDuration: 0.3)
        setTabBarHidden(animated: true)
        setNavBarHidden(animated: true)
    }
    
    private func showHealthBar(withOption option: UIViewAnimationOptions, alpha: CGFloat) {
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: option,
                       animations: {
                        self.remainingView.alpha = alpha
        })
    }
    
    private func playCallSound() {
        if UIApplication.shared.applicationState != .active {
            return
        }
        
        guard let url = Bundle.main.url(forResource: "calling", withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryMultiRoute)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            guard player != nil else { return }
            player!.numberOfLoops = -1
            player!.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func requestForMicrophonePermission(completion: @escaping (Bool) -> Void) {
        let audioShared = AVAudioSession.sharedInstance()
        
        switch audioShared.recordPermission() {
        case AVAudioSessionRecordPermission.denied:
            completion(false)
        case AVAudioSessionRecordPermission.granted:
            completion(true)
        case AVAudioSessionRecordPermission.undetermined:
            audioShared.requestRecordPermission({ (granted) in
                completion(granted)
            })
        default:
            completion(false)
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func callBtnTapped(_ sender: UIButton) {
        requestForMicrophonePermission { (response) in
            if !response {
                self.performSegue(withIdentifier: "toMicPopOverVC", sender: self)
            } else {
                self.setAnimations()
            }
        }
    }
}
