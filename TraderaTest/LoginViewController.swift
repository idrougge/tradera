//
//  LoginViewController.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-08-29.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var button: UIButton!
    var session:TraderaSession?
    var username:String=""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        session?.notifications.addObserver(self, selector: #selector(gotUser), name: TraderaService.notifications.gotUserByAlias.rawValue, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressButton(sender: AnyObject) {
        username=textfield.text!
        print("didPressButton: \(username)")
        //let userid=session?.service.getUserByAlias()
        let _=TraderaService.URLConnection(message: session!.service.getUserByAlias(username), action: "\"http://api.tradera.com/GetUserByAlias\"", session: session!, url: TraderaService.publicServiceURL)
        let _=TraderaService.URLConnection(message: session!.service.fetchToken(), action: "\"http://api.tradera.com/FetchToken\"", session: session!, url: TraderaService.publicServiceURL)
        
    }
    
    func gotUser(notification:NSNotification) {
        print("gotUser()")
        if let user=notification.object as? TraderaUser
        {
            print("gotUser.user = \(user)")
            //session!.user=user
            TraderaSession.user=user
            textfield.text="\(user.username) (\(user.id))"
        }
    }
    
    func fetchToken() {
        let tokenxml=session?.service.fetchToken()
        print("fetchToken: \(tokenxml)")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("segue till: \(segue.destinationViewController)")
        if let vc=segue.destinationViewController as? WebLoginViewController {
            print("prepareForSegue: Hoppar till Traderas webbinloggning")
            vc.parent=self
            vc.session=session
        }
    }

}
