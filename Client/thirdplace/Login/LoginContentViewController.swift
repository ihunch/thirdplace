//
//  LoginContentViewController.swift
//  thirdplace
//
//  Created by Yang Yu on 24/12/2015.
//  Copyright © 2015 Hunch Pty Ltd. All rights reserved.
//

import UIKit

class LoginContentViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    var pageIndex: Int = 0
    var imageFile: String?
    var titletext: String?
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.titleLabel.text = titletext
        self.imageview.image = UIImage(named: imageFile!)
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
