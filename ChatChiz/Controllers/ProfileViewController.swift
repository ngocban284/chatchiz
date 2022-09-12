//
//  ProfileViewController.swift
//  ChatChiz
//
//  Created by Ngoc Ban on 08/09/2022.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView:UITableView!
    
    let data = ["Log Out"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet = UIAlertController(title: "",
                                    message: "",
                                    preferredStyle: .actionSheet)
        
        actionSheet.addAction(
            UIAlertAction(title: "Log Out" ,
                        style: .destructive,
                        handler: {[weak self] _ in
                            
                            guard let strongSelf = self else{
                                return
                            }
                            
                            do{
                                ///logout
                                try FirebaseAuth.Auth.auth().signOut()
                                
                                ///navigation to login
                                let vc = LoginViewController()
                                let nav = UINavigationController(rootViewController: vc)
                                nav.modalPresentationStyle = .fullScreen
                                strongSelf.present(nav, animated: true)
                                 
                            }catch{
                                print("Fail to Log Out.")
                            }
        }))
        
        present(actionSheet, animated: true)
        
    }
    
    
}
