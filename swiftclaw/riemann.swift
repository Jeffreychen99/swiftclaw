//
//  riemann.swift
//  swiftclaw
//
//  Created by Jeffrey Chen on 8/10/16.
//  Copyright (c) 2016 Jeffrey Chen. All rights reserved.
//

import Foundation
import Darwin
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


struct arrayGroup
{
    var wave: [[[Double]]]
    var s: [[Double]]
    var amdq: [[Double]]
    var apdq: [[Double]]
    
    init(aTemp: [[[Double]]], bTemp: [[Double]], cTemp: [[Double]], dTemp: [[Double]])
    {
        wave = aTemp
        s = bTemp
        amdq = cTemp
        apdq = dTemp
    }
}


func advection_1d(_ q_l: [[Double]], q_r: [[Double]], aux_l: [Double], aux_r: [Double], problem_data: [String: Double]) -> arrayGroup
{
    let num_eqn = 1
    let num_waves = 1
    
    // Number of Riemann Problems we are solving
    let num_rp = q_l[0].count
    
    // Return values
    var wave = [[[Double]]](repeating: [[Double]](repeating: [Double](repeating: Double(), count: num_rp), count: num_waves), count: num_eqn)
    var s = [[Double]](repeating: [Double](repeating: Double(), count: num_rp), count: num_eqn)
    var amdq = [[Double]](repeating: [Double](repeating: 0.0, count: num_rp), count: num_eqn)
    var apdq = [[Double]](repeating: [Double](repeating: 0.0, count: num_rp), count: num_eqn)
    
    for i in 0 ..< wave[0][0].count
    {
        wave[0][0][i] = q_r[0][i] - q_l[0][i]
        s[0][i] = problem_data["u"]!
    }
    
    if(problem_data["u"] > 0)
    {
        for i in 0 ..< apdq[0].count
        {
            apdq[0][i] = s[0][i] * wave[0][0][i]
        }
    }
    else
    {
        for i in 0 ..< amdq[0].count
        {
            amdq[0][i] = Double(s[0][i]) * wave[0][0][i]
        }
    }
    
    return arrayGroup(aTemp: wave, bTemp: s, cTemp: amdq, dTemp: apdq)
}






func acoustics_1d(_ q_l: [[Double]], q_r: [[Double]], aux_l: [Double], aux_r: [Double], problem_data: [String: Double]) -> arrayGroup
{
    let num_eqn = 2
    let num_waves = 2
    
    // Number of Riemann Problems we are solving
    let num_rp = q_l[0].count
    
    // Return values
    var wave = [[[Double]]](repeating: [[Double]](repeating: [Double](repeating: Double(), count: num_rp), count: num_waves), count: num_eqn)
    var s = [[Double]](repeating: [Double](repeating: Double(), count: num_rp), count: num_eqn)
    var amdq = [[Double]](repeating: [Double](repeating: Double(), count: num_rp), count: num_eqn)
    var apdq = [[Double]](repeating: [Double](repeating: Double(), count: num_rp), count: num_eqn)
    
    // Local values
    var delta = [[Double]](repeating: [Double](repeating: Double(), count: q_r[0].count), count: q_r.count)
    for i in 0 ..< delta.count
    {
        for j in 0 ..< delta[0].count
        {
            delta[i][j] = q_r[i][j] - q_l[i][j]
        }
    }
    
    var a1 = [Double](repeating: Double(), count: delta[0].count)
    var a2 = [Double](repeating: Double(), count: delta[0].count)

    for i in 0 ..< a1.count
    {
        a1[i] = (-delta[0][i] + problem_data["zz"]!*delta[1][i]) / (2.0 * problem_data["zz"]!)
        a2[i] = (delta[0][i] + problem_data["zz"]!*delta[1][i]) / (2.0 * problem_data["zz"]!)
    }
    
    // Compute the waves
    // 1-Wave
    for i in 0 ..< wave[0][0].count
    {
        wave[0][0][i] = -a1[i] * problem_data["zz"]!
        wave[1][0][i] = a1[i]
        s[0][i] = -problem_data["cc"]!
    }
    
    // 2-Wave
    for i in 0 ..< wave[0][0].count
    {
        wave[0][1][i] = -a2[i] * problem_data["zz"]!
        wave[1][1][i] = a2[i]
        s[1][i] = -problem_data["cc"]!
    }
    
    // Compute the left going and right going fluctuation
    for m in 0 ..< num_eqn
    {
        for i in 0 ..< amdq[0].count
        {
            amdq[m][i] = s[0][i] * wave[m][0][i]
            apdq[m][i] = s[1][i] * wave[m][1][i]
        }
    }
    
    return arrayGroup(aTemp: wave, bTemp: s, cTemp: amdq, dTemp: apdq)
}






func burgers_1d(_ q_l: [[Double]], q_r: [[Double]], aux_l: [Double], aux_r: [Double], problem_data: [String: Double]) -> arrayGroup
{
    let num_eqn = 1
    let num_waves = 1
    
    // Number of Riemann Problems we are solving
    let num_rp = q_l[0].count
    
    // Output arrays
    var wave = [[[Double]]](repeating: [[Double]](repeating: [Double](repeating: Double(), count: num_rp), count: num_waves), count: num_eqn)
    var s = [[Double]](repeating: [Double](repeating: Double(), count: num_rp), count: num_eqn)
    var amdq = [[Double]](repeating: [Double](repeating: Double(), count: num_rp), count: num_eqn)
    var apdq = [[Double]](repeating: [Double](repeating: Double(), count: num_rp), count: num_eqn)
    
    // Basic solve
    for i in 0 ..< wave[0].count
    {
        for j in 0 ..< wave[0][i].count
        {
            wave[0][i][j] = q_r[i][j] - q_l[i][j]
        }
    }
    for i in 0 ..< s[0].count
    {
        s[0][i] = 0.5 * (q_r[0][i]+q_l[0][i])
    }
    
    var s_index = [[Double]](repeating: [Double](repeating: 0.0, count: num_rp), count: 2)
    for i in 0 ..< s[0].count
    {
        s_index[0][i] = s[0][i]
    }
    
    for i in 0 ..< wave[0][0].count
    {
        if(s_index[0][i] < 0.0)
        {
            amdq[0][i] = s_index[0][i] * wave[0][0][i]
            apdq[0][i] = 0.0
        }
        else
        {
            amdq[0][i] = 0.0
            apdq[0][i] = s_index[0][i] * wave[0][0][i]
        }
    }
    
    // Compute entropy fix
    if(problem_data["efix"] == 1.0)
    {
        //var transonic = [
    }
    
    
    return arrayGroup(aTemp: wave, bTemp: s, cTemp: amdq, dTemp: apdq)
}




