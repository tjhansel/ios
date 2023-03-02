//
//  ViewController.swift
//  MyGroceryList
//
//  Created by Jordan Hansen on 3/2/23.
//

import CoreData
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models = [GroceryListItem]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Grocery List"
        view.addSubview(tableView)
        getAllItems()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(didTapClearAll))
    }
    @objc private func didTapAdd(){
        let alert = UIAlertController(title: "New Item", message: "Enter New Item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: {[weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            self?.createItem(name: text)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let checkmark = model.completed ? "" : ""
        cell.textLabel?.attributedText = NSAttributedString(string: "\(checkmark) \(model.itemName ?? "Purchased Item Removed")", attributes: [NSAttributedString.Key.strikethroughStyle: model.completed ? NSUnderlineStyle.single.rawValue : 0])

           // Add checkmark toggle
           cell.accessoryType = model.completed ? .checkmark : .none
           
           // Add swipe gestures
           let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
           swipeGesture.direction = model.completed ? .left : .right
           cell.addGestureRecognizer(swipeGesture)
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
            alert.textFields?.first?.text = item.itemName
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
        do{
            models = try context.fetch(GroceryListItem.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            fatalError("Failed to fetch items: \(error)")
        }
    }
    
    func createItem(name: String){
        let newItem = GroceryListItem(context: context)
        newItem.itemName = name
        newItem.addedAt = Date()
        
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
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            models.removeAll()
            tableView.reloadData()
        }
        catch {
            fatalError("Failed to delete all items: \(error)")
        }
    }
}

