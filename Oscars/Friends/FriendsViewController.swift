//
//  FriendsViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/16/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FacebookCore
import Social
import NVActivityIndicatorView

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    struct friends {
        let name: String
        let email: String
        let photo: UIImage
        let available: Bool
    }
    
    var invitations = [String]()
    var invitationsArray = [friends]()
    var friendsList = [friends]()
    var suggestedFriends = [friends]()
    var friendChosen = String()
    var screenSize = CGRect()
    var screenHeight = CGFloat()
    var testArray = [Bool](repeating: false, count: 3)
    var checkTimer: Timer!
    var totalHeight = CGFloat()
    
    @IBAction func unwindToFriends(segue: UIStoryboardSegue) {}
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var purchaseView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var myActivityView: NVActivityIndicatorView!
    
    @IBAction func searchClicked(_ sender: Any) {
        if (searchField.text?.isEmpty)! {
            let alertController = UIAlertController(title: "Error", message: "Email field is blank", preferredStyle: UIAlertController.Style.alert)
            
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(ok)
            
            self.present(alertController, animated: true, completion: nil)
        } else if searchField.text == Items.sharedInstance.loggedIn {
            let alertController = UIAlertController(title: "Error", message: "You cannot add yourself as a friend", preferredStyle: UIAlertController.Style.alert)
            
            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                self.searchField.text = ""
            }
            
            alertController.addAction(ok)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            self.logError(logString: "Friends VC - Attempting to send invite via search to \(searchField.text!)")
            sendInvite(email: searchField.text!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myActivityView.startAnimating()
        
        self.checkTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(LoadingNewViewController.repeatCheck),userInfo: nil, repeats: true)
        
        if Items.sharedInstance.purchased {
            purchaseView.isHidden = true
        } else {
            purchaseView.isHidden = false
        }
        
        friendsTableView.dataSource = nil
        
        hideKeyboardWhenTappedAround()
        searchField.delegate = self
        screenSize = UIScreen.main.bounds
        screenHeight = screenSize.height
        
        Firestore.firestore().collection("Users").document(Items.sharedInstance.loggedIn).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                self.logError(logString: "Friends VC - Unable to load User document", logError: (error?.localizedDescription)!)
                let alertController = UIAlertController(title: "Error", message: "We could not load the necessary data. Please quit the app and try again", preferredStyle: UIAlertController.Style.alert)
                
                
                let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    UserDefaults.standard.removeObject(forKey: "loggedIn")
                    Items.sharedInstance.loggedIn = ""
                }
                
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            guard let data = document.data() else {
                return
            }
            
            self.invitations.removeAll()
            self.invitationsArray.removeAll()
            self.friendsList.removeAll()
            
            self.invitations = data["Invitations"] as! [String]
            let loadingFriends = document.data()!["Friends"] as! [String]
            
            let friendDownloading = DispatchGroup()
            for friend in loadingFriends {
                friendDownloading.enter()
                Firestore.firestore().collection("Users").document(friend).getDocument { (friendDocument, error) in
                    if let error = error {
                        self.logError(logString: "Friends VC - Error Loading Friend Document (Friend: \(friend))", logError: error.localizedDescription)
                    } else {
                        if let friendDocument = friendDocument, friendDocument.exists {
                            var photo = UIImage()
                            let photoURL = friendDocument.data()!["imageURL"] as! String
                            if photoURL == "nil" {
                                photo = UIImage(named: "profilePic")!
                                self.friendsList.append(friends(name: friendDocument.data()!["Name"] as! String, email: friend, photo: photo, available: true))
                                friendDownloading.leave()
                            } else {
                                let url = URL(string: photoURL)!
                                self.getData(from: url) { data, response, error in
                                    guard let data = data, error == nil else {
                                        photo = UIImage(named: "profilePic")!
                                        self.friendsList.append(friends(name: friendDocument.data()!["Name"] as! String, email: friend, photo: photo, available: true))
                                        friendDownloading.leave()
                                        return
                                    }
                                    DispatchQueue.main.async() {
                                        photo = UIImage(data: data)!
                                        self.friendsList.append(friends(name: friendDocument.data()!["Name"] as! String, email: friend, photo: photo, available: true))
                                        friendDownloading.leave()
                                    }
                                }
                            }
                        } else {
                            Firestore.firestore().collection("UserMovieList2020").document(friend).getDocument { (friendDocument, error) in
                                if let error = error {
                                    self.logError(logString: "Friends VC - Error Loading Friend Document (Friend: \(friend))", logError: error.localizedDescription)
                                    friendDownloading.leave()
                                } else {
                                    if let friendDocument = friendDocument, friendDocument.exists {
                                        var photo = UIImage()
                                        let photoURL = friendDocument.data()!["Image URL"] as! String
                                        if photoURL == "nil" {
                                            photo = UIImage(named: "profilePic")!
                                            self.friendsList.append(friends(name: friendDocument.data()!["Name"] as! String, email: friend, photo: photo, available: false))
                                            friendDownloading.leave()
                                        } else {
                                            let url = URL(string: photoURL)!
                                            self.getData(from: url) { data, response, error in
                                                guard let data = data, error == nil else {
                                                    photo = UIImage(named: "profilePic")!
                                                    self.friendsList.append(friends(name: friendDocument.data()!["Name"] as! String, email: friend, photo: photo, available: false))
                                                    friendDownloading.leave()
                                                    return
                                                }
                                                DispatchQueue.main.async() {
                                                    photo = UIImage(data: data)!
                                                    self.friendsList.append(friends(name: friendDocument.data()!["Name"] as! String, email: friend, photo: photo, available: false))
                                                    friendDownloading.leave()
                                                }
                                            }
                                        }
                                    } else {
                                        print("No Document")
                                        friendDownloading.leave()
                                    }
                                }
                            }
                            self.logError(logString: "Friends VC - Friend Document Doesn't Exist (Friend \(friend))")
                        }
                    }
                }
            }
            friendDownloading.notify(queue: .main) {
                self.logError(logString: "Friends VC - Succesfully Loaded Friends")
                self.checkScroll()
                self.friendsTableView.reloadData()
                self.testArray[0] = true
            }
            
            let inviteDownloading = DispatchGroup()
            for invite in self.invitations {
                inviteDownloading.enter()
                Firestore.firestore().collection("Users").document(invite).getDocument { (inviteDocument, error) in
                    if let error = error {
                        self.logError(logString: "Friends VC - Error Loading Invitation Document (Invite: \(invite))", logError: error.localizedDescription)
                    } else {
                        if let inviteDocument = inviteDocument, inviteDocument.exists {
                            var photo = UIImage()
                            let photoURL = inviteDocument.data()!["imageURL"] as! String
                            if photoURL == "nil" {
                                photo = UIImage(named: "profilePic")!
                                self.invitationsArray.append(friends(name: inviteDocument.data()!["Name"] as! String, email: invite, photo: photo, available: true))
                                inviteDownloading.leave()
                            } else {
                                let url = URL(string: photoURL)!
                                self.getData(from: url) { data, response, error in
                                    guard let data = data, error == nil else {
                                        photo = UIImage(named: "profilePic")!
                                        self.invitationsArray.append(friends(name: inviteDocument.data()!["Name"] as! String, email: invite, photo: photo, available: true))
                                        inviteDownloading.leave()
                                        return
                                    }
                                    DispatchQueue.main.async() {
                                        photo = UIImage(data: data)!
                                        self.invitationsArray.append(friends(name: inviteDocument.data()!["Name"] as! String, email: invite, photo: photo, available: true))
                                        inviteDownloading.leave()
                                    }
                                }
                            }
                        } else {
                            self.logError(logString: "Friends VC - Invitation Document Doesn't Exist (Invitation: \(invite))")
                            inviteDownloading.leave()
                        }
                    }
                }
            }
            inviteDownloading.notify(queue: .main) {
                self.logError(logString: "Friends VC - Invitations Loaded Succesfully")
                self.checkScroll()
                self.friendsTableView.reloadData()
                self.testArray[1] = true
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePurchased), name:NSNotification.Name(rawValue: "purchased"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil
        )
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.frame.origin.y = -keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func updatePurchased(notification: NSNotification){
        if Items.sharedInstance.purchased {
            purchaseView.isHidden = true
        } else {
            purchaseView.isHidden = false
        }
    }
    
    @objc func repeatCheck() {
        for item in testArray {
            if item == false {
                return
            }
        }
        
        self.logError(logString: "Friends VC - Everything Loaded Succesfully")
        
        var tempSuggestions = [friends]()
        for suggestion in self.suggestedFriends {
            if !self.friendsList.contains(where: {$0.email == suggestion.email}) {
                tempSuggestions.append(suggestion)
            }
        }
        self.suggestedFriends = tempSuggestions
        
        checkScroll()
        
        DispatchQueue.main.async {
            self.myActivityView.stopAnimating()
            self.loadingView.isHidden = true
            self.friendsTableView.dataSource = self
            self.friendsTableView.reloadData()
        }
        checkTimer.invalidate()
    }
    
    func sendInvite(email: String) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let myRef = Firestore.firestore().collection("Users").document(email)
        myRef.getDocument { (document, error) in
            if let error = error {
                self.logError(logString: "Friends VC - Error Getting Invite Document (Invite: \(email))", logError: error.localizedDescription)
            } else {
                if let document = document, document.exists {
                    var previousInvitations = document.data()!["Invitations"] as! [String]
                    if previousInvitations.contains(Items.sharedInstance.loggedIn) {
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.logError(logString: "Friends VC - Invite Already Sent for User")
                        let alertController = UIAlertController(title: "Error", message: "There is already an invitation pending for this user.", preferredStyle: UIAlertController.Style.alert)
                        
                        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                            (result : UIAlertAction) -> Void in
                            self.searchField.text = ""
                            
                        }
                        
                        alertController.addAction(ok)
                        
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        previousInvitations.append(Items.sharedInstance.loggedIn)
                        myRef.updateData([
                            "Invitations": previousInvitations
                        ]) { err in
                            if err != nil {
                                self.logError(logString: "Friends VC - Error Sending Invite", logError: (err?.localizedDescription)!)
                                UIApplication.shared.endIgnoringInteractionEvents()
                                let alertController = UIAlertController(title: "Error", message: "Your invitation could not be sent. Please check your connection and try again.", preferredStyle: UIAlertController.Style.alert)
                                
                                let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                    (result : UIAlertAction) -> Void in
                                }
                                
                                alertController.addAction(ok)
                                
                                self.present(alertController, animated: true, completion: nil)
                            } else {
                                self.logError(logString: "Friends VC - Invitation Sent Succesfully")
                                UIApplication.shared.endIgnoringInteractionEvents()
                                let alertController = UIAlertController(title: "Success", message: "Your invitations has been sent", preferredStyle: UIAlertController.Style.alert)
                                
                                let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                    (result : UIAlertAction) -> Void in
                                    self.searchField.text = ""
                                    
                                }
                                
                                alertController.addAction(ok)
                                
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    self.logError(logString: "Friends VC - No Account Found with Email")
                    UIApplication.shared.endIgnoringInteractionEvents()
                    let alertController = UIAlertController(title: "Error", message: "There was no account found with that email. Either this person has not updated to the latest version of the app, or this is an incorrect email", preferredStyle: UIAlertController.Style.alert)
                    
                    let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        self.searchField.text = ""
                        
                    }
                    
                    alertController.addAction(ok)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    /*
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = CGRect(x:self.view.frame.origin.x, y:self.view.frame.origin.y - 200, width:self.view.frame.size.width, height:self.view.frame.size.height);
            
        })
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = CGRect(x:self.view.frame.origin.x, y:self.view.frame.origin.y + 200, width:self.view.frame.size.width, height:self.view.frame.size.height);
            
        })
    }*/
    
    override func viewDidAppear(_ animated: Bool) {
        self.logError(logString: "In Friends VC")
        suggestedFriends.removeAll()
        if Items.sharedInstance.purchased {
            purchaseView.isHidden = true
            if AccessToken.current != nil {
                let connection = GraphRequestConnection()
                connection.add(GraphRequest(graphPath: "/me/friends")) { httpResponse, result, error in
                    if error != nil {
                        // Unable to get Facebook Information
                        self.logError(logString: "Friends VC - Unable To Get Facebook Friends Info", logError: error!.localizedDescription)
                        self.friendsTableView.reloadData()
                        self.testArray[2] = true
                    } else {
                        if let result = result as? [String:Any] {
                            if let allSuggested = result["data"]{
                                let data = allSuggested as! [NSDictionary]
                                let suggestedDownloading = DispatchGroup()
                                for friendObject in data {
                                    suggestedDownloading.enter()
                                    let friendID = friendObject["id"] as! String
                                    self.logError(logString: "Friends VC - Getting Friend Data for ID \(friendID)")
                                    Firestore.firestore().collection("Users").whereField("FacebookID", isEqualTo: friendID).getDocuments() { (querySnapshot, err) in
                                        if let err = err {
                                            self.logError(logString: "Friends VC - Error Getting Facebook Friend Document", logError: err.localizedDescription)
                                        } else {
                                            if !querySnapshot!.documents.isEmpty {

                                                let document = querySnapshot!.documents[0]
                                                let documentInfo = document.data()
                                                var photo = UIImage()
                                                let photoURL = documentInfo["imageURL"] as! String
                                                
                                                var friendTest = false
                                                for item in self.friendsList {
                                                    if item.email == document.documentID {
                                                        friendTest = true
                                                    }
                                                }
                                                for item2 in self.invitationsArray {
                                                    if item2.email == document.documentID {
                                                        friendTest = true
                                                    }
                                                }
                                                
                                                if friendTest == false {
                                                    if photoURL == "nil" {
                                                        photo = UIImage(named: "profilePic")!
                                                        self.suggestedFriends.append(friends(name: documentInfo["Name"] as! String, email: document.documentID, photo: photo, available: true))
                                                        suggestedDownloading.leave()
                                                    } else {
                                                        let url = URL(string: photoURL)!
                                                        self.getData(from: url) { data, response, error in
                                                            guard let data = data, error == nil else {
                                                                self.logError(logString: "Friends VC - Unable to get Facebook Friends Profile Photo", logError: (error?.localizedDescription)!)
                                                                photo = UIImage(named: "profilePic")!
                                                                self.suggestedFriends.append(friends(name: documentInfo["Name"] as! String, email: document.documentID, photo: photo, available: true))
                                                                suggestedDownloading.leave()
                                                                return
                                                            }
                                                            DispatchQueue.main.async() {
                                                                photo = UIImage(data: data)!
                                                                self.suggestedFriends.append(friends(name: documentInfo["Name"] as! String, email: document.documentID, photo: photo, available: true))
                                                                suggestedDownloading.leave()
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    self.logError(logString: "Friends VC - Found Facebook friend but he is already added as a friend or already in the invitations list")
                                                    suggestedDownloading.leave()
                                                }
                                            } else {
                                                self.logError(logString: "Friends VC - Found friend but they are not in the database")
                                                suggestedDownloading.leave()
                                            }
                                        }
                                    }
                                }
                                suggestedDownloading.notify(queue: .main) {
                                    self.logError(logString: "Friends VC - All Facebook Friends Downloaded")
                                    self.friendsTableView.reloadData()
                                    self.testArray[2] = true
                                }
                                
                            } else {
                                self.logError(logString: "Friends VC - Couldn't load Facebook Data")
                                self.friendsTableView.reloadData()
                                self.testArray[2] = true
                            }
                        } else {
                            self.logError(logString: "Friends VC - Couldn't load Facebook Data - 2")
                            self.friendsTableView.reloadData()
                            self.testArray[2] = true
                        }
                    }
                }
                connection.start()
            } else {
                checkScroll()
                friendsTableView.reloadData()
                self.testArray[2] = true
            }
        } else {
            purchaseView.isHidden = false
            testArray[2] = true
        }
    }
    
    func checkScroll() {
        var friendCount = friendsList.count
        var invitationCount = invitationsArray.count
        var suggestedCount = suggestedFriends.count
        if friendCount == 0 {
            friendCount = 1
        }
        if invitationCount == 0 {
            invitationCount = 1
        }
        if suggestedCount == 0 {
            suggestedCount = 1
        }
        let totalCount = friendCount + invitationCount + suggestedCount
        let totalSize = CGFloat((totalCount * 72) + 400)
        
        if totalSize > UIScreen.main.bounds.height {
            friendsTableView.isScrollEnabled = true
        } else {
            friendsTableView.isScrollEnabled = false
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if friendsList.count == 0 {
                return 1
            } else {
                return friendsList.count
            }
        } else if section == 1 {
            if invitationsArray.count == 0 {
                return 1
            } else {
                return invitationsArray.count
            }
        } else {
            if suggestedFriends.count == 0 {
                return 1
            } else if suggestedFriends.count > 5 {
                return 5
            } else {
                return suggestedFriends.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendsTableViewCell
        
        if indexPath.section == 0 {
            if friendsList.count == 0 {
                cell.isUserInteractionEnabled = false
                cell.hiddenView.isHidden = false
                cell.noFacebookLabel.isHidden = true
                cell.noFriendsLabel.isHidden = false
                cell.noInvitationsLabel.isHidden = true
                cell.noSuggestionsLabel.isHidden = true
                cell.shareButton.isHidden = true
            } else {
                cell.isUserInteractionEnabled = true
                cell.hiddenView.isHidden = true
                cell.nameLabel.text = friendsList[indexPath.row].name
                cell.profilePic.image = friendsList[indexPath.row].photo
            }
        } else if indexPath.section == 1 {
            if invitationsArray.count == 0 {
                cell.isUserInteractionEnabled = false
                cell.hiddenView.isHidden = false
                cell.noFacebookLabel.isHidden = true
                cell.noFriendsLabel.isHidden = true
                cell.noInvitationsLabel.isHidden = false
                cell.noSuggestionsLabel.isHidden = true
                cell.shareButton.isHidden = true
            } else {
                cell.isUserInteractionEnabled = true
                cell.hiddenView.isHidden = true
                cell.nameLabel.text = invitationsArray[indexPath.row].name
                cell.profilePic.image = invitationsArray[indexPath.row].photo
            }
        } else {
            if AccessToken.current != nil {
                if suggestedFriends.count == 0 {
                    cell.isUserInteractionEnabled = true
                    cell.hiddenView.isHidden = false
                    cell.noFacebookLabel.isHidden = true
                    cell.noFriendsLabel.isHidden = true
                    cell.noInvitationsLabel.isHidden = true
                    cell.noSuggestionsLabel.isHidden = false
                    cell.shareButton.isHidden = false
                    cell.shareButton.addTarget(self, action: #selector(shareFacebook(_:)), for: .touchUpInside)
                } else {
                    cell.isUserInteractionEnabled = true
                    cell.hiddenView.isHidden = true
                    cell.nameLabel.text = suggestedFriends[indexPath.row].name
                    cell.profilePic.image = suggestedFriends[indexPath.row].photo
                }
            } else {
                cell.isUserInteractionEnabled = false
                cell.hiddenView.isHidden = false
                cell.noFacebookLabel.isHidden = false
                cell.noFriendsLabel.isHidden = true
                cell.noInvitationsLabel.isHidden = true
                cell.noSuggestionsLabel.isHidden = true
                cell.shareButton.isHidden = true
            }
        }
        
        return cell
    }
    
    @objc func shareFacebook (_ sender: UIButton){
        self.logError(logString: "Friends VC - Share Facebook Clicked")
        let socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        
        socialController?.add(URL(string: "https://itunes.apple.com/us/app/awards-watchlist/id1197448840?mt=8"))
        
        self.present(socialController!, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section
        {
        case 0:
            return "Current Friends:"
        case 1:
            return "Invitations:"
        default:
            return "Suggested Friends:"
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        if #available(iOS 13.0, *) {
            view.tintColor = UIColor.systemGray2
        } else {
            // Fallback on earlier versions
            view.tintColor = UIColor.black
        }
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColorFromRGB(rgbValue: 0x9B8742)
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            DispatchQueue.main.async {
                if self.friendsList[indexPath.row].available {
                    self.friendChosen = self.friendsList[indexPath.row].email
                    self.performSegue(withIdentifier: "showFriendSegue", sender: self)
                } else {
                    let alertController = UIAlertController(title: "Error", message: "Your friend has not updated to the latest version of the app, therefore their information is not available.", preferredStyle: UIAlertController.Style.alert)

                    let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                     (result : UIAlertAction) -> Void in
                     return }

                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else if indexPath.section == 1 {
            DispatchQueue.main.async {
                let friend = self.invitationsArray[indexPath.row]
                let alertController = UIAlertController(title: "", message: "Would you like to accepted or delcline the invitation from \(friend.name)", preferredStyle: UIAlertController.Style.actionSheet)
                
                let decline = UIAlertAction(title: "Decline", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    self.logError(logString: "Friends VC - Attempting Decline of Invitation")
                    self.declined(rowNumber: indexPath.row)
                }
                let accept = UIAlertAction(title: "Accept", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    self.logError(logString: "Friends VC - Attempting Accept of Invitation")
                    self.accepted(rowNumber: indexPath.row)
                }
                
                alertController.addAction(decline)
                alertController.addAction(accept)
                
                self.present(alertController, animated: true, completion: nil)
            }
        } else {
            DispatchQueue.main.async {
                if self.suggestedFriends.count != 0 {
                    let suggestion = self.suggestedFriends[indexPath.row]
                    let alertController = UIAlertController(title: "Invite", message: "Would you like to send a friend invite to \(suggestion.name)", preferredStyle: UIAlertController.Style.alert)
                    
                    let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                    }
                    let send = UIAlertAction(title: "Send Invite", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        self.logError(logString: "Friends VC - Attempting Invitation Send to \(suggestion.email)")
                        self.sendInvite(email: suggestion.email)
                    }
                    
                    alertController.addAction(cancel)
                    alertController.addAction(send)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            if friendsList.count == 0 {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            
            let friendName = friendsList[indexPath.row].name
            let alertController = UIAlertController(title: "Remove Friend", message: "Are you sure you want to delete \(friendName)?", preferredStyle: UIAlertController.Style.alert)
            
            let ok = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
            }
            let delete = UIAlertAction(title: "Delete", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                self.logError(logString: "Friends VC - Attempting to delete friend \(self.friendsList[indexPath.row].email)")
                UIApplication.shared.beginIgnoringInteractionEvents()
                
                let friendRemoving = self.friendsList[indexPath.row].email
                self.friendsList.remove(at: indexPath.row)
                self.friendsTableView.reloadData()
                var newFriends = [String]()
                for friend in self.friendsList {
                    newFriends.append(friend.email)
                }
                
                Firestore.firestore().collection("Users").document(Items.sharedInstance.loggedIn).updateData([
                    "Friends": newFriends
                ]) { err in
                    if let err = err {
                        self.logError(logString: "Friends VC - Error Removing Friend" , logError: err.localizedDescription)
                        let alertController = UIAlertController(title: "Error", message: "There was an error removing this friend. Please quit the app and try again", preferredStyle: UIAlertController.Style.alert)
                        
                        
                        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                            (result : UIAlertAction) -> Void in
                            UIApplication.shared.endIgnoringInteractionEvents()
                            return
                        }
                        
                        alertController.addAction(ok)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                
                let docRef = Firestore.firestore().collection("Users").document(friendRemoving)
                docRef.getDocument { (document, error) in
                    if let error = error {
                        self.logError(logString: "Friends VC - Error Accessing document of friend deleting", logError: error.localizedDescription)
                    } else {
                        if let document = document, document.exists {
                            let friends = document.data()!["Friends"] as! [String]
                            var newFriends2 = [String]()
                            
                            let friendsDownloading = DispatchGroup()
                            for item in friends {
                                friendsDownloading.enter()
                                if item != Items.sharedInstance.loggedIn {
                                    newFriends2.append(item)
                                }
                                friendsDownloading.leave()
                            }
                            friendsDownloading.notify(queue: .main) {
                                docRef.updateData([
                                    "Friends": newFriends2
                                ]) { err in
                                    if let err = err {
                                        self.logError(logString: "Friends VC - Error Updating document of friend deleting", logError: err.localizedDescription)
                                        let alertController = UIAlertController(title: "Error", message: "There was an error removing this friend. Please quit the app and try again", preferredStyle: UIAlertController.Style.alert)
                                        
                                        
                                        let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                            (result : UIAlertAction) -> Void in
                                            return
                                        }
                                        
                                        alertController.addAction(ok)
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                }
                            }
                        } else {
                            self.logError(logString: "Friends VC - Document of friend trying to delete doesn't exist")
                            let alertController = UIAlertController(title: "Error", message: "There was an error removing this friend. Please quit the app and try again", preferredStyle: UIAlertController.Style.alert)
                            
                            
                            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                UIApplication.shared.endIgnoringInteractionEvents()
                                return
                            }
                            
                            alertController.addAction(ok)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
            
            alertController.addAction(ok)
            alertController.addAction(delete)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func invited (rowNumber: Int) {
        sendInvite(email: suggestedFriends[rowNumber].email)
        suggestedFriends.remove(at: rowNumber)
        friendsTableView.reloadData()
    }
    
    func accepted (rowNumber: Int){
        UIApplication.shared.beginIgnoringInteractionEvents()
        let inviteVar = self.invitations[rowNumber]
        let docRef = Firestore.firestore().collection("Users").document(Items.sharedInstance.loggedIn)
        docRef.getDocument { (document, error) in
            if let error = error {
                self.logError(logString: "Friends VC - Error Accesing user document", logError: error.localizedDescription)
            } else {
                if let document = document, document.exists {
                    var friendList = document.data()!["Friends"] as! [String]
                    friendList.append(self.invitations[rowNumber])
                    var oldInvitations = self.invitations
                    oldInvitations.remove(at: rowNumber)
                    
                    docRef.updateData([
                        "Friends": friendList,
                        "Invitations": oldInvitations
                    ]) { err in
                        if let err = err {
                            self.logError(logString: "Friends VC - Error Updating friends/invitations in user document", logError: err.localizedDescription)
                            let alertController = UIAlertController(title: "Error", message: "There was an error accepting this invitation. Please quit the app and try again", preferredStyle: UIAlertController.Style.alert)
                            
                            
                            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                UIApplication.shared.endIgnoringInteractionEvents()
                                return
                            }
                            
                            alertController.addAction(ok)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            let docRef2 = Firestore.firestore().collection("Users").document(inviteVar)
                            docRef2.getDocument { (document, error) in
                                if let document2 = document, document2.exists {
                                    var friendList2 = document2.data()!["Friends"] as! [String]
                                    friendList2.append(Items.sharedInstance.loggedIn)
                                    
                                    docRef2.updateData([
                                        "Friends": friendList2
                                    ]) { err in
                                        if let err = err {
                                            self.logError(logString: "Friends VC - Error Updating Friends document", logError: err.localizedDescription)
                                            let alertController = UIAlertController(title: "Error", message: "There was an error adding this friend. Please quit the app and try again", preferredStyle: UIAlertController.Style.alert)
                                            
                                            
                                            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                                (result : UIAlertAction) -> Void in
                                                return
                                            }
                                            
                                            alertController.addAction(ok)
                                            self.present(alertController, animated: true, completion: nil)
                                        }
                                        UIApplication.shared.endIgnoringInteractionEvents()
                                    }
                                } else {
                                    self.logError(logString: "Friends VC - Friend document doesn't exist")
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    let alertController = UIAlertController(title: "Error", message: "There was an error adding this friend. Please quit the app and try again", preferredStyle: UIAlertController.Style.alert)
                                    
                                    
                                    let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                        (result : UIAlertAction) -> Void in
                                        return
                                    }
                                    
                                    alertController.addAction(ok)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                } else {
                    self.logError(logString: "Friends VC - User Document Doesn't Exist")
                    let alertController = UIAlertController(title: "Error", message: "There was an error adding this friend. Please quit the app and try again", preferredStyle: UIAlertController.Style.alert)
                    
                    
                    let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        UIApplication.shared.endIgnoringInteractionEvents()
                        return
                    }
                    
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func declined (rowNumber: Int){
        let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to decline this invitation?", preferredStyle: UIAlertController.Style.alert)
        
        let ok = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        let decline = UIAlertAction(title: "Decline", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            UIApplication.shared.beginIgnoringInteractionEvents()
            self.invitations.remove(at: rowNumber)
            //self.friendsTableView.reloadData()
            Firestore.firestore().collection("Users").document(Items.sharedInstance.loggedIn).updateData([
                "Invitations": self.invitations
            ]) { err in
                if let err = err {
                    self.logError(logString: "Friends VC - Error Removing Invtation From User Document", logError: err.localizedDescription)
                    let alertController = UIAlertController(title: "Error", message: "There was an error removing this invitation. Please quit the app and try again", preferredStyle: UIAlertController.Style.alert)
                    
                    
                    let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        return
                    }
                    
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                }
                UIApplication.shared.endIgnoringInteractionEvents()
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
    
    func logError(logString: String, logError: String = "") {
        if logError == "" {
            do {
                let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                let url = dir.appendingPathComponent("logFile.txt")
                try logString.appendLine(to: url as URL)
                //let result = try String(contentsOf: url as URL, encoding: String.Encoding.utf8)
            }
            catch {
                print("Could not write to file")
            }
        } else {
            do {
                let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                let url = dir.appendingPathComponent("logFile.txt")
                try logString.appendLine(to: url as URL)
                try logError.appendLine(to: url as URL)
                //let result = try String(contentsOf: url as URL, encoding: String.Encoding.utf8)
            }
            catch {
                print("Could not write to file")
            }
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
