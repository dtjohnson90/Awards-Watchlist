//
//  FriendsViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/16/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import FirebaseFirestore

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    struct friends {
        let name: String
        let email: String
        let photo: UIImage
    }
    struct inviteInfo {
        let name: String
        let email: String
    }
    
    var invitations = [String]()
    var invitationsArray = [inviteInfo]()
    var friendsList = [friends]()
    var friendChosen = String()
    var screenSize = CGRect()
    var screenHeight = CGFloat()
    
    @IBAction func unwindToFriends(segue: UIStoryboardSegue) {}
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var invitationsTableView: UITableView!
    @IBOutlet weak var friendsHiddenView: UIView!
    @IBOutlet weak var invitationsHiddenView: UIView!
    @IBOutlet weak var friendsTableHeight: NSLayoutConstraint!
    @IBOutlet weak var invitationsTableHeight: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var purchaseView: UIView!
    
    @IBAction func searchClicked(_ sender: Any) {
        if (searchField.text?.isEmpty)! {
            let alertController = UIAlertController(title: "Error", message: "Email field is blank", preferredStyle: UIAlertControllerStyle.alert)
            
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(ok)
            
            self.present(alertController, animated: true, completion: nil)
        } else if searchField.text == Items.sharedInstance.loggedIn {
            let alertController = UIAlertController(title: "Error", message: "You cannot add yourself as a friend", preferredStyle: UIAlertControllerStyle.alert)
            
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(ok)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            let myRef = Firestore.firestore().collection("UserMovieList").document(searchField.text!)
            myRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    var previousInvitations = document.data()!["Invitations"] as! [String]
                    if previousInvitations.contains(Items.sharedInstance.loggedIn) {
                        let alertController = UIAlertController(title: "Error", message: "There is already an invitation pending for this user.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                            (result : UIAlertAction) -> Void in
                        }
                        
                        alertController.addAction(ok)
                        
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        previousInvitations.append(Items.sharedInstance.loggedIn)
                        myRef.updateData([
                            "Invitations": previousInvitations
                        ]) { err in
                            if err != nil {
                                let alertController = UIAlertController(title: "Error", message: "Your invitation could not be sent. Please check your connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
                                
                                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                    (result : UIAlertAction) -> Void in
                                }
                                
                                alertController.addAction(ok)
                                
                                self.present(alertController, animated: true, completion: nil)
                            } else {
                                let alertController = UIAlertController(title: "Success", message: "Your invitations has been sent", preferredStyle: UIAlertControllerStyle.alert)
                                
                                let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                    (result : UIAlertAction) -> Void in
                                }
                                
                                alertController.addAction(ok)
                                
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    let alertController = UIAlertController(title: "Error", message: "There was no account found with that email. Please try again", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                        (result : UIAlertAction) -> Void in
                    }
                    
                    alertController.addAction(ok)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Items.sharedInstance.purchased {
            purchaseView.isHidden = true
        } else {
            purchaseView.isHidden = false
            self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
        
        friendsTableView.dataSource = nil
        invitationsTableView.dataSource = nil
        friendsHiddenView.isHidden = true
        invitationsHiddenView.isHidden = true
        
        hideKeyboardWhenTappedAround()
        searchField.delegate = self
        screenSize = UIScreen.main.bounds
        screenHeight = screenSize.height
        
        Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            self.invitations.removeAll()
            self.invitationsArray.removeAll()
            self.friendsList.removeAll()
            
            self.invitations = data["Invitations"] as! [String]
            let loadingFriends = document.data()!["Friends"] as! [String]
            
            if self.invitations.isEmpty {
                self.invitationsHiddenView.isHidden = false
            } else {
                self.invitationsHiddenView.isHidden = true
            }
            if loadingFriends.isEmpty {
                self.friendsHiddenView.isHidden = false
            } else {
                self.friendsHiddenView.isHidden = true
            }
            
            let friendDownloading = DispatchGroup()
            for friend in loadingFriends {
                friendDownloading.enter()
                Firestore.firestore().collection("UserMovieList").document(friend).getDocument { (document2, error) in
                    if let document2 = document2, document2.exists {
                        var photo = UIImage()
                        let photoURL = document2.data()!["Image URL"] as! String
                        if photoURL == "nil" {
                            photo = UIImage(named: "profilePic")!
                            self.friendsList.append(friends(name: document2.data()!["Name"] as! String, email: friend, photo: photo))
                            friendDownloading.leave()
                        } else {
                            let url = URL(string: photoURL)!
                            self.getData(from: url) { data, response, error in
                                guard let data = data, error == nil else {
                                    photo = UIImage(named: "profilePic")!
                                    self.friendsList.append(friends(name: document2.data()!["Name"] as! String, email: friend, photo: photo))
                                    friendDownloading.leave()
                                    return
                                }
                                print(response?.suggestedFilename ?? url.lastPathComponent)
                                print("Download Finished")
                                DispatchQueue.main.async() {
                                    photo = UIImage(data: data)!
                                    self.friendsList.append(friends(name: document2.data()!["Name"] as! String, email: friend, photo: photo))
                                    friendDownloading.leave()
                                }
                            }
                        }
                    }
                }
            }
            friendDownloading.notify(queue: .main) {
                print("Done")
                self.friendsTableView.dataSource = self
                self.friendsTableView.reloadData()
                if self.friendsList.count == 0 {
                    self.friendsTableHeight.constant = 72
                } else {
                    self.friendsTableHeight.constant = CGFloat(72 * self.friendsList.count)
                }
                self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: self.contentView.bounds.height + 75)
            }
            
            let inviteDownloading = DispatchGroup()
            for invite in self.invitations {
                inviteDownloading.enter()
                Firestore.firestore().collection("UserMovieList").document(invite).getDocument { (document, error) in
                    if let document2 = document, document2.exists {
                        self.invitationsArray.append(inviteInfo(name: document2.data()!["Name"] as! String, email: document2.documentID))
                        inviteDownloading.leave()
                    }
                }
            }
            inviteDownloading.notify(queue: .main) {
                self.invitationsTableView.dataSource = self
                self.invitationsTableView.reloadData()
                if self.invitationsArray.count == 0 {
                    self.invitationsTableHeight.constant = 72
                } else {
                    self.invitationsTableHeight.constant = CGFloat(92 * self.invitationsArray.count)
                }
                let totalHeight = self.friendsTableHeight.constant + self.invitationsTableHeight.constant + 250
                self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: totalHeight)
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = CGRect(x:self.view.frame.origin.x, y:self.view.frame.origin.y - 200, width:self.view.frame.size.width, height:self.view.frame.size.height);
            
        })
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = CGRect(x:self.view.frame.origin.x, y:self.view.frame.origin.y + 200, width:self.view.frame.size.width, height:self.view.frame.size.height);
            
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Items.sharedInstance.purchased {
            purchaseView.isHidden = true
        } else {
            purchaseView.isHidden = false
            self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == friendsTableView {
            return friendsList.count
        } else {
            return invitations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == friendsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendsTableViewCell
            
            cell.nameLabel.text = friendsList[indexPath.row].name
            cell.profilePic.image = friendsList[indexPath.row].photo
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "invitationCell", for: indexPath) as! InvitationTableViewCell
            
            cell.nameLabel.text = invitationsArray[indexPath.row].name
            cell.acceptButton.addTarget(self, action: #selector(accepted(_:)), for: .touchUpInside)
            cell.acceptButton.tag = indexPath.row
            
            cell.declineButton.addTarget(self, action: #selector(self.declined(_:)), for: .touchUpInside)
            cell.declineButton.tag = indexPath.row
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if tableView == invitationsTableView {
            return 92
        } else {
            return 72
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == friendsTableView {
            friendChosen = friendsList[indexPath.row].email
            performSegue(withIdentifier: "showFriendSegue", sender: self)
        }
    }
    
    @objc func accepted (_ sender: UIButton){
        let inviteVar = self.invitations[sender.tag]
        let docRef = Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var friendList = document.data()!["Friends"] as! [String]
                friendList.append(self.invitations[sender.tag])
                var oldInvitations = self.invitations
                oldInvitations.remove(at: sender.tag)
                
                docRef.updateData([
                    "Friends": friendList,
                    "Invitations": oldInvitations
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        let docRef2 = Firestore.firestore().collection("UserMovieList").document(inviteVar)
                        docRef2.getDocument { (document, error) in
                            if let document2 = document, document2.exists {
                                var friendList2 = document2.data()!["Friends"] as! [String]
                                friendList2.append(Items.sharedInstance.loggedIn)
                                
                                docRef2.updateData([
                                    "Friends": friendList2
                                ]) { err in
                                    if let err = err {
                                        print("Error updating document: \(err)")
                                    } else {
                                        print("Document successfully updated")
                                    }
                                }
                            } else {
                                print("Document does not exist")
                            }
                        }
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @objc func declined (_ sender: UIButton){
        let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to decline this invitation?", preferredStyle: UIAlertControllerStyle.alert)
        
        let ok = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
        }
        let decline = UIAlertAction(title: "Decline", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            
            self.invitations.remove(at: sender.tag)
            Firestore.firestore().collection("UserMovieList").document(Items.sharedInstance.loggedIn).updateData([
                "Invitations": self.invitations
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
        
        alertController.addAction(ok)
        alertController.addAction(decline)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFriendSegue" {
            let tabBarController = segue.destination as! UITabBarController
            
            let destinationViewController = tabBarController.viewControllers![0] as! UINavigationController // or whatever tab index you're trying to access
            let targetcontroller = destinationViewController.topViewController as! FriendsSeenViewController
            targetcontroller.friendChosen = friendChosen
            
            let destinationViewController2 = tabBarController.viewControllers![1] as! UINavigationController // or whatever tab index you're trying to access
            let targetcontroller2 = destinationViewController2.topViewController as! FriendPredictionsViewController
            targetcontroller2.friendChosen = friendChosen
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
