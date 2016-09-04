#!/usr/bin/env python

import numpy
import matplotlib.pyplot as plt
import clawpack.pyclaw.solution as sol

for i in xrange(20):
    mySolution = sol.Solution(i, path='./numerical_output')
    fig = plt.figure()
    axes = fig.add_subplot(1, 1, 1)
    axes.plot(mySolution.state.grid.x.centers, mySolution.q[0, :], 'o-')
    plt.savefig("./graphic_output/q%s.png" % i)
