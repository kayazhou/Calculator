//
//  Utility.swift
//  Calculator
//
//  Created by He Zhou on 9/5/20.
//  Copyright © 2020 HMK. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Utility {
    var ref: DatabaseReference = Database.database().reference()
    var databaseHandle:DatabaseHandle!

    func save(input: String) {
        var date = ""
        var interval = ""
        (date, interval) = getDateString()
        ref.child("record").child(interval).setValue(["content":input, "date":date])
    }

    func fetchAllRecords(completion: @escaping([String: AnyObject]) -> Void) {
        ref.child("record").observeSingleEvent(of: .value, with: { (snapshot) in
            let postDict = (snapshot.value as? [String: AnyObject])!
            completion(postDict)
        })
    }
    
    func getDateString() -> (String, String) {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"
        let date = Date()
        let now = df.string(from: date)
        let inter = Int64(date.timeIntervalSince1970 * 1000)
        return (now, String(inter))
    }
}
