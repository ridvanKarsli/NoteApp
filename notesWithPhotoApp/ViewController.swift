//
//  ViewController.swift
//  notesWithPhotoApp
//
//  Created by Rıdvan KARSLI on 29.01.2024.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var idArray = [UUID]()
    var titleArray = [String]()
    var selectedTitle = ""
    var selectedId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableview çalışması için
        tableView.delegate = self
        tableView.dataSource = self
        
        //üst kısma buton ekleme
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButton))
        
        
        //it work when an object saved in coreData
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
        
        getData()
    }
    
    @objc func getData(){
        //get datas
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteWP")
        
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if let title = result.value(forKey: "title") as? String{
                        self.titleArray.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
                    self.tableView.reloadData()
                }
            }
        }catch{
            print("error")
        }
    }
    
    @objc func addButton(){
        selectedTitle = ""
        performSegue(withIdentifier: "toDetailVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC"{
            let destination = segue.destination as! DetailVC
            destination.chosenTitle = selectedTitle
            destination.chosenId = selectedId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTitle = titleArray[indexPath.row]
        selectedId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteWP")
            
            let idText = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idText)
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row]{
                                context.delete(result)
                                idArray.remove(at: indexPath.row)
                                titleArray.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                }catch{
                                    print("error")
                                }
                                break
                            }
                        }
                    }
                }
            }catch{
                print("error")
            }
            
        }
    }


}

