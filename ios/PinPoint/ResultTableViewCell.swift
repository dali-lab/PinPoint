//
//  SearchResultTableViewCell.swift
//  PinPoint
//
//  Created by Patrick Xu on 2/1/16.
//  Copyright © 2016 DALI. All rights reserved.
//

import UIKit
import Foundation

class ResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var resultText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}