//
//  CustomTextField.swift
//  ListaCompras
//
//  Created by Vasco Gomes on 28/12/2016.
//  Copyright © 2016 Vasco Gomes. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    //textFont is always Helvetica Neue
    var textFont = UIFont(name: "Helvetica Neue", size: 14.0)

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        //round the edges of the text field
        self.layer.cornerRadius = 3.0
        
        //set backgroundColor lightGray
        self.backgroundColor = UIColor.lightGray

        //set a border
        self.layer.borderWidth = 1
        //set a white border color
        self.layer.borderColor = UIColor.white.cgColor
        
        //the color of the text is darkGray
        self.textColor = UIColor.darkGray
        
        //always Helvetica Neue
        if let fnt = textFont {
            self.font = fnt
        } else {
            self.font = UIFont(name: "Helvetica Neue", size: 14.0)
        }

    }
    
    // Placeholder text
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        //the placeholder text is 10 point from the beginning
        return bounds.insetBy(dx: 10, dy: 0)
    }
    
    // Editable text
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        //the editable text is 10 point from the beginning
        return bounds.insetBy(dx: 10, dy: 0)
    }


}
