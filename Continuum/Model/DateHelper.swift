//
//  DateHelper.swift
//  Continuum
//
//  Created by Kaden Hendrickson on 6/5/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

extension Date {
    
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }
}
