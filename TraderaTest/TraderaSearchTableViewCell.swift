//
//  TraderaSearchTableViewCell.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-05-19.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import UIKit

class TraderaSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //backgroundColor=UIColor.yellowColor()
        //frame=CGRect(x: 1, y: 1, width: frame.width, height: 96)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
