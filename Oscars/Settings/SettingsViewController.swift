//
//  SettingsViewController.swift
//  Oscars
//
//  Created by Dustin Johnson on 10/18/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import GoogleSignIn
import FirebaseAuth
import FirebaseFirestore
import StoreKit
import MessageUI

//class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, GIDSignInDelegate, GIDSignInUIDelegate, MFMailComposeViewControllerDelegate {
class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, GIDSignInDelegate, MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var accountArray = ["Change Name","Update Photo"]
    var loginArray = [String](repeating: "", count: 3)
    var logoArray = [UIImage(named: "user")!,UIImage(named: "camera")!, UIImage(named: "FacebookIcon")!,UIImage(named: "GoogleIcon")!,UIImage(named: "Mail-icon")!,UIImage(named: "remove")!,UIImage(named: "remove")!,UIImage(named: "remove")!]
    var dataArray = ["Change Name","Update Photo","","","Sign Out","Clear Movies Seen", "Clear Predictions","Clear All Data"]
    var memberImage = Items.sharedInstance.profilePic
    var imageUpdated = false
    
    var name = ""
    var email = ""
    var rowSelected = Int()
    let imageUploadManager = ImageUploadManager()
    let errorManager = ErrorManager()
    var providers = [String]()
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {}
    @IBOutlet weak var settingsTable: UITableView!
    @IBOutlet weak var versionLabel: UILabel!
    //@IBOutlet weak var settingsImage: UIImageView!
    //@IBOutlet weak var accountTable: UITableView!
    //@IBOutlet weak var dataTable: UITableView!
    @IBOutlet weak var proLabel: UILabel!
    @IBOutlet weak var proButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameChangeView: UIView!
    @IBOutlet weak var nameChangeField: UITextField!
    @IBOutlet weak var textConstraint: NSLayoutConstraint!
    
    @IBAction func rateClicked(_ sender: Any) {
        self.logError(logString: "Settings VC - Rate App Clicked")
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            rateApp(appId: "id1197448840")
        }
    }
    @IBAction func purchaseClicked(_ sender: Any) {
        self.logError(logString: "Settings VC - Purchase Pro Clicked")
        performSegue(withIdentifier: "purchaseSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        profilePic.layer.cornerRadius = profilePic.bounds.height / 2
        profilePic.image = Items.sharedInstance.profilePic
        versionLabel.text = "Version " + ((Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String)!)
        versionLabel.isUserInteractionEnabled = true
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap))
        versionLabel.addGestureRecognizer(longGesture)
        nameChangeView.isHidden = true
        
        if Items.sharedInstance.purchased {
            self.proLabel.isHidden = false
            self.proButton.isHidden = true
        } else {
            self.proLabel.isHidden = true
            self.proButton.isHidden = false
        }
        
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        let docRef = Firestore.firestore().collection("Users").document(Items.sharedInstance.loggedIn)
        docRef.getDocument { (document, error) in
            if let error = error {
                self.logError(logString: "Settings VC - Error accessing User document", logError: error)
            } else {
                if let document = document, document.exists {
                    self.nameLabel.text = document.data()!["Name"] as? String
                    self.emailLabel.text = document.documentID
                } else {
                    self.logError(logString: "Settings VC - User Document Doesn't Exist")
                    let alertController = UIAlertController(title: "Error", message: "There was a problem accessing your information. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                    
                    
                    let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        Items.sharedInstance.loggedIn = ""
                        UserDefaults.standard.removeObject(forKey: "loggedIn")
                    }
                    
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updatePurchased), name:NSNotification.Name(rawValue: "purchased"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil
        )
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let bar = UIToolbar()
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        let save = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        bar.items = [cancel,save]
        bar.sizeToFit()
        nameChangeField.inputAccessoryView = bar
        
        hideKeyboardWhenTappedAround()
        
        Auth.auth().fetchSignInMethods(forEmail: Items.sharedInstance.loggedIn, completion: { (providers, error) in
            let myProviders = providers! as [String]
            if myProviders.contains("facebook.com") {
                self.dataArray[2] = "Disconnect Facebook Account"
            } else {
                self.dataArray[2] = "Connect App To Facebook"
            }
            
            if myProviders.contains("google.com") {
                self.dataArray[3] = "Disconnect Google Account"
            } else {
                self.dataArray[3] = "Connect App To Google"
            }
            self.settingsTable.reloadData()
        })
        
        for prov in Auth.auth().currentUser!.providerData {
            providers.append(prov.providerID)
        }
    }
    
    @objc func saveTapped() {
        let userRef = Firestore.firestore().collection("Users").document(Items.sharedInstance.loggedIn)
        userRef.updateData([
            "Name": nameChangeField.text!
        ]) { err in
            if let err = err {
                self.logError(logString: "Change Settings VC - Problem Updating Name", logError: err)
                let alertController = UIAlertController(title: "Error", message: "There was a problem saving your name. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                
                
                let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.nameLabel.text = self.nameChangeField.text
                self.nameChangeField.resignFirstResponder()
            }
        }
    }
    
    @objc func cancelTapped() {
        nameChangeField.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            textConstraint.constant = keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //nameChangeView.frame.origin.y = 0
        nameChangeField.text = ""
        textConstraint.constant = 0
        nameChangeView.isHidden = true
    }
    
    @objc func updatePurchased(notification: NSNotification){
        if Items.sharedInstance.purchased {
            self.proLabel.isHidden = false
            self.proButton.isHidden = true
        } else {
            self.proLabel.isHidden = true
            self.proButton.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.logError(logString: "In Settings VC")
        if AccessToken.current != nil {
            self.logError(logString: "Settings VC - Facebook Login: True")
            dataArray[2] = "Disconnect Facebook Account"
        } else {
            self.logError(logString: "Settings VC - Facebook Login: False")
            dataArray[2] = "Connect App To Facebook"
        }
        
        if GIDSignIn.sharedInstance()?.currentUser == nil {
            self.logError(logString: "Settings VC - Google Login: False")
            dataArray[3] = "Connect App To Google"
        } else {
           self.logError(logString: "Settings VC - Google Login: True")
            dataArray[3] = "Disconnect Google Account"
        }
        
        if Items.sharedInstance.purchased {
            self.proLabel.isHidden = false
            self.proButton.isHidden = true
        } else {
            self.proLabel.isHidden = true
            self.proButton.isHidden = false
        }
        
        let docRef2 = Firestore.firestore().collection("Users").document(Items.sharedInstance.loggedIn)
        docRef2.getDocument { (document2, error) in
            if let error = error {
                self.logError(logString: "Settings VC - Error Accessing User Document", logError: error)
            } else {
                if let document2 = document2, document2.exists {
                    self.nameLabel.text = document2.data()!["Name"] as? String
                } else {
                    self.logError(logString: "Settings VC - User Document Doesn't Exist")
                    let alertController = UIAlertController(title: "Error", message: "There was a problem accessing your information. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                    
                    
                    let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        Items.sharedInstance.loggedIn = ""
                        UserDefaults.standard.removeObject(forKey: "loggedIn")
                    }
                    
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
        }
        profilePic.image = Items.sharedInstance.profilePic
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section
        {
        case 0:
            return "Personal Information"
        case 1:
            return "Account Logins"
        default:
            return "App Data"
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let headerView = UIView(frame: CGRect(x: 0,y: 0,width: self.view.bounds.width,height: 40))
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: headerView.bounds.width, height: 21))
        let border = UIView(frame: CGRect(x: 0,y: 27,width: self.view.bounds.width,height: 0.5))
        
        switch section {
        case 0:
            title.text = "Personal Information"
        case 1:
            title.text = "Account Login"
        default:
            title.text = "App Data"
        }
         
        if #available(iOS 13.0, *) {
            headerView.backgroundColor = UIColor.secondarySystemGroupedBackground
            border.backgroundColor = UIColor.systemGray2
            title.textColor = UIColor.label
            title.font = UIFont.boldSystemFont(ofSize: 20)
        } else {
            headerView.backgroundColor = UIColor.black
            border.backgroundColor = UIColor.gray
            title.textColor = UIColor.white
            title.font = UIFont.boldSystemFont(ofSize: 20)
        }
        
        headerView.addSubview(border)
        headerView.addSubview(title)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0,y: 0,width: self.view.bounds.width,height: 10))
        if #available(iOS 13.0, *) {
            footerView.backgroundColor = UIColor.secondarySystemGroupedBackground
        } else {
            footerView.backgroundColor = UIColor.black
        }
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "loginCell", for: indexPath) as! LoginTableViewCell
        switch indexPath.section {
        case 0:
            cell.logo.image = logoArray[indexPath.row]
            cell.accountLabel.text = dataArray[indexPath.row]
        case 1:
            cell.logo.image = logoArray[indexPath.row + 2]
            cell.accountLabel.text = dataArray[indexPath.row + 2]
        default:
            cell.logo.image = logoArray[indexPath.row + 5]
            cell.accountLabel.text = dataArray[indexPath.row + 5]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                nameChangeView.isHidden = false
                nameChangeField.becomeFirstResponder()
            default:
                let alertController = UIAlertController(title: "Profile Picture", message: "Would you like to take a picture or upload one from your photo library?", preferredStyle: UIAlertController.Style.actionSheet)
                
                let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                }
                let library = UIAlertAction(title: "Photo Library", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        self.logError(logString: "Change Settings VC - Editing Picture From Photo Library")
                        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = self
                        imagePicker.sourceType = .photoLibrary;
                        imagePicker.allowsEditing = true
                        self.present(imagePicker, animated: true, completion: nil)
                    }
                }
                let camera = UIAlertAction(title: "Take Picture", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        self.logError(logString: "Change Settings VC - Editing Picture From Camera")
                        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = self
                        imagePicker.sourceType = .camera;
                        imagePicker.allowsEditing = true
                        self.present(imagePicker, animated: true, completion: nil)
                    }
                }
                
                alertController.addAction(camera)
                alertController.addAction(library)
                alertController.addAction(cancel)
                
                self.present(alertController, animated: true, completion: nil)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                if providers.contains("facebook.com") {
                //if AccessToken.current != nil {
                    self.logError(logString: "Settings VC - Logging Out Of Facebook")
                    Auth.auth().currentUser?.unlink(fromProvider: "facebook.com") { (user, error) in
                        if let error = error {
                            print("Couldn't remove facebook \(error.localizedDescription)")
                        } else {
                            print("Facebook removed")
                            LoginManager().logOut()
                            self.dataArray[2] = "Connect App To Facebook"
                            self.settingsTable.reloadData()
                        }
                    }
                } else {
                    let loginManager = LoginManager()
                    loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) {loginResult in
                        switch loginResult {
                        case .failed(let error):
                            self.logError(logString: "Settings VC - Facebook Login Failed", logError: error)
                            let alertController = UIAlertController(title: "Error", message: "Unable to login to Facebook. Please try again.", preferredStyle: UIAlertController.Style.alert)
                            
                            
                            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                Items.sharedInstance.loggedIn = ""
                                UserDefaults.standard.removeObject(forKey: "loggedIn")
                            }
                            
                            alertController.addAction(ok)
                            self.present(alertController, animated: true, completion: nil)
                        case .cancelled:
                            self.logError(logString: "Settings VC - Facebook Login Cancelled")
                        case .success:
                            self.logError(logString: "Settings VC - Facebook Login Succesfull")
                            
                            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                            Auth.auth().currentUser?.link(with: credential) { (authResult, error) in
                                // ...
                                if let error = error {
                                    print("Eror: \(error.localizedDescription)")
                                } else {
                                    print("Linked Facebook")
                                    self.dataArray[2] = "Disconnect Facebook Account"
                                    self.settingsTable.reloadData()
                                }
                            }
                        }
                    }
                }
            } else if indexPath.row == 1 {
                if !providers.contains("google.com") {
                //if GIDSignIn.sharedInstance()?.currentUser == nil {
                    GIDSignIn.sharedInstance().signIn()
                } else {
                   self.logError(logString: "Settings VC - Logging Out Of Google")
                    Auth.auth().currentUser?.unlink(fromProvider: "google.com") { (user, error) in
                        if let error = error {
                            print("Couldn't remove google \(error.localizedDescription)")
                        } else {
                            print("google removed")
                            GIDSignIn.sharedInstance()?.signOut()
                            self.dataArray[3] = "Connect App to Google"
                            self.settingsTable.reloadData()
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Signing Out", message: "Are you sure you want to sign out? This will remove all saved movies and predictions from this device", preferredStyle: UIAlertController.Style.alert)
                    
                    let local = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                    }
                    let account = UIAlertAction(title: "Sign Out", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        self.logError(logString: "Settings VC - Logging Out Of Application")
                        do {
                            try Auth.auth().signOut()
                        } catch let signOutError as NSError {
                            self.logError(logString: "Settings VC - Problem Logging Out of Auth", logError: signOutError)
                            let alertController = UIAlertController(title: "Error", message: "There was a problem signing out. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                            
                            
                            let ok = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                            }
                            
                            alertController.addAction(ok)
                            self.present(alertController, animated: true, completion: nil)
                        }
                        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                        UserDefaults.standard.synchronize()
                        Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                        Items.sharedInstance.loggedIn = String()
                        Items.sharedInstance.moviesSeenArray.removeAll()
                        Items.sharedInstance.movieArray.removeAll()
                        Items.sharedInstance.actorArray.removeAll()
                        LoginManager().logOut()
                        GIDSignIn.sharedInstance().signOut()
                        UserDefaults.standard.set(true, forKey: Items.sharedInstance.updateKey)
                        self.performSegue(withIdentifier: "signOutSegue", sender: self)
                    }
                    
                    alertController.addAction(local)
                    alertController.addAction(account)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.clearData(clear: indexPath.row)
            }
        }
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let editedImage = info[.editedImage] as? UIImage
        let originalImage = info[.originalImage] as? UIImage
        
        if editedImage != nil {
            memberImage = editedImage
            uploadImage()
        } else if originalImage != nil {
            memberImage = originalImage
            uploadImage()
        }
            
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadImage() {
        let userRef = Firestore.firestore().collection("Users").document(Items.sharedInstance.loggedIn)
        self.imageUploadManager.uploadImage(self.memberImage!, progressBlock: { [unowned self] (percentage) in
            }, completionBlock: { [unowned self] (fileURL, errorMessage) in
                if let fileURL = fileURL {
                    userRef.updateData([
                        "imageURL": fileURL.absoluteString
                    ]) { err in
                        if let err = err {
                            self.logError(logString: "Change Settings VC - Problem Updating Picture", logError: err)
                            let alertController = UIAlertController(title: "Error", message: "There was an error attempting to save picture", preferredStyle: UIAlertController.Style.alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                UIApplication.shared.endIgnoringInteractionEvents()
                            }
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            Items.sharedInstance.profilePic = memberImage
                            profilePic.image = memberImage
                            UIApplication.shared.endIgnoringInteractionEvents()
                        }
                    }
                }
        })
    }
    
    @objc func longTap() {
        let alertController = UIAlertController(title: "Error Reporting", message: "Would you like to email the developer with an error?", preferredStyle: UIAlertController.Style.actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
        }
        let email = UIAlertAction(title: "Email Logs", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            self.logError(logString: "Settings VC - Sending Logs via Email")
            self.sendMail()
        }
        
        alertController.addAction(email)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["dtjohnsonapps@gmail.com"])
            mail.setSubject("\(Items.sharedInstance.loggedIn) Log Files: \(Date())")
            mail.setMessageBody("<p>Please describe the issue in as much detail as possible. Pictures are highly recommended if available.</p>", isHTML: true)
            
            let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
            let url = dir.appendingPathComponent("logFile.txt")
            if let fileData = NSData(contentsOf: url)
            {
                print("File data loaded.")
                mail.addAttachmentData(fileData as Data, mimeType: "text/txt", fileName: "logFile.txt")
            }
            
            present(mail, animated: true)
        } else {
            // show failure alert
            self.logError(logString: "Settings VC - Unable to send email with Logs")
            let alertController = UIAlertController(title: "Error", message: "The email is unable to automatically send. Please send an email to 'dtjohnsonapps@gmail.com' to file an issue report.", preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    fileprivate func rateApp(appId: String) {
        openUrl("itms-apps://itunes.apple.com/app/" + appId)
    }
    
    fileprivate func openUrl(_ urlString:String) {
        let url = URL(string: urlString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        if let error = error {
            self.logError(logString: "Settings VC - Google Login Failed", logError: error)
            UIApplication.shared.endIgnoringInteractionEvents()
            let errorCode = (error as NSError).code
            if errorCode != -5 {
                self.errorManager.googleError(error: errorCode, completionBlock: {(title,showError,errorString) in
                    if showError {
                        self.callError(title: "Error", message: "We were unable to login via Google. Please try again")
                    }
                })
            }
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().currentUser?.link(with: credential) { (authResult, error) in
            if let error = error {
                self.logError(logString: "Settings VC - Unable to Authenticate via Google", logError: error)
                UIApplication.shared.endIgnoringInteractionEvents()
                self.signInError(error: error)
                GIDSignIn.sharedInstance()?.signOut()
            } else {
                self.logError(logString: "Settings VC - Logged in via Google succesfully")
                UIApplication.shared.endIgnoringInteractionEvents()
                self.dataArray[3] = "Disconnect Google Account"
                self.settingsTable.reloadData()
            }
        }
    }
    
    func clearData(clear: Int) {
        switch clear {
        case 0:
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to remove all your saved movies? This is irreversible", preferredStyle: UIAlertController.Style.alert)
            
            let local = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                
            }
            let account = UIAlertAction(title: "Remove", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                self.logError(logString: "Settings VC - Removing Saved Movies")
                
                UIApplication.shared.beginIgnoringInteractionEvents()
                UserDefaults.standard.removeObject(forKey: "LocalStorage")
                UserDefaults.standard.synchronize()
                Items.sharedInstance.moviesSeenArray.removeAll()
                
                let userRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(Items.sharedInstance.loggedIn)
                userRef.getDocument { (document, error) in
                    if let error = error {
                        self.logError(logString: "Settings VC - Unable to get User Document", logError: error)
                    } else {
                        if let document = document, document.exists {
                            userRef.updateData([
                                "movies": [String]()
                            ]) { err in
                                UIApplication.shared.endIgnoringInteractionEvents()
                                if let err = err {
                                    self.logError(logString: "Settings VC - Unable to update saved movies to document", logError: err)
                                    let alertController = UIAlertController(title: "Error", message: "There was a problem clearing the data. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                                    
                                    let account = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                        (result : UIAlertAction) -> Void in
                                        GIDSignIn.sharedInstance().signOut()
                                        return
                                    }
                                    
                                    alertController.addAction(account)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }
                        } else {
                            self.logError(logString: "Settings VC - User Document doesn't exist")
                            UIApplication.shared.endIgnoringInteractionEvents()
                            let alertController = UIAlertController(title: "Error", message: "There was a problem clearing the data. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                            
                            let account = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                GIDSignIn.sharedInstance().signOut()
                                return
                            }
                            
                            alertController.addAction(account)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
            
            alertController.addAction(local)
            alertController.addAction(account)
            self.present(alertController, animated: true, completion: nil)
        case 1:
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to remove all your predictions? This is irreversible", preferredStyle: UIAlertController.Style.alert)
            
            let local = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            let account = UIAlertAction(title: "Remove", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                self.logError(logString: "Settings VC - Removing Saved Predictions")
                
                UIApplication.shared.beginIgnoringInteractionEvents()
                UserDefaults.standard.removeObject(forKey: "Predictions")
                UserDefaults.standard.synchronize()
                Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                Items.sharedInstance.dataCleared = true
                
                let userRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(Items.sharedInstance.loggedIn)
                userRef.getDocument { (document, error) in
                    if let error = error {
                        self.logError(logString: "Settings VC - Unable to access User document", logError: error)
                    } else {
                        if let document = document, document.exists {
                            //Edit your document to be empty
                            userRef.updateData([
                                "Best Picture": "",
                                "Best Actor": "",
                                "Best Actress": "",
                                "Supporting Actor": "",
                                "Supporting Actress": "",
                                "Animated": "",
                                "Cinematography": "",
                                "Costume Design": "",
                                "Directing": "",
                                "Documentary Feature": "",
                                "Documentary Short": "",
                                "Film Editing": "",
                                "Foreign": "",
                                "Makeup": "",
                                "Music Song": "",
                                "Music Score": "",
                                "Production Design": "",
                                "Short Animated": "",
                                "Short Live": "",
                                "Sound Editing": "",
                                "Sound Mixing": "",
                                "Visual Effects": "",
                                "Writing Adapted": "",
                                "Writing Original": ""
                            ]) { err in
                                if let err = err {
                                    self.logError(logString: "Settings VC - Unable to update User Predictions", logError: err)
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    let alertController = UIAlertController(title: "Error", message: "There was a problem clearing the data. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                                    
                                    let account = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                        (result : UIAlertAction) -> Void in
                                        GIDSignIn.sharedInstance().signOut()
                                        return
                                    }
                                    
                                    alertController.addAction(account)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                                UIApplication.shared.endIgnoringInteractionEvents()
                            }
                        } else {
                            self.logError(logString: "Settings VC - User Document Doesn't Exist")
                            UIApplication.shared.endIgnoringInteractionEvents()
                            let alertController = UIAlertController(title: "Error", message: "There was a problem clearing the data. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                            
                            let account = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                GIDSignIn.sharedInstance().signOut()
                                return
                            }
                            
                            alertController.addAction(account)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
            
            alertController.addAction(local)
            alertController.addAction(account)
            self.present(alertController, animated: true, completion: nil)
        default:
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to remove all saved data? This is irreversible", preferredStyle: UIAlertController.Style.alert)
            
            let local = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            let account = UIAlertAction(title: "Remove", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                self.logError(logString: "Settings VC - Removing All Data")
                
                UIApplication.shared.beginIgnoringInteractionEvents()
                UserDefaults.standard.removeObject(forKey: "LocalStorage")
                UserDefaults.standard.removeObject(forKey: "Predictions")
                UserDefaults.standard.synchronize()
                Items.sharedInstance.predictions = [String](repeating: "", count: 24)
                Items.sharedInstance.moviesSeenArray.removeAll()
                Items.sharedInstance.dataCleared = true
                
                let userRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(Items.sharedInstance.loggedIn)
                userRef.getDocument { (document, error) in
                    if let error = error {
                        self.logError(logString: "Settings VC - Error Accessing User Document", logError: error)
                    } else {
                        if let document = document, document.exists {
                            let friends = document.data()!["Friends"] as! [String]
                            
                            //Cycle through every friend and remove your name from their list
                            for item in friends {
                                let friendRef = Firestore.firestore().collection(Items.sharedInstance.userMovieListYear).document(item)
                                friendRef.getDocument { (document, error) in
                                    if let error = error {
                                        self.logError(logString: "Settings VC - Unable to get friend document. (Friend: \(item))", logError: error)
                                    } else {
                                        if let document = document, document.exists {
                                            var theirFreinds = document.data()!["Friends"] as! [String]
                                            for (index,friend) in theirFreinds.enumerated() {
                                                if friend == Items.sharedInstance.loggedIn {
                                                    theirFreinds.remove(at: index)
                                                }
                                            }
                                            friendRef.updateData([
                                                "Friends": theirFreinds
                                            ]) { err in
                                                if let err = err {
                                                    self.logError(logString: "Settings VC - Error Updating Friends Document. (Friend: \(item))", logError: err)
                                                    UIApplication.shared.endIgnoringInteractionEvents()
                                                    let alertController = UIAlertController(title: "Error", message: "There was a problem clearing the data. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                                                    
                                                    let account = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                                        (result : UIAlertAction) -> Void in
                                                        GIDSignIn.sharedInstance().signOut()
                                                        return
                                                    }
                                                    
                                                    alertController.addAction(account)
                                                    self.present(alertController, animated: true, completion: nil)
                                                }
                                                UIApplication.shared.endIgnoringInteractionEvents()
                                            }
                                        } else {
                                            self.logError(logString: "Settings VC - Friend Document Doesn't Exist (Friend: \(item))")
                                        }
                                    }
                                }
                            }
                            
                            //Edit your document to be empty
                            userRef.updateData([
                                "movies": [String](),
                                "Best Picture": "",
                                "Best Actor": "",
                                "Best Actress": "",
                                "Supporting Actor": "",
                                "Supporting Actress": "",
                                "Animated": "",
                                "Cinematography": "",
                                "Costume Design": "",
                                "Directing": "",
                                "Documentary Feature": "",
                                "Documentary Short": "",
                                "Film Editing": "",
                                "Foreign": "",
                                "Makeup": "",
                                "Music Song": "",
                                "Music Score": "",
                                "Production Design": "",
                                "Short Animated": "",
                                "Short Live": "",
                                "Sound Editing": "",
                                "Sound Mixing": "",
                                "Visual Effects": "",
                                "Writing Adapted": "",
                                "Writing Original": "",
                                "Invitations": [String](),
                                "Friends": [String]()
                            ]) { err in
                                if let err = err {
                                    self.logError(logString: "Settings VC - Error Updating User Document", logError: err)
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    let alertController = UIAlertController(title: "Error", message: "There was a problem clearing the data. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                                    
                                    let account = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                        (result : UIAlertAction) -> Void in
                                        GIDSignIn.sharedInstance().signOut()
                                        return
                                    }
                                    
                                    alertController.addAction(account)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                                UIApplication.shared.endIgnoringInteractionEvents()
                            }
                            
                        } else {
                            self.logError(logString: "Settings VC - User Document Doesn't Exist")
                            UIApplication.shared.endIgnoringInteractionEvents()
                            let alertController = UIAlertController(title: "Error", message: "There was a problem clearing the data. Please quit the app and try again.", preferredStyle: UIAlertController.Style.alert)
                            
                            let account = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                                (result : UIAlertAction) -> Void in
                                GIDSignIn.sharedInstance().signOut()
                                return
                            }
                            
                            alertController.addAction(account)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
            
            alertController.addAction(local)
            alertController.addAction(account)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func logError(logString: String, logError: Error? = nil) {
        if logError != nil {
            do {
                let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                let url = dir.appendingPathComponent("logFile.txt")
                try logString.appendLine(to: url as URL)
            }
            catch {
                print("Could not write to file")
            }
        } else {
            do {
                let dir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
                let url = dir.appendingPathComponent("logFile.txt")
                try logString.appendLine(to: url as URL)
                try String(describing: logError).appendLine(to: url as URL)
            }
            catch {
                print("Could not write to file")
            }
        }
    }
    
    func signInError(error: Error) {
        if let errorCode = AuthErrorCode(rawValue: error._code){
            if errorCode == .emailAlreadyInUse {
                self.logError(logString: "Login VC - User is trying to sign into an email already used", logError: error)
                let errorEmail = (error as NSError).userInfo["FIRAuthErrorUserInfoEmailKey"] as! String
                Auth.auth().fetchSignInMethods(forEmail: errorEmail, completion: { (providers, error) in
                    let myProviders = providers! as [String]
                    let providerCount = myProviders.count
                    if providerCount == 1 {
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let provider = myProviders[0].components(separatedBy: ".")[0]
                        let message = "You have previously signed in with \(provider). Please sign in with that provider."
                        self.callError(title: "Sign In Error", message: message)
                    } else {
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let provider1 = myProviders[0].components(separatedBy: ".")[0]
                        let provider2 = myProviders[1].components(separatedBy: ".")[0]
                        let message = "You have previously signed in with \(provider1) and \(provider2). Please sign in with one of those providers."
                        self.callError(title: "Sign In Error", message: message)
                    }
                })
            } else {
                self.logError(logString: "Login VC - Login Error", logError: error)
                self.errorManager.firestoreError(error: errorCode, completionBlock: {(title,showError,errorString) in
                    if showError {
                        self.callError(title: title, message: errorString)
                    }
                })
            }
        }
    }
    
    func callError(title: String, message: String) {
        UIApplication.shared.endIgnoringInteractionEvents()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
         (result : UIAlertAction) -> Void in
         return }

        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
