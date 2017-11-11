//
//  main.swift
//  ReportParser
//
//  Created by James on 11/11/2017.
//  Copyright © 2017 James. All rights reserved.
//

import Foundation

let productIdentifier = "mv08-jsm" // CommandLine.arguments[1]
let curDir = FileManager.default.currentDirectoryPath

let reportPath = curDir + "/financial_report.csv"
let report = try! String(contentsOfFile: reportPath)
let array = report.components(separatedBy: "\n")
let coloumnTitles = array[2].components(separatedBy: ",")
let exchangeIndex = (coloumnTitles.index(where: { $0 == "Exchange Rate"})!)

var exchangeRates = [String: Double]()
for i in 3..<array.count {
    let row = array[i]
    let cols = row.components(separatedBy: ",")
    
    if cols.first?.isEmpty == true { break }
    
    let num = cols[exchangeIndex].replacingOccurrences(of: "\"", with: "")
    exchangeRates[cols[0]] = Double(num)
}

let summaryFile = try! String(contentsOfFile: curDir + "/Summary.csv")
var fileNameStrings = summaryFile.components(separatedBy: "\n")
fileNameStrings.removeFirst()

var fileNames = [String: String]()

for s in fileNameStrings {
    let com = s.components(separatedBy: ",")
    if com.count == 2 {
        var file = com[1].replacingOccurrences(of: "\t", with: "")
        file = file.replacingOccurrences(of: ".gz", with: "")
        fileNames[com[0]] = file
    }
}

var total = 0.0

for (region, fileName) in fileNames {
    
    let file = try! String(contentsOfFile: curDir + "/" + fileName)
    var rows = file.components(separatedBy: "\n")
    
    let firstRow = rows.removeFirst()
    let identifierIndex = firstRow.components(separatedBy: "\t").index(of: "Vendor Identifier")!
    let shareIndex = firstRow.components(separatedBy: "\t").index(of: "Extended Partner Share")!
    
    rows.removeLast(4)
    
    for row in rows {
        let cols = row.components(separatedBy: "\t")
        if cols[identifierIndex] == productIdentifier {
            let exRate = exchangeRates[region]!
            let amount = Double(cols[shareIndex])! * exRate
            total += amount
        }
    }
}

print("total: \(round(total))")


