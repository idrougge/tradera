//
//  LoginViewController.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-06-16.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import UIKit

class WebLoginViewController: UIViewController, UIWebViewDelegate {
    
    var parent:LoginViewController?
    var session:TraderaSession?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        webView.delegate=self
        let url=NSURL(string: TraderaService.loginURL)
        let req=NSURLRequest(URL: url!)
        webView.loadRequest(req)
        //print(webView.url)
        print("parent.username=\(parent?.username)")
    }
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("shouldStartLoadWithRequest: \(request) navigationType: \(String(navigationType.rawValue))")
        if request.mainDocumentURL?.host == "127.0.0.1" {
            print("URL pekar på localhost")
            print("mainDocumentURL: \(request.mainDocumentURL)")
            print("baseURL: \(request.mainDocumentURL?.baseURL)")
            print("lastPathComponent: \(request.mainDocumentURL?.lastPathComponent)")
            print("parameterString: \(request.mainDocumentURL?.parameterString)")
            print("query: \(request.mainDocumentURL?.query)")
            var user=[String:String]()
            if let params=NSURLComponents(string: request.mainDocumentURL!.absoluteString)?.queryItems {
                print("params: \(params)")
                //var user=[String:String]()
                //params.map{print("params.map: \($0.name) = \($0.value)")}
                params.map{user[$0.name]=$0.value}
                print("user=\(user)")
                for bla:NSURLQueryItem in params {
                    print("bla.name=\(bla.name), bla.value=\(bla.value)")
                }
                for blö:NSURLQueryItem in params {
                    switch (blö.name,blö.value) {
                    case ("userId", let id) where Int(id!) != nil:
                        print("id=\(id)")
                    case ("token", let token):
                        print("token=\(token)")
                        TraderaSession.token=token
                    default:
                        break
                    }
                }
                //if let token=user["token"], let id=user["userId"] {
                guard let token=user["token"], id=user["userId"]
                    else {print("Kunde inte hämta ut token och id!");webView.stopLoading();return false}
                    TraderaSession.token=token
                    //TraderaSession.authid=id
                    session!.notifications.addObserver(self, selector: #selector(gotUser), name: TraderaService.notifications.gotUserInfo.rawValue, object: nil)
                    let _=TraderaService.URLConnection(message: session!.service.getUserInfo(Int(id)!), action: "\"http://api.tradera.com/GetUserInfo\"", session: session!, url: TraderaService.restrictedServiceURL)
                //}
            }
            webView.stopLoading()
            webView.loadHTMLString("<h1>Stopp!</h1>", baseURL: nil)
        }
        switch navigationType {
        case .FormSubmitted: print("formsubmitted")
        case .LinkClicked: print("linkclicked")
        case .FormResubmitted: print("FormResubmitted")
        case .BackForward: print("BackForward")
        case .Other: print("Other")
        default: print("Okänd navigation")
        }
        print("pageCount: \(webView.pageCount)")
        return true
    }
    
    func gotUser(notification:NSNotification) {
        print("WebLoginViewController.gotUser()")
        if let user = notification.object as? TraderaUser {
            print("Identifierade användare: \(user)")
            TraderaSession.user=user
            let alert=UIAlertController(title: "Bekräftade identitet",
                                        message: "Användare: \(TraderaSession.user?.name)\nEpost: \(TraderaSession.user?.email)\nTelefon: \(TraderaSession.user?.mobile)",
                                        preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK",
                style: UIAlertActionStyle.Default,
                handler: {_ in
                    self.navigationController?.popViewControllerAnimated(true)}))
            presentViewController(alert, animated: true, completion: nil)

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func done(sender: AnyObject) {
        print("Done")
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("viewWillDisappear(animated: \(animated))")
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("prepareForSegue(segue: \(segue.identifier))")
    }
}
