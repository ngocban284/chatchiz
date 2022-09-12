//
//  DatabaseManager.swift
//  ChatChiz
//
//  Created by Ngoc Ban on 11/09/2022.
//

import Foundation
import FirebaseDatabase

struct ChatAppUser{
    let firstName:String
    let lastName:String
    let emailAddress:String
    
    var safeEmail:String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private var database = Database.database().reference(fromURL: "https://chat-chiz-default-rtdb.asia-southeast1.firebasedatabase.app/")
    
}

// MARK-account management
extension DatabaseManager{
    /// validate new user
    public func userExists(with email:String,completion:@escaping((Bool)->Void)){
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value,with:{
            DataSnapshot in
            
            guard DataSnapshot.value as? String != nil else{
                completion(false)
                return
            }
            
            completion(true)
        })
        
    }
    
    /// insert new user to database
    public func insertUser(with user:ChatAppUser){
        database.child(user.safeEmail).setValue([
            "firstName":user.firstName,
            "lastName":user.lastName
        ])
    }
}
