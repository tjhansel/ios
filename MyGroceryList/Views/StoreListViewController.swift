//
//  StoreListViewController.swift
//  MyGroceryList
//
//  Created by Jordan Hansen on 3/2/23.
//

import UIKit
import CoreData

class StoreListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var stores = [Store]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Store List"
        view.addSubview(tableView)
        getAllStores()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(didTapClearAll))
    }
    
    @objc private func didTapAdd(){
        let alert = UIAlertController(title: "New Store", message: "Enter New Item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: {[weak self] _ in
            guard let nameField = alert.textFields?[0], let nameText = nameField.text, !nameText.isEmpty
            else {
                return
            }
            self?.createStore(storeName: nameText)
            
        }))
        self.present(alert, animated: true)
    }
    @objc private func didTapClearAll() {
        let alert = UIAlertController(title: "Clear All Stores", message: "Are you sure you want to delete all stores?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteAllStores()
        }))
        present(alert, animated: true)
    }
    @objc func storeNameTextFieldDidChange(_ textField: UITextField) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else {
            return
        }
        let selectedItem = stores[selectedIndexPath.row]
        selectedItem.name = textField.text ?? ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let store = stores[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let storeName = store.name
        
        cell.textLabel?.text = storeName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
        _ = stores[indexPath.row]
        
        performSegue(withIdentifier: "viewList", sender: nil)
//        let sheet = UIAlertController(title: "Modify Store", message: nil, preferredStyle: .actionSheet)
//        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: {_ in
//
//            let alert = UIAlertController(title: "Edit Store Name", message: "Update Store Name", preferredStyle: .alert)
//            alert.addTextField(configurationHandler: nil)
//            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: {[weak self] _ in
//                guard let field = alert.textFields?.first, let newStoreName = field.text, !newStoreName.isEmpty else {
//                    return
//                }
//
//                self?.updateStore(store: store, newStoreName: newStoreName)
//            }))
//            self.present(alert, animated: true)
//        }))
//        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] _ in
//            self?.deleteStore(store: store)
//        }))
//        present(sheet, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? ItemsListViewController
        let storeObj = stores [tableView.indexPathForSelectedRow?.row ?? 0]
        vc?.store = storeObj
    }
    
    //Core Data
    
    func createStore(storeName: String){
        let newStore = Store(context: context)
        newStore.name = storeName
        
        do{
            try context.save()
            getAllStores()
        }
        catch {
            fatalError("Failed to save store: \(error)")
        }
    }
    
    func getAllStores(){
        do{
            stores = try context.fetch(Store.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            fatalError("Failed to fetch stores: \(error)")
        }
    }
    
    func deleteStore(store: Store){
        context.delete(store)
        
        do{
            try context.save()
            getAllStores()
        }
        catch {
            fatalError("Failed to delete store: \(error)")
        }
    }
    
    func updateStore(store: Store, newStoreName: String){
        store.name = newStoreName
        
        do{
            try context.save()
            getAllStores()
        }
        catch {
            fatalError("Failed to update store: \(error)")
        }
        
    }
    func deleteAllStores() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Store.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            stores.removeAll()
            tableView.reloadData()
        }
        catch {
            fatalError("Failed to delete all stores: \(error)")
        }
    }
}
