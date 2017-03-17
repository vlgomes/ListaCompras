//
//  ItemDetailsViewController.swift
//  ListaCompras
//
//  Created by Vasco Gomes on 20/12/2016.
//  Copyright © 2016 Vasco Gomes. All rights reserved.
//

import UIKit
import CoreData

class ItemDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet var itemTitle: CustomTextField!
    @IBOutlet var itemQuantity: CustomTextField!
    @IBOutlet var itemDetails: CustomTextField!
    @IBOutlet var itemBrand: CustomTextField!
    @IBOutlet var itemPrice: CustomTextField!
    @IBOutlet var unitsSwitch: UISwitch!
    @IBOutlet var kgSwitch: UISwitch!
    @IBOutlet var litersSwitch: UISwitch!
    @IBOutlet var categoryPicker: UIPickerView!
    
    var itemToEdit: Item?
    var categories = [Category]()
    var list : List?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryPicker.delegate = self
        categoryPicker.delegate = self
    
        loadCategories()
        
        if itemToEdit != nil
        {
            loadItemData()
        }
        else
        {
            unitsSwitch.setOn(true, animated: true)
            kgSwitch.setOn(false, animated: true)
            litersSwitch.setOn(false, animated: true)
        }
    }
    
    func loadCategories()
    {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            //set the types array to the result saved in core data
            self.categories = try context.fetch(fetchRequest)
            self.categoryPicker.reloadAllComponents()
            
        } catch {
            print("Error loading the types")
        }
    }

    @IBAction func unitOn(_ sender: Any) {
        if(!unitsSwitch.isOn)
        {
            unitsSwitch.setOn(true, animated: true)
            kgSwitch.setOn(false, animated: true)
            litersSwitch.setOn(false, animated: true)
        }
        else {
            unitsSwitch.setOn(false, animated: true)
        }
        
        //check if the others are off
        if(!kgSwitch.isOn && !litersSwitch.isOn)
        {
            unitsSwitch.setOn(true, animated: true)
        }
    }
    
    @IBAction func kgOn(_ sender: Any) {
        if(!kgSwitch.isOn)
        {
            kgSwitch.setOn(true, animated: true)
            unitsSwitch.setOn(false, animated: true)
            litersSwitch.setOn(false, animated: true)
        }
        else {
            kgSwitch.setOn(false, animated: true)
        }
        
        //check if the others are off
        if(!unitsSwitch.isOn && !litersSwitch.isOn)
        {
            kgSwitch.setOn(true, animated: true)
        }
    }
    
    @IBAction func literOn(_ sender: Any) {
        if(!litersSwitch.isOn)
        {
            litersSwitch.setOn(true, animated: true)
            unitsSwitch.setOn(false, animated: true)
            kgSwitch.setOn(false, animated: true)
        }
        else {
            litersSwitch.setOn(false, animated: true)
        }
        
        //check if the others are off
        if(!unitsSwitch.isOn && !kgSwitch.isOn)
        {
            litersSwitch.setOn(true, animated: true)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let category = categories[row]
        return category.name
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //only 1 picker view
        return categories.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //how many columns there are
        //we don't neeed to check the tag because in both there are only 1 component
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //update when selected
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadItemData()
    {
        
        if let item = itemToEdit{
            
            itemTitle.text = item.title
            itemQuantity.text = "\(item.quantity)"
            itemPrice.text = "\(item.price)"
            itemDetails.text = item.details
            itemBrand.text = item.brand
            
            if(item.unity == "Units")
            {
                unitsSwitch.setOn(true, animated: true)
                kgSwitch.setOn(false, animated: true)
                litersSwitch.setOn(false, animated: true)
            }
            else if(item.unity == "Kg")
            {
                kgSwitch.setOn(true, animated: true)
                unitsSwitch.setOn(false, animated: true)
                litersSwitch.setOn(false, animated: true)
            }
            else if(item.unity == "Liters")
            {
                litersSwitch.setOn(true, animated: true)
                unitsSwitch.setOn(false, animated: true)
                kgSwitch.setOn(false, animated: true)
            }
            
            //select the type from the item, and select it
            if let category = item.category
            {
                var index = 0
                repeat
                {
                    let cat = categories[index]
                    if cat.name == category.name
                    {
                        categoryPicker.selectRow(index, inComponent: 0, animated: false)
                        break
                    }
                    
                    index += 1
                    
                } while (index < categories.count)
            }

            //since it's an editing 
            if self.list == nil{
                self.list = item.list
            }
        }
    }
    
    @IBAction func onSave(_ sender: Any) {
        
        var item : Item!
    
        
        if itemToEdit == nil{
            //if this occurs, there is a new item
            item = Item (context: context)
            item.createdDate = NSDate()
        }
        else {
            //if not, we are in edit mode and we are editing the current item
            item=itemToEdit
            
            //in the case of edition, we remove from the category and list. Later we will add again
            let oldCategory = item.category
            
            oldCategory?.removeFromItems(item)
            list!.removeFromItems((item))
        }

        if let title = itemTitle.text{
            item.title = title
        }
        
        if let quantity = itemQuantity.text{
            //convert the string to float
            item.quantity = (quantity as NSString).floatValue
        }
        
        if let price = itemPrice.text{
            //convert the string to double
            item.price = (price as NSString).floatValue
        }
        
        if let brand = itemBrand.text{
            item.brand = brand
        }
        
        if let details = itemDetails.text{
            item.details = details
        }
        
        if(unitsSwitch.isOn)
        {
            item.unity = "Units"
        }
        else if(kgSwitch.isOn)
        {
            item.unity = "Kg"
        }
        else if(litersSwitch.isOn)
        {
            item.unity = "Liters"
        }
        
        //inComponent means the columns, since there is only one column, it should be 0
        let category = categories[categoryPicker.selectedRow(inComponent: 0)]
        
        item.category = category

        category.addToItems(item)
        list!.addToItems(item)
 
        ad.saveContext()
        
        //take us back to previouse view controller
        _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func onCancel(_ sender: Any) {
        
        //go back to previous view controller
        _ =  navigationController?.popViewController(animated: true)
        
    }
}
