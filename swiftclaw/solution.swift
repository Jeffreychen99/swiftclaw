//
//  solution.swift
//  swiftclaw
//
//  Created by Jeffrey Chen on 8/10/16.
//  Copyright (c) 2016 Jeffrey Chen. All rights reserved.
//

import Foundation

class Solution
{
    var num_eqn: Int
    var gridCells: Int
    
    var x_lower: Double
    var dx: Double
    var time: Double
    var x_upper: Double
    
    var q: [[Double]]
    var aux: [Double] = []
    
    
    init(n: Int, i: Int, x: Double, x_space: Double, t: Double, method: (Double)->Double)
    {
        num_eqn = n
        gridCells = i
        x_lower = x
        dx = x_space
        time = t
        x_upper = Double(x_lower) + (Double(dx) * Double(gridCells))
        
        q = [[Double]](count: n, repeatedValue: [])
        for index1 in 0 ..< num_eqn
        {
            var temp = [Double](count: i, repeatedValue: Double())
            for index2 in 0 ..< i
            {
                temp[index2] = method(Double(index2)*x_space + x)
            }
            q[index1] = temp
        }
    }
    
    func writeToFile(frame: Int)
    {
        var fileNameQ = "fort.q"
        var fileNameT = "fort.t"
        var fileNumber = ""
        
        print(NSBundle.mainBundle().executablePath)
        
        if(frame < 10)
        {
            fileNumber += "000"
        }
        else if(frame < 100)
        {
            fileNumber += "00"
        }
        else if(frame < 1000)
        {
            fileNumber += "0"
        }
        fileNumber += String(frame)
        fileNameQ += fileNumber
        fileNameT += fileNumber
        
        let pathQ = "~/Desktop/swiftclaw/numerical_output/" + fileNameQ     // swiftclaw directory has to be on desktop
        let pathT = "~/Desktop/swiftclaw/numerical_output/" + fileNameT     // swiftclaw directory has to be on desktop
        
        let locationQ = NSString(string: pathQ).stringByExpandingTildeInPath
        let locationT = NSString(string: pathT).stringByExpandingTildeInPath
        
        var qWritten = "1          patch_number \n"
        qWritten += "1          AMR_level\n"
        qWritten += "\(gridCells)       mx\n"
        qWritten += "\(x_lower)         xlow\n"
        qWritten += "\(dx)              dx\n \n"
        for i in 0 ..< gridCells
        {
            for j in 0 ..< equations
            {
                qWritten += NSString(format: "%e", q[j][i]) as String
                qWritten += "   "
            }
            qWritten += "\n"
        }
        do {
            try qWritten.writeToFile(locationQ, atomically: true, encoding: NSUTF8StringEncoding)
        } catch _ {
        }
        
        var tWritten = ""
        tWritten += NSString(format: "%e", time) as String
        tWritten += "          time\n"
        tWritten += "\(num_eqn)          num_eqn\n"
        tWritten += "1             numstates\n"
        tWritten += "\(aux.count)              num_aux\n"
        tWritten += "1              num_dim\n \n"
        do {
            try tWritten.writeToFile(locationT, atomically: true, encoding: NSUTF8StringEncoding)
        } catch _ {
        }
        
    }
}
