//
//  ListItemCell.swift
//  ListaCompras
//
//  Created by Vasco Gomes on 20/12/2016.
//  Copyright © 2016 Vasco Gomes. All rights reserved.
//

import UIKit

class ListItemCell: UITableViewCell {
    
    @IBOutlet var name: UILabel!
    @IBOutlet var numberOfItems: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    
    func configureCell(list : List){
        
        name.text = list.listName
        
        numberOfItems.text = "\((list.items?.count)!)"
        
        if(list.type == "Completed List")
        {
            //set the background to LightGray and the textColor to DarlGray if list is checked
            //the light gray that i want R:230,G:230,B:230. In here it is 230/250, 230/250, 230/250
            self.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.92,alpha: 1.0)  //very light gray
            name.textColor = UIColor.darkGray
            numberOfItems.textColor = UIColor.darkGray
        }
    }
}

