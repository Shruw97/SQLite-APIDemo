//
//  ViewController.swift
//  FetchOfflineDataInDB
//
//  Created by saurabh wattamwar on 27/11/23.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
  
   
    @IBOutlet weak var userCollectionView: UICollectionView!
    
    var dbManagerObj : DBmanager? = DBmanager.init()
    
    var users = [UserModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        userCollectionView.dataSource = self
        userCollectionView.delegate = self
    
        
        let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 20
    
            userCollectionView.collectionViewLayout = layout
       
        
        fetchDataFromAPI()
        
        let nib = UINib(nibName: "UserCollectionViewCell", bundle: .main)
        self.userCollectionView.register(nib, forCellWithReuseIdentifier: "UserCollectionViewCell")
        
        let headerNib = UINib(nibName: "UserCollectionReusableView", bundle: .main)
        self.userCollectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "UserCollectionReusableView")
        layout.headerReferenceSize = CGSize(width: self.userCollectionView.frame.width, height: 50)
     
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let userCollectionViewCell = userCollectionView.dequeueReusableCell(withReuseIdentifier: "UserCollectionViewCell", for: indexPath) as! UserCollectionViewCell
        var temp = users[indexPath.row]
        userCollectionViewCell.idLbl.text = "\(temp.id)"
        userCollectionViewCell.nameLbl.text = temp.name
        
        return userCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return  CGSize(width: (self.userCollectionView.frame.width - 10)/2, height: 150)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "UserCollectionReusableView", for: indexPath) as! UserCollectionReusableView
//        headerView.backgroundColor = .cyan
        headerView.delegate = self
        return headerView
        
    }
    
    func switchBtnClicked(isSwitchOn : Bool){
        print("switch clicked action in vc \(isSwitchOn)")
      
        if isSwitchOn == true{
            users.removeAll()
            self.userCollectionView.reloadData()
            fetchDataFromAPI()
        }else{
           
            var arrayOfModel = dbManagerObj?.read()
            users.removeAll()
            users.append(contentsOf: arrayOfModel!)
            self.userCollectionView.reloadData()
        }
       
    }
    
    func fetchDataFromDB(){
        users.removeAll()
        self.userCollectionView.reloadData()
    }
    
    
    func fetchDataFromAPI(){
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let urlsession = URLSession(configuration: .default)
        
        let datatask = urlsession.dataTask(with: request) { data, response, error in
            if error != nil || data == nil{
                print("error is \(error)")
                return
            }
            do{
                let jsonObj = try JSONSerialization.jsonObject(with: data!) as! [[String : Any]]
                
                for eachDictionary in jsonObj{
                    let eachId = eachDictionary["id"] as! Int
                    let eachName = eachDictionary["name"] as! String
                    
                    let modelObj = UserModel(id: eachId, name: eachName)
                    self.users.append(modelObj)
                    
                }
                
                ///At this point of time, data has downloaded and stored in array. Now, we can insert records from users array in db. So, call insert function from here.
                self.saveUsersInDB()
                
                DispatchQueue.main.async {
                    self.userCollectionView.reloadData()
                }
                
             
                
            }
            
            catch{
                print("JSON not parsed : \(error.localizedDescription)")
            }
        }
        datatask.resume()
    }
    
    func saveUsersInDB(){
        for item in self.users{
            self.dbManagerObj?.insert(id: item.id, name: item.name)
        }
      
    }
 }

