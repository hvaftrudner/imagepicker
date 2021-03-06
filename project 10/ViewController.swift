//
//  ViewController.swift
//  project 10
//
//  Created by Kristoffer Eriksson on 2020-09-25.
//
import LocalAuthentication
import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()
    var hidden = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //load()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "unlock", style: .plain, target: self, action: #selector(unlock))
        
    }
    // remember to add Face id privacy to info.plist
    @objc func unlock(_ sender: Any){
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            let reason = "Identify Yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockImages()
                    } else {
                        // error
                        let ac = UIAlertController(title: "Authentication Failed", message: "You could not be verified, pls try again", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        
                        self?.present(ac, animated: true)
                        
                    }
                }
                
            }
        } else {
            //no biometrics
            let ac = UIAlertController(title: "Biometry not available", message: "Your device does not have biometric notification", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func unlockImages(){
        
        load()
        collectionView.reloadData()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue personCell")
        }
        
        let person = people[indexPath.item]
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let person = people[indexPath.item]
        
        let options = UIAlertController(title: "Options", message: nil, preferredStyle: .alert)
        options.addAction(UIAlertAction(title: "Rename", style: .default){_ in
            let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
            ac.addTextField()
            ac.addAction(UIAlertAction(title: "OK", style: .default) {
                [weak self, weak ac] _ in
                guard let newName = ac?.textFields?[0].text else {return}
                person.name = newName
                self?.collectionView.reloadData()
            })
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(ac, animated: true)
        })
        options.addAction(UIAlertAction(title: "Delete", style: .default){ _ in
            let ac2 = UIAlertController(title: "Delete", message: nil, preferredStyle: .alert)
            ac2.addAction(UIAlertAction(title: "OK", style: .default){
                [weak self] _ in
                self?.people.remove(at: indexPath.item)
                self?.collectionView.reloadData()
            })
            ac2.addAction(UIAlertAction(title: "Cancel", style: .default))
            self.present(ac2, animated: true)
        })
        options.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(options, animated: true)
    
    }
    @objc func addNewPerson(){
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
            print(picker.sourceType)
        }
        
        picker.allowsEditing = true
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else {return}
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8){
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        save()
        collectionView.reloadData()
        
        dismiss(animated: true)
        
    }
    
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    //save and load with userdefaults / keywrapper didnt work on array
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(people) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        }
        else {
            print("Failed to save people")
        }
    }
    
    func load (){
        let defaults = UserDefaults.standard
                
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            let jsonDecoder = JSONDecoder()
                do {
                
                people = try jsonDecoder.decode([Person].self, from: savedPeople)
            }
            catch {
                print("Failed to load people")
            }
        }
    }
    
    
}

