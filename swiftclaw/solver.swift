//
//  solver.swift
//  swiftclaw
//
//  Created by Jeffrey Chen on 8/10/16.
//  Copyright (c) 2016 Jeffrey Chen. All rights reserved.
//

import Foundation

func step(_ sol: Solution, dt: Double, num_ghost: Int, problem_data: [String: Double], solver_method: ([[Double]], [[Double]], [Double], [Double], [String: Double]) -> arrayGroup)
{
    
    var q_bc = [[Double]](repeating: [], count: sol.q.count)
    for i in 0 ..< sol.q.count
    {
        q_bc[i] = [Double](repeating: Double(), count: 2*num_ghost+sol.q[0].count)
        for j in 0 ..< sol.q[0].count
        {
            q_bc[i][j+num_ghost] = sol.q[i][j]
        }
        for j in 0 ..< num_ghost
        {
            q_bc[i][j] = sol.q[i][0]
            q_bc[i][q_bc[i].count-1-j] = sol.q[i][sol.q[i].count-1]
        }
    }
    
    // Index q_r and q_l for the edges
    var q_r = [[Double]](repeating: [Double](repeating: Double(), count: q_bc[0].count-1), count: sol.q.count)
    var q_l = [[Double]](repeating: [Double](repeating: Double(), count: q_bc[0].count-1), count: sol.q.count)
    for i in 0 ..< q_bc.count
    {
        for j in 0 ..< q_bc[0].count-1
        {
            q_r[i][j] = q_bc[i][j+1]    //if you switch these then wave goes the right way
            q_l[i][j] = q_bc[i][j]
        }
    }
    
    // Solve Riemann problem at each interface
    var rp1 = solver_method(q_l, q_r, sol.aux, sol.aux, problem_data)
    
    for m in 0 ..< sol.num_eqn
    {
        for i in num_ghost ..< sol.gridCells
        {
            print("rp1:         \(rp1.apdq[m][i-num_ghost])")
            print("minus:       \(dt/sol.dx*rp1.apdq[m][i-num_ghost]) \n")
            
            q_bc[m][i] -= (dt/sol.dx) * rp1.apdq[m][i-num_ghost]
            q_bc[m][i-1] -= (dt/sol.dx) * rp1.amdq[m][i-num_ghost]
        }
    }
    
    // Compute maximum wave speed
    var cfl: Double = 0.0
    for i in num_ghost ..< sol.gridCells+num_ghost
    {
        for mw in 0 ..< 1
        {
            cfl = [cfl, dt/sol.dx*Double(rp1.s[mw][i-num_ghost]), -dt/sol.dx*Double(rp1.s[mw][i-num_ghost])].max()!
        }
    }
    
    print("before step: \(sol.q[0][20])")
    for i in 0 ..< sol.q.count
    {
        for j in 0 ..< sol.q[0].count
        {
            sol.q[i][j] = q_bc[i][j+num_ghost]
        }
    }
    print("after step:  \(sol.q[0][20])")
    
    sol.time += dt
}

