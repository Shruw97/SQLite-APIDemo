//
//  DBmanager.swift
//  FetchOfflineDataInDB
//
//  Created by saurabh wattamwar on 27/11/23.
//

import Foundation
import SQLite3

class DBmanager{
    
    var db : OpaquePointer? 
    
    init(){
        db = openDataBase()
        createTable()
    }
    
    func openDataBase() -> OpaquePointer?{
        //The path where the sqlite3 database file is created.
        let dbPath  = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("myDb.sqlite").path
        var db : OpaquePointer? = nil
       
        
        if sqlite3_open(dbPath, &db) != SQLITE_OK{
            debugPrint("Can't open database")
            return nil
        }else{
            print("Successfully created connection to database at \(dbPath)")
            return db
        }
    }
    
    func createTable(){
        let createTableString = "CREATE TABLE IF NOT EXISTS user(id INTEGER PRIMARY KEY, name TEXT)"
        
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK{
            if sqlite3_step(createTableStatement) == SQLITE_DONE{
                print("Users table created")
            }
            else{
                print("Users table could not be created")
            }
        }
        else{
            print("CREATE TABLE statement could not be prepared")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    
    func insert(id:Int,name:String){
        
        let users = read()
        for u in users{
            if u.id == id{
                break //checks if the id already exists and if so func will terminate & next lines won't execute.
            }
        }
        
        let insertStatementString = "INSERT INTO user(Id,name) VALUES (?,?);"
        var insertStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK{
            sqlite3_bind_int(insertStatement,1, Int32(id))
            sqlite3_bind_text(insertStatement,2, (name as NSString).utf8String, -1, nil)
          
            if sqlite3_step(insertStatement) == SQLITE_DONE{
                print("Successfully inserted row")
            }
            else{
                print("Could not insert row")
            }
        }
        else{
            print("INSERT statement could not be prepared")
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    func read() -> [UserModel]{
        let queryStatementString = "SELECT * FROM user;"
        var queryStatement: OpaquePointer? = nil
        var arrayOfUsersInRead: [UserModel] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK{
            
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = sqlite3_column_int(queryStatement, 0)
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
             
                
                arrayOfUsersInRead.append(UserModel(id:Int(id),name: name))
//                print("Query Result:")
//                print("\(id) | \(name)")
            }
        }else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return arrayOfUsersInRead
        
    }
   
}




//func fetchUsers() -> [UserModel]{
//    var usersArray = [UserModel]()
//
//    var documentDirectory =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//
//    documentDirectory.append("/myDb.sqlite")
//
//    print(documentDirectory)
//
//
//
//
//    let i1 = UserModel(id: 1, name: "Shruti")
//    usersArray.append(i1)
//
//    let i2 = UserModel(id: 2, name: "Shubham")
//    usersArray.append(i2)
//
//    let i3 = UserModel(id: 3, name: "Daramwar")
//    usersArray.append(i3)
//
//    return usersArray
//
//}
