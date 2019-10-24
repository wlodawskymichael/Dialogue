//
//  Loading.swift
//  Dialogue
//
//  Created by Sahil Parikh on 10/23/19.
//  Copyright © 2019 CS371L. All rights reserved.
//

import Foundation
import KVLoading

class Loading {
    static func show() {
        KVLoading.shared.show()
    }
    
    static func hide() {
        KVLoading.shared.hide()
    }
    
    
    static func mockLoading(wait: Double, closure: () -> Void) {
        Loading.show()
        let timer = Timer.scheduledTimer(withTimeInterval: wait, repeats: false) {timer in
            Loading.hide()
        }
        timer.fire()
    }
}
