//
//  ViewController.swift
//  ListaCompras
//
//  Created by Vasco Gomes on 19/12/2016.
//  Copyright © 2016 Vasco Gomes. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UITableViewController, NSFetchedResultsControllerDelegate{
    
    var controller : NSFetchedResultsController<List>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        attemptFetch()
        
        //If it's the first time, load dummy data
        if (controller.sections?.count)! <= 0
        {
            generateTestData()
            attemptFetch()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(controller != nil)
        {
            if let sections = controller.sections
            {
                //if there is anything it will return its number
                let sectionInfo = sections[section]
                return sectionInfo.numberOfObjects
            }
        }
        return 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if(controller != nil)
        {
            if let sections = controller.sections
            {
                return sections.count
            }
        }
        
        return 0
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        //this will be called when a section is changed, thus managing section insertion and deletion
        switch(type)
        {
        case NSFetchedResultsChangeType.insert:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            tableView.insertSections(sectionIndexSet as IndexSet, with: .fade)
            
            break;
            
        case NSFetchedResultsChangeType.delete:
            let sectionIndexSet = NSIndexSet(index: sectionIndex)
            
            tableView.deleteSections(sectionIndexSet as IndexSet,with: .fade)
            break;
            
        default:
            break;
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //creating a cell passing the itemCell and the indexPath
        let cell =  tableView.dequeueReusableCell(withIdentifier: "ListItemCell", for: indexPath) as! ListItemCell
        
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        
        return cell
    }
    
    func configureCell(cell : ListItemCell, indexPath : NSIndexPath)
    {
        let list = controller.object(at: (indexPath as NSIndexPath) as IndexPath)
        
        cell.configureCell(list: list)
    }
    
    //when someone clicks the item on the table view this function is called
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedList = controller.object(at: (indexPath as NSIndexPath) as IndexPath)
        
        performSegue(withIdentifier: "ListViewController", sender: selectedList)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //since we've setted the sectionNameKeyPath we should just present it
        if(controller != nil)
        {
            return controller.sections![section].name
        }
        
        return ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //if there is the segue we are looking for
        if segue.identifier == "ListViewController"
        {
            if let destination =  segue.destination as? ListViewController
            {
                //cast the object as a item
                if let list = sender as? List
                {
                    destination.listToEdit = list
                }
            }
        }
    }
    
    //fetch data from database
    func attemptFetch()
    {
        let fetchRequest : NSFetchRequest<List> = List.fetchRequest()
        
        //the default is sorting by date
        let dateSort = NSSortDescriptor(key: "createdDate", ascending: false)
        
        fetchRequest.sortDescriptors = [dateSort]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:context , sectionNameKeyPath: "type", cacheName: nil)
        
        controller.delegate = self
        
        self.controller = controller
        
        //a fetch can fail so we have to do a do
        do{
            try controller.performFetch()
        } catch{
            let error = error as NSError!
            print("\(error)")
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    //listens for when we want to make a change
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type)
        {
        case.insert:
            if let indexPath = newIndexPath{
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
            
        case.delete :
            if let indexPath = indexPath{
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
            
        case.update:
            if let indexPath = indexPath{
                let cell = tableView.cellForRow(at: indexPath) as! ListItemCell
                
                configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            }
            break
            
        //this is when its been dragged
        case.move :
            if let indexPath = indexPath {
                //delete at the old location
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath{
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        }
    }
    
    //used once, persited, and then we can leave it
    func generateTestData()
    {
        /************* ITEM **************/
        let item = Item(context: context)
        
        item.title = "Pêras"
        item.quantity = 1
        item.unity = "Kg"
        item.price = 1.67
        item.brand = "Continente"
        item.createdDate = NSDate()

        let item2 = Item(context: context)
        
        item2.title = "Maçãs"
        item2.quantity = 5
        item2.price = 1.56
        item2.unity = "Units"
        item2.brand = "Continente"
        item2.createdDate = NSDate()

        let item3 = Item(context: context)
        
        item3.title = "Bifes Frango"
        item3.quantity = 1
        item3.price = 4
        item3.unity = "Kg"
        item3.brand = "Continente"
        item3.createdDate = NSDate()
        
        let item4 = Item(context: context)
        
        item4.title = "Candeeiro"
        item4.quantity = 1
        item4.price = 5
        item4.unity = "Units"
        item4.brand = "Kasa"
        item4.createdDate = NSDate()
        
        /********* TYPES *****************/
        let category = Category(context: context)
        category.name = "Animais"
        
        let category2 = Category(context: context)
        category2.name = "Bébé"
        
        let category3 = Category(context: context)
        category3.name = "Bebidas"
        
        let category4 = Category(context: context)
        category4.name = "Beleza"
        
        let category5 = Category(context: context)
        category5.name = "Bio&Saudável"
        
        let category6 = Category(context: context)
        category6.name = "Casa"
        item4.category = category6
        
        let category7 = Category(context: context)
        category7.name = "Congelados"
        
        let category8 = Category(context: context)
        category8.name = "Frescos"
        item3.category = category8
        
        let category9 = Category(context: context)
        category9.name = "Higiene"
        
        let category10 = Category(context: context)
        category10.name = "Lacticínios"
        
        let category11 = Category(context: context)
        category11.name = "Lazer"
        
        let category12 = Category(context: context)
        category12.name = "Limpeza"

        let category13 = Category(context: context)
        category13.name = "Mercearia"
        item.category = category13
        item2.category = category13
        
        let category14 = Category(context: context)
        category14.name = "Saúde"

        /*********** LIST ***************/
        let list = List(context: context)
        
        list.listName = "Lista de Compras"
        list.addToItems(item)
        list.addToItems(item2)
        list.addToItems(item3)
        list.addToItems(item4)
        list.type = "Current List"
        
        ad.saveContext()
    }
}

