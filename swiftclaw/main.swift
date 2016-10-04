//
//  main.swift
//  swiftclaw
//
//  Created by Jeffrey Chen on 8/10/16.
//  Copyright (c) 2016 Jeffrey Chen. All rights reserved.
//

import Foundation

var equations = 1
var gridCells = 100
var x_lower = 0.0
var dx = 1.0
var time = 0.0

var adv_spd = 1.0
var impedence = 2.0
var sound_spd = 3.0
var entropy_fix = 1.0

var problem_data: [String: Double] = ["u": adv_spd, "zz": impedence, "cc": sound_spd, "efix": entropy_fix]

func f(_ x: Double) -> Double
{
    return sin(x / 25.0)
}

var solution = Solution(n: equations, i: gridCells, x: x_lower, x_space: dx, t: time, method: f)

var num_steps = 20
var stepString = String(num_steps)
let path = "~/Desktop/swiftclaw/num_steps.txt"     // swiftclaw directory has to be on desktop
do {
    try stepString.write(toFile: NSString(string: path).expandingTildeInPath, atomically: true, encoding: String.Encoding.utf8)
} catch _ {
}

solution.writeToFile(0)
for i in 1 ..< num_steps
{
    step(solution, dt: 0.8, num_ghost: 2, problem_data: problem_data, solver_method: advection_1d)
    solution.writeToFile(i)
}
