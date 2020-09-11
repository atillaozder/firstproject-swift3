//
//  MicPopOverVC.swift
//  FirstProject
//
//  Created by FirstProject on 31.08.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

final class SettingsButton: UIButton, Shadowable, Roundable, Gradientable {}
final class MicImgView: UIImageView, Roundable {}

final class MicPopOverVC: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var micImgView: MicImgView!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var goSettingsBtn: SettingsButton!
    @IBOutlet var animationView: SpringView!
    
    override var prefersStatusBarHidden: Bool {
        return AppDelegate.isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeStatusBarVisibility(withDuration: 0.3)
    }
    
    // MARK: - View Methods
    
    private func setupViews() {
        self.view.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        goSettingsBtn.setCornersRounded()
        goSettingsBtn.addShadow()
        micImgView.setRounded()
        micImgView.setRenderingAlwaysTemplate()
    }
    
    // MARK: - Actions
    
    @IBAction func goSettingsTapped(_ sender: UIButton) {
        guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        AppDelegate.isStatusBarHidden = false
        self.setNeedsStatusBarAppearanceUpdate()
    }
}
