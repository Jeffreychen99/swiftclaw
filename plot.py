#!/usr/bin/env python

import numpy
import matplotlib.pyplot as plt
import clawpack.pyclaw.solution as sol

file = open('num_steps.txt', 'r')
num_steps = file.read()

for i in xrange(int(num_steps)):
    mySolution = sol.Solution(i, path='./numerical_output')
    fig = plt.figure()
    axes = fig.add_subplot(1, 1, 1)
    axes.plot(mySolution.state.grid.x.centers, mySolution.q[0, :], 'o-')
    plt.savefig("./graphic_output/q%s.png" % i)