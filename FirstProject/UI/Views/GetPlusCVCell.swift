//
//  GetPlusCVCell.swift
//  FirstProject
//
//  Created by FirstProject on 6.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

final class PriceLabel: UILabel, Mutabling {}

final class GetPlusCVCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var priceLbl: PriceLabel!
    
    // MARK: Awake From Nib
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = CustomColors.flatWhite.value
        priceLbl.numberOfLines = 3
    }
    
    // MARK: - Helpers
    
    func setupLabel(forIndex index: Int) {
        switch index {
        case 0:
            setAttributed(superStr: "1", mainStr: "\nhafta", subStr: "\n₺3.49/hafta")
        case 1:
            setAttributed(superStr: "1", mainStr: "\nay", subStr: "\n₺9.99/ay")
        case 2:
            setAttributed(superStr: "3", mainStr: "\nay", subStr: "\n₺6.66/ay")
        default:
            break
        }
    }
    
    func setSelected() {
        if isSelected {
            self.layer.borderWidth = 3.0
            self.layer.borderColor = CustomColors.buyBtn.value.cgColor
            self.backgroundColor = UIColor.white
            priceLbl.textColor = CustomColors.buyBtn.value
        } else {
            self.layer.borderWidth = 0.0
            self.layer.borderColor = UIColor.clear.cgColor
            self.backgroundColor = CustomColors.flatWhite.value
            priceLbl.textColor = UIColor.black
        }
    }
    
    private func setAttributed(superStr: String, mainStr: String, subStr: String) {
        let superAttr = superStr.getAttributed(size: 30.0, font: .bold, color: .black)
        let mainAttr = mainStr.getAttributed(size: 15.0, font: .normal, color: .black)
        let subAttr = subStr.getAttributed(size: 18.0, font: .normal, color: .black)
        
        priceLbl.setMutableAttributed(fromTexts: [superAttr, mainAttr, subAttr])
    }
}
