//
//  ItemCellTableViewCell.swift
//  ListaCompras
//
//  Created by Vasco Gomes on 01/01/2017.
//  Copyright © 2017 Vasco Gomes. All rights reserved.
//

import UIKit

class ItemCellTableViewCell: UITableViewCell {
    
    @IBOutlet var itemTitle: UILabel!
    @IBOutlet var itemQuantityUnity: UILabel!
    @IBOutlet var itemPrice: UILabel!
    @IBOutlet var itemBrand: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(item : Item){
        
        if(item != nil)
        {
            itemTitle.text = item.title
        
            itemQuantityUnity.text = "\((item.quantity)) \((item.unity!))"
        
            itemPrice.text = "\((item.price)) €"
        
            itemBrand.text = item.brand
        }
    }

}
