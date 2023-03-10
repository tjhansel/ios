//
//  ItemsListViewController.swift
//  MyGroceryList
//
//  Created by Jordan Hansen on 3/2/23.
//

import CoreData
import UIKit

class ItemsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models = [GroceryListItem]()
    
    var store: Store?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Grocery List"
        view.addSubview(tableView)
        getAllItems()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(didTapClearAll)),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        ]
    }
    
    @objc private func didTapAdd(){
        let alert = UIAlertController(title: "New Item", message: "Enter New Item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: {[weak self] _ in
            guard let nameField = alert.textFields?[0], let nameText = nameField.text, !nameText.isEmpty
            else {
                return
            }
            self?.createItem(name: nameText)
        }))
        present(alert, animated: true)
    }
    @objc private func didTapClearAll() {
           let alert = UIAlertController(title: "Clear All Items", message: "Are you sure you want to delete all items?", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
           alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
               self?.deleteAllItems()
           }))
           present(alert, animated: true)
       }
//    @objc func storeNameTextFieldDidChange(_ textField: UITextField) {
//        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
//            return
//        }
//        let selectedItem = models[selectedIndexPath.row]
//        selectedItem.storeName = textField.text ?? ""
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // strikeout and check mark
        let checkmark = model.completed ? "" : ""
        cell.textLabel?.attributedText = NSAttributedString(string: "\(checkmark) \(model.itemName ?? "Purchased Item Removed")", attributes: [NSAttributedString.Key.strikethroughStyle: model.completed ? NSUnderlineStyle.single.rawValue : 0])
        cell.accessoryType = model.completed ? .checkmark : .none
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeGesture.direction = model.completed ? .left : .right
        cell.addGestureRecognizer(swipeGesture)
        
        let groceryListItem = models[indexPath.row]
        
        cell.textLabel?.text = groceryListItem.itemName
            
        return cell
    }
    @objc private func handleSwipeGesture(_ gestureRecognizer: UISwipeGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let item = models[indexPath.row]
        item.completed.toggle()
        
        do {
            try context.save()
            getAllItems()
        } catch {
            fatalError("Failed to save item: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = models[indexPath.row]
        let sheet = UIAlertController(title: "Modify Item", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: {_ in
            
            let alert = UIAlertController(title: "Edit Item", message: "Update Grocery Item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: {[weak self] _ in
                guard let field = alert.textFields?.first, let newItemName = field.text, !newItemName.isEmpty else {
                    return
                }
                
                self?.updateItem(item: item, newItemName: newItemName)
            }))
            self.present(alert, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] _ in
            self?.deleteItem(item: item)
        }))
        present(sheet, animated: true)
    }
    
    
    
    
    // Core Data
    
    func getAllItems(){
        models = store?.listItems?.allObjects as? [GroceryListItem] ?? []
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func createItem(name: String){
        let newItem = GroceryListItem(context: context)
        newItem.itemName = name
        newItem.addedAt = Date()
        store?.addToListItems(newItem)
        
        do{
            try context.save()
            getAllItems()
        }
        catch {
            fatalError("Failed to save item: \(error)")
        }
    }
    
    func deleteItem(item: GroceryListItem){
        context.delete(item)
        
        do{
            try context.save()
            getAllItems()
        }
        catch {
            fatalError("Failed to delete item: \(error)")
        }
    }
    
    func updateItem(item: GroceryListItem, newItemName: String){
        item.itemName = newItemName
        
        do{
            try context.save()
            getAllItems()
        }
        catch {
            fatalError("Failed to update item: \(error)")
        }
        
    }
    func deleteAllItems() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = GroceryListItem.fetchRequest()
        _ = store!.name
        let predicate = NSPredicate(format: "store.name == %@", store!.name!)
        fetchRequest.predicate = predicate
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        if let delete = try? context.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            
            do {
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                try context.save()
            } catch {
                fatalError("\(error)")
            }

            getAllItems()
        }
        getAllItems()
    }
}

