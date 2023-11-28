//
//  UserCollectionReusableView.swift
//  FetchOfflineDataInDB
//
//  Created by saurabh wattamwar on 27/11/23.
//

import UIKit

class UserCollectionReusableView: UICollectionReusableView {

    var delegate : ViewController?
    
    
    @IBAction func clickedSwitch(_ sender: UISwitch) {
        delegate?.switchBtnClicked(isSwitchOn: sender.isOn)
    
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
}
