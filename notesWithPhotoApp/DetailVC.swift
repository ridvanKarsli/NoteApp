//
//  DetailVC.swift
//  notesWithPhotoApp
//
//  Created by Rıdvan KARSLI on 29.01.2024.
//

import UIKit
import CoreData

class DetailVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenTitle = ""
    var chosenId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenTitle != ""{
            //getData
            saveButton.isEnabled = false
            titleText.isEnabled = false
            noteText.isEditable = false
            imageView.isUserInteractionEnabled = false
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteWP")
            
            let idText = chosenId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idText!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let title = result.value(forKey: "title") as? String{
                            titleText.text = title
                        }
                        if let note = result.value(forKey: "note") as? String{
                            noteText.text = note
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }catch{
                print("error")
            }
        }else{
            saveButton.isEnabled = false
            titleText.isEnabled = false
            noteText.isEditable = false
            imageView.isUserInteractionEnabled = true
        }

        //selecting a photo
        
        
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
    
    @objc func imageTap(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        titleText.isEnabled = true
        noteText.isEditable = true
        saveButton.isEnabled = true
        imageView.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        //saving datas
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newNote = NSEntityDescription.insertNewObject(forEntityName: "NoteWP", into: context)
        
        newNote.setValue(noteText.text, forKey: "note")
        newNote.setValue(titleText.text, forKey: "title")
        newNote.setValue(UUID(), forKey: "id")
        let imageData = imageView.image?.jpegData(compressionQuality: 0.5)
        newNote.setValue(imageData, forKey: "image")
        
        do{
            try context.save()
        }catch{
            print("error")
        }
        
        //send a message thath did someting
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        //go back the vc
        self.navigationController?.popViewController(animated: true)
    }

}
