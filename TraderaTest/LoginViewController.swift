//
//  LoginViewController.swift
//  TraderaTest
//
//  Created by Iggy Drougge on 2016-06-16.
//  Copyright © 2016 Iggy Drougge. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        webView.delegate=self
        let url=NSURL(string: TraderaService.loginURL)
        let req=NSURLRequest(URL: url!)
        webView.loadRequest(req)
        //print(webView.url)
    }
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("shouldStartLoadWithRequest: \(request) navigationType: \(String(navigationType.rawValue))")
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

}
