//
//  ListViewController.swift
//  ListaCompras
//
//  Created by Vasco Gomes on 19/12/2016.
//  Copyright © 2016 Vasco Gomes. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController,UINavigationControllerDelegate ,UITableViewDelegate,UITableViewDataSource, NSFetchedResultsControllerDelegate
{
    @IBOutlet var listTableView: UITableView!
    @IBOutlet var listTitle: UITextField!
    @IBOutlet var segment: UISegmentedControl!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var copyButton: UIBarButtonItem!
    
    var listViewcontroller : NSFetchedResultsController<Item>!
    var listToEdit: List?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.delegate = self
        listTableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //if its null, its an edition
        if listToEdit != nil
        {
            loadCategoriesData()
        }
    }
    
    func loadCategoriesData()
    {
        if let list = listToEdit{
            
            listTitle.text = list.listName
            
            //fetchs data from Database by listName
            attemptFetch()
            
            //enable the button to add more items
            addButton.isEnabled = true
            copyButton.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(listViewcontroller != nil)
        {
            if let sections = listViewcontroller.sections
            {
                //if there is anything it will return its number
                let sectionInfo = sections[section]
                return sectionInfo.numberOfObjects
            }
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if(listViewcontroller != nil)
        {
            if let sections = listViewcontroller.sections
            {
                return sections.count
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //since we've setted the sectionNameKeyPath we should just present it
        if(listViewcontroller != nil)
        {
            return listViewcontroller.sections![section].name
        }
       
        return ""
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        //this will be called when a section is changed, thus managing section insertion and deletion
        switch(type)
        {
            case NSFetchedResultsChangeType.insert:
                let sectionIndexSet = NSIndexSet(index: sectionIndex)
                listTableView.insertSections(sectionIndexSet as IndexSet, with: .fade)
        
                break;
            
            case NSFetchedResultsChangeType.delete:
                let sectionIndexSet = NSIndexSet(index: sectionIndex)

                listTableView.deleteSections(sectionIndexSet as IndexSet,with: .fade)
                break;
        
            default:
                break;
        }
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell =  tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCellTableViewCell
        
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        
        return cell
    }
    
    func configureCell(cell : ItemCellTableViewCell, indexPath: NSIndexPath)
    {
        let item = listViewcontroller.object(at: (indexPath as NSIndexPath) as IndexPath)
        
        cell.configureCell(item: item)
        
        if(item.isChecked)
        {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
    }
    
    func checkListType()
    {
        var count = 0
        
        if(listViewcontroller != nil && listViewcontroller.fetchedObjects != nil)
        {
            for item in listViewcontroller.fetchedObjects!
            {
                if(item.isChecked)
                {
                    count+=1
                }
            }
        }

        if(count != 0 && count == listViewcontroller.fetchedObjects?.count)
        {
            listToEdit?.type = "Completed List"
        }
        else {
            listToEdit?.type = "Current List"
        }
    }
    
    @IBAction func longPressCheck(_ sender: Any) {
        
        //ATENTION
        //Long-press gestures are continuous. The gesture begins (UIGestureRecognizerStateBegan) when the number of allowable fingers (numberOfTouchesRequired) have been pressed for the specified period (minimumPressDuration - in our case 1 second) and the touches do not move beyond the allowable range of movement (allowableMovement). The gesture recognizer transitions to the Change state whenever a finger moves, and it ends (UIGestureRecognizerStateEnded) when any of the fingers are lifted.
        
        //we just want to go to edit when the gesture is ended
        if ((sender as AnyObject).state == UIGestureRecognizerState.ended) {
            //get the location pressed
            let location = (sender as AnyObject).location(in: listTableView) // Location
            
            //get the index
            guard let indexPath = listTableView.indexPathForRow(at: location) else { return }

            let selectedItem = listViewcontroller.object(at: (indexPath as IndexPath))
            
            //send it to itemDetails Controller
            performSegue(withIdentifier: "ItemDetailsViewController", sender: selectedItem)
        }
    }
    
    //when someone clicks the item on the table view this function is called
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //get selected Cell
        guard let selectedCell = listTableView.cellForRow(at: indexPath) else { return }
        
        //passing to the ItemCell custom class to handle the update of the object
        let selectedItem = listViewcontroller.object(at: (indexPath as NSIndexPath) as IndexPath)
        
        if (selectedCell.accessoryType == UITableViewCellAccessoryType.checkmark) {
            selectedCell.accessoryType = UITableViewCellAccessoryType.none
            selectedItem.isChecked = false
        }
        else {
            selectedCell.accessoryType = UITableViewCellAccessoryType.checkmark
            selectedItem.isChecked = true
        }
        
        //saving the change to isChecked
        ad.saveContext()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ItemDetailsViewController"
        {
            if let destination =  segue.destination as? ItemDetailsViewController
            {
                //cast the object as a item
                if let item = sender as? Item
                {
                    //if it is edit, we send an item
                    destination.itemToEdit = item
                }
            }
        }
        
        if segue.identifier == "AddItem"
        {
            if let destination =  segue.destination as? ItemDetailsViewController
            {
                //if we are adding, we send a list
                destination.list = listToEdit
            }
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        listTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        listTableView.endUpdates()
    }
    
    //listens for when we want to make a change
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type)
        {
        case.insert:
            if let indexPath = newIndexPath{
                listTableView.insertRows(at: [indexPath], with: .fade)
            }
            break
            
        case.delete :
            if let indexPath = indexPath{
                listTableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
            
            
        case.update:
            if let indexPath = indexPath{
                let cell = listTableView.cellForRow(at: indexPath) as? ItemCellTableViewCell
                
                configureCell(cell: (cell)!, indexPath: indexPath as NSIndexPath)
            }
            break
            
            
        //this is when its being dragged
        case.move :
            if let indexPath = indexPath {
                //delete at the old location
                listTableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath{
                listTableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        }
    }
    
    @IBAction func segmentChange(_ sender: Any) {
        
        //everytime someone selects a diferent sort, it will run through here
        attemptFetch()
        
        listTableView.reloadData()
    }
    
    @IBAction func onSave(_ sender: Any) {
        
        var list : List!
        var nameExists : Bool
        
        if listToEdit == nil{
            //check if name of list already exists (this check is only made in add mode, not in edit mode
            nameExists = checkIfNameExists()
        }
        else {
            nameExists = false
            
            //check if all the items on the list are checked
            checkListType()
            
            //if not, we we are in edit mode and we should edit the current item
            list=listToEdit
        }
        
        if(!nameExists)
        {
            if listToEdit == nil
            {
                //insert entity list to NSManagedContext
                list = List (context: context)
                list.createdDate = NSDate()
                list.type = "Current List"
            }
            
            if let title = listTitle.text{
                list.listName = title
            }
            ad.saveContext()
            
            //take us back to the main view controller
            _ = navigationController?.popViewController(animated: true)
        }
        else {
            let alertController = UIAlertController(title: "Alert", message:
                "A list with the same name already exists", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func checkIfNameExists() -> Bool
    {
        if listTitle.text != nil
        {
            let fetchRequest : NSFetchRequest<List> = List.fetchRequest()
            
            let title = listTitle.text!
            
            fetchRequest.predicate = NSPredicate(format: "listName == %@", title);
            
            fetchRequest.fetchLimit = 1
            
            //a fetch can fail so we have to do a do
            do{
                let count = try context.count(for: fetchRequest)
                if(count == 0){
                    // no matching object
                    return false
                }
                else{
                    // at least one matching object exists. Which means that we already have this list name
                    return true
                }
            }
            catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
        }
        return false
 
    }

    func checkIfNameExists(name: String) -> Bool
    {
        let fetchRequest : NSFetchRequest<List> = List.fetchRequest()
            
        fetchRequest.predicate = NSPredicate(format: "listName == %@", name);
            
        fetchRequest.fetchLimit = 1
            
        //a fetch can fail so we have to do a do
        do{
            let count = try context.count(for: fetchRequest)
            if(count == 0){
                    // no matching object
                return false
            }
            else{
                // at least one matching object exists. Which means that we already have this list name
                return true
            }
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        return false
    }

    
    @IBAction func onEdit(_ sender: Any) {
        listTableView.setEditing(!listTableView.isEditing, animated: true)
    }
    
    @IBAction func cancelToShoppingList(_ sender: Any) {
        
        //we should check because the changes of check are made in each click. Even if we press cancel it, they are already saved
        //we should check if all the items on the list are checked
        checkListType()
        
        ad.saveContext()
        
        //go back to Main View Controller
        _ =  navigationController?.popViewController(animated: true)
    }
    
    //fetch data from database
    func attemptFetch()
    {
        let fetchRequest : NSFetchRequest<Item> = Item.fetchRequest()
        
        //the default is sorting by category
        let categoryNameSort = NSSortDescriptor(key: "category.name", ascending: true)
        
        //the remaining sorts
        let titleSort = NSSortDescriptor(key: "title", ascending: true)
        let createdDateSort = NSSortDescriptor(key: "createdDate", ascending: true)
        let brandSort = NSSortDescriptor(key: "brand", ascending: true)
        
        if(listToEdit != nil)
        {
            fetchRequest.predicate = NSPredicate(format: "list.listName == %@", listToEdit!.listName!);
        }
        
        //the segment selected by default is the category
        if segment.selectedSegmentIndex == 0
        {
            fetchRequest.sortDescriptors = [titleSort]
            let lvcontroller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:context , sectionNameKeyPath: nil, cacheName: nil)
            
            lvcontroller.delegate = self
            
            self.listViewcontroller = lvcontroller
            
            //a fetch can fail so we have to do a do
            do{
                try lvcontroller.performFetch()
            } catch{
                let error = error as NSError!
                print("\(error)")
            }
            
        }
        else if segment.selectedSegmentIndex == 1 {
            fetchRequest.sortDescriptors = [createdDateSort]
            let lvcontroller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:context , sectionNameKeyPath: nil, cacheName: nil)
            
            lvcontroller.delegate = self
            
            self.listViewcontroller = lvcontroller
            
            //a fetch can fail so we have to do a do
            do{
                try lvcontroller.performFetch()
            } catch{
                let error = error as NSError!
                print("\(error)")
            }
            
        }
        else if segment.selectedSegmentIndex == 2 {
            //order by category and title
            fetchRequest.sortDescriptors = [categoryNameSort,titleSort]
            let lvcontroller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:context , sectionNameKeyPath: "category.name", cacheName: nil)
            
            lvcontroller.delegate = self
            
            self.listViewcontroller = lvcontroller
            
            //a fetch can fail so we have to do a do
            do{
                try lvcontroller.performFetch()
            } catch{
                let error = error as NSError!
                print("\(error)")
            }
        }
        else if segment.selectedSegmentIndex == 3 {
            //order by category and title
            fetchRequest.sortDescriptors = [brandSort,titleSort]
            let lvcontroller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:context , sectionNameKeyPath: "brand", cacheName: nil)
            
            lvcontroller.delegate = self
            
            self.listViewcontroller = lvcontroller
            
            //a fetch can fail so we have to do a do
            do{
                try lvcontroller.performFetch()
            } catch{
                let error = error as NSError!
                print("\(error)")
            }
        }
        
        if (listToEdit != nil)
        {
            editButton.isEnabled = true
        }
    }
    
    @IBAction func onCopy(_ sender: Any) {
        //check if we have anything to copy
        if listToEdit != nil{
            
            let copiedName = (listToEdit?.listName)! + " (1)"

            //if the list wasn't copied yet -> if the name doesn't exist
            if(!checkIfNameExists(name: copiedName))
            {
                var copiedList : List!
                //copy List
                copiedList = List (context: context)
            
                copiedList.createdDate = NSDate()
                copiedList.listName = copiedName
            
                copiedList.type = "Current List"
            
                if(listViewcontroller != nil && listViewcontroller.fetchedObjects != nil)
                {
                    for item in listViewcontroller.fetchedObjects!
                    {
                        var copieditem : Item!
                    
                        copieditem = Item (context:context)
                
                        copieditem.title = item.title
                        copieditem.quantity = item.quantity
                        copieditem.details = item.details
                        copieditem.unity = item.unity

                        copieditem.isChecked = false
                    
                        let category = item.category
                    
                        copiedList.addToItems(copieditem)
                        category?.addToItems(copieditem)
                    }
                }
            
                ad.saveContext()
                
                //go back to Main View Controller
                _ =  navigationController?.popViewController(animated: true)
            }
            else {
                //a copy of the list with the same name already exists
                
                let alertController = UIAlertController(title: "Alert", message:
                    "A copy of this list was already made", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        else
        {
            //it should never enter here
            let alertController = UIAlertController(title: "Alert", message:
                "No list make copy from", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }

    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete {
            
            //passing to the ItemCell custom class to handle the update of the object
            let selectedItem = listViewcontroller.object(at: (indexPath as NSIndexPath) as IndexPath)
            
            context.delete(selectedItem)
                
            ad.saveContext()
        }
    }
    
    @IBAction func onDelete(_ sender: Any) {
        //check if we have anything to delete
        if listToEdit != nil{
            context.delete(listToEdit!)
            ad.saveContext()
        }
        
        //go back to Main View Controller
        _ =  navigationController?.popViewController(animated: true)
    }
}
