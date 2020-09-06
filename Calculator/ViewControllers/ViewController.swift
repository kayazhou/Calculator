//
//  ViewController.swift
//  Calculator
//
//  Created by He Zhou on 9/5/20.
//  Copyright © 2020 HMK. All rights reserved.
//

import UIKit
import FirebaseDatabase

enum Operator {
    case addition
    case Subtraction
    case multiplication
    case division
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showLable: UILabel!
    var ref: DatabaseReference = Database.database().reference()
    let utility = Utility.init()
    var dataSource: [String] = []

    var firstNumber: Double = 0.0
    var secondNumber: Double = 0.0
    var firstString: String = "0"
    var secondString: String = "0"

    var stringToSave: String = ""

    var currentState = 0 // 0 is new start, 1 is number, 2 is operator
    var operatorFlag: Operator = Operator.addition

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CELL")

        utility.fetchAllRecords { (result) in
            let arr = result.sorted{ $0.key < $1.key}
            self.dataSource = []
            for (_, value) in arr {
                let item = value as? [String: Any]
                self.dataSource.append(item!["content"] as! String)
            }
            self.tableView.reloadData()
        }

        ref.observe(DataEventType.childChanged) { (snapshot) in
            self.ref.child("record").observeSingleEvent(of: .value, with: { (snapshot) in
                let postDict = (snapshot.value as? [String: AnyObject])!
                let arr = postDict.sorted{ $0.key < $1.key}
                self.dataSource = []
                for (_, value) in arr {
                    let item = value as? [String: Any]
                    self.dataSource.append(item!["content"] as! String)
                }
                self.tableView.reloadData()
                print(self.dataSource)
            })
        }
    }

    @IBAction func numberTap(sender: UIButton) {
        let title = sender.currentTitle!

        if currentState == 1 { // last input is number
            secondString.append(title)
            secondNumber = Double(secondString)!
            showLable.text = String(secondNumber)
        } else if currentState == 0 { // start new one
            firstString = ""
            firstNumber = 0
            secondNumber = 0
            secondString = ""
            secondString.append(title)
            secondNumber = Double(secondString)!
            showLable.text = String(secondNumber)
        } else {
            // Add calulator sign
            switch operatorFlag {
            case .addition:
                stringToSave.append("+")
            case .Subtraction:
                stringToSave.append("-")
            case .multiplication:
                stringToSave.append("×")
            case .division:
                stringToSave.append("÷")
            }
            secondString = ""
            secondString.append(title)
            secondNumber = Double(secondString)!
            showLable.text = String(secondNumber)
        }
        currentState = 1
    }

    @IBAction func operatorTap(sender: UIButton) {
        print("currentState is \(currentState)")
        if currentState != 0 {
            if currentState == 1 { // last time is number
                stringToSave.append(String(Double(secondString)!))
                // Calculate last number
                print("operator flag \(operatorFlag)")
                print("1 firstnumber \(firstNumber)  secondnumber \(secondNumber) operator \(operatorFlag)")
                switch operatorFlag {
                case .addition:
                    firstNumber = firstNumber + secondNumber
                case .Subtraction:
                    firstNumber = firstNumber - secondNumber
                case .multiplication:
                    firstNumber = firstNumber * secondNumber
                case .division:
                    firstNumber = firstNumber / secondNumber
                }
                showLable.text = String(firstNumber)
            }

            // Set current operatorFlag
            let title = sender.currentTitle!
            switch title {
            case "+" : operatorFlag = Operator.addition
            case "-" : operatorFlag = Operator.Subtraction
            case "×" : operatorFlag = Operator.multiplication
            case "÷" : operatorFlag = Operator.division
            default: break
            }
            // Save current state
            currentState = 2
        }

        print("2 firstnumber \(firstNumber)  secondnumber \(secondNumber) operator \(operatorFlag)")
    }

    @IBAction func calculateTap(sender: UIButton) {
        if currentState != 0 {

            print("String is \(stringToSave)")
            secondNumber = Double(secondString)!
            if currentState != 2 {
                // Calculate last number
                switch operatorFlag {
                case .addition:
                    firstNumber = firstNumber + secondNumber
                case .Subtraction:
                    firstNumber = firstNumber - secondNumber
                case .multiplication:
                    firstNumber = firstNumber * secondNumber
                case .division:
                    firstNumber = firstNumber / secondNumber
                }
                stringToSave.append(String(Double(secondString)!))
            }
            firstString = String(firstNumber)
            stringToSave.append("=")
            stringToSave.append(String(Double(firstString)!))
            showLable.text = firstString
            currentState = 0
            operatorFlag = .addition
            utility.save(input: stringToSave)
            stringToSave = ""
        }

    }

    @IBAction func clearTap(sender: UIButton) {
        stringToSave = ""
        firstString = ""
        firstNumber = 0
        secondNumber = 0
        secondString = "0"
        showLable.text = secondString
        currentState = 0
    }

}

extension ViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count > 10 ? 10 : dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)

        cell.textLabel?.text = dataSource[dataSource.count-indexPath.row-1]

        return cell
    }

}
