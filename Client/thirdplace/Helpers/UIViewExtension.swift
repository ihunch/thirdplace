//
//  UIViewExtension.swift
//  thirdplace
//
//  Created by Yang Yu on 5/02/2016.
//  Copyright © 2016 Hunch Pty Ltd. All rights reserved.
//

import Foundation

extension UIView {
    func makeCircular() {
        let cntr:CGPoint = self.center
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.center = cntr
    }
}