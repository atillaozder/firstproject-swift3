//
//  PlusPopOverVC.swift
//  FirstProject
//
//  Created by FirstProject on 5.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

final class PlusView: UIView, Roundable, Gradientable {}
final class PlusImageView: UIImageView, Shadowable, Roundable {}
final class BuyButton: UIButton, Shadowable, Roundable, Gradientable {}
final class PlusCollectionView: UICollectionView, Shadowable {}
final class PlusLabel: UILabel, Mutabling {}

final class PlusPopOverVC: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var animationView: SpringView!
    @IBOutlet weak var plusImgView: PlusImageView!
    @IBOutlet weak var getPlusBtn: BuyButton!
    @IBOutlet weak var dismissBtn: BuyButton!
    @IBOutlet weak var collectionView: PlusCollectionView!
    
    @IBOutlet weak var topView: PlusView!
    @IBOutlet weak var bottomView: PlusView!
    
    @IBOutlet weak var rootStackView: UIStackView!
    @IBOutlet weak var plusLbl: PlusLabel!
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout!
    
    var lastSelection: IndexPath!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        topView.getGradientLayer().frame = topView.bounds
        getPlusBtn.getGradientLayer().frame = getPlusBtn.bounds
    }
    
    // MARK: - View Methods
    
    private func setupViews() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        animationView.layer.cornerRadius = 15.0
        animationView.clipsToBounds = true
        
        plusImgView.setRounded()
        plusImgView.setRenderingAlwaysTemplate()
        plusImgView.addShadow()
        plusImgView.tintColor = CustomColors.plusView.value
        
        plusLbl.numberOfLines = 3
        let mainStr = "Sınırsız Arama Hakkı"
        let subStr = "\nSınırsız Arama Yapmak İçin Ayrıcalıklı Özelliklerimizden Faydalan"
        
        let attr = mainStr.getAttributed(size: 25.0, font: .bold, color: .white)
        let subAttr = subStr.getAttributed(size: 15.0, font: .normal, color: .white)
        plusLbl.setMutableAttributed(fromTexts: [attr, subAttr])
        
        getPlusBtn.setCornersRounded()
        dismissBtn.setCornersRounded()
        getPlusBtn.addShadow()
        
        topView.setGradientLayer(angleInDegs: 360, colors: CustomColors.plusView.gradientValue, hasBorder: false)
        getPlusBtn.setGradientLayer(angleInDegs: 90, colors: CustomColors.buyBtn.gradientValue, hasBorder: false)
        
        collectionView.backgroundColor = UIColor(hex: "#d3d3d3")
        collectionView.allowsMultipleSelection = false
        collectionView.addShadow()
    }
    
    fileprivate func createPath(forSelectedCell cell: GetPlusCVCell) {
        if cell.isSelected {
            collectionView.layer.shadowPath = UIBezierPath(rect: CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: cell.frame.width, height: cell.frame.height)).cgPath
        }
    }
    
    // MARK: - Actions
    
    @IBAction func getPlusTapped(_ sender: UIButton) {
        // IN APP PURCHASE
    }
    
    @IBAction func dismissTapped(_ sender: UIButton) {
        animationView.y = -(animationView.frame.height + UIApplication.shared.statusBarFrame.height)
        animationView.animateTo()
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - CollectionViewDataSource

extension PlusPopOverVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GetPlusCVCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GetPlusCVCell", for: indexPath) as! GetPlusCVCell
        cell.setupLabel(forIndex: indexPath.row)
        
        if indexPath.row == 1 {
            lastSelection = indexPath
            cell.isSelected = true
            cell.setSelected()
            createPath(forSelectedCell: cell)
        }
        
        return cell
    }
}

// MARK: - CollectionViewDelegateFlowLayout

extension PlusPopOverVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - (1 * (3 - 1))) / 3  // - (spacing * (itemsInLine - 1)) / itemsInLine
        let height = collectionView.frame.height - (0.5 * (3 - 1)) // - (spacing * (itemsInLine - 1))
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.5, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

// MARK: - CollectionViewDelegate

extension PlusPopOverVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if lastSelection == indexPath {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if lastSelection.row == 1 {
            let lastCell = collectionView.cellForItem(at: lastSelection) as! GetPlusCVCell
            lastCell.isSelected = false
            lastCell.setSelected()
        }
        
        let cell = collectionView.cellForItem(at: indexPath) as! GetPlusCVCell
        cell.setSelected()
        createPath(forSelectedCell: cell)
        lastSelection = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GetPlusCVCell
        cell.setSelected()
    }
}
