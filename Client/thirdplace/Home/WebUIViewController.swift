//
//  WebUIViewController.swift
//  thirdplace
//
//  Created by Yang Yu on 5/02/2016.
//  Copyright © 2016 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class WebUIViewController: UIViewController,UIWebViewDelegate
{
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func refresh(sender: AnyObject) {
        webview.reload()
    }
    
    @IBOutlet weak var webview: UIWebView!

    override func viewDidLoad()
    {
        let url = NSURL(string: AppConfig.thirdplaceReportURL())
        let request = NSURLRequest(URL: url!)
        self.webview.loadRequest(request)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        return true
    }

    func webView(webView: UIWebView, didFailLoadWithError error: NSError?)
    {
        ErrorHandler.showPopupMessage(self.view, text: "Cannot load the report page, try again later")
    }

}
