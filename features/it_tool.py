#!/usr/bin/env python
"""
Script to calculate Mutual Information between two discrete random variables

Roberto maestre - rmaestre@gmail.com
Bojan Mihaljevic - boki.mihaljevic@gmail.com
"""
from __future__ import division
from numpy  import shape, where, in1d
import math



class InformationTheoryTool:

    def __init__(self, data):
        """
        """
        # Check if all rows have the same length
        assert (len(data.shape) == 2)
        # Save data
        self.data = data
        self.n_rows = data.shape[0]
        self.n_cols = data.shape[1]


    def single_entropy(self, x_index, log_base, debug = False):
        """
        Calculate the entropy of a random variable
        """
        # Check if index are into the bounds
        assert (x_index >= 0 and x_index <= self.n_rows)
        # Variable to return entropy
        summation = 0.0
        # Get uniques values of random variables
        values_x = set(self.data[x_index])
        # Print debug info
        if debug:
            print 'Entropy of'
            print self.data[x_index]
        # For each random
        for value_x in values_x:
            px = shape(where(self.data[x_index]==value_x))[1] / self.n_cols
            if px > 0.0:
                summation += px * math.log(px, log_base)
            if debug:
                print '(%d) px:%f' % (value_x, px)
        if summation == 0.0:
            return summation
        else:
            return - summation


    def entropy(self, x_index, y_index, log_base, debug = False):
        """
        Calculate the entropy between two random variable
        """
        assert (x_index >= 0 and x_index <= self.n_rows)
        assert (y_index >= 0 and y_index <= self.n_rows)
        # Variable to return MI
        summation = 0.0
        # Get uniques values of random variables
        values_x = set(self.data[x_index])
        values_y = set(self.data[y_index])
        # Print debug info
        if debug:
            print 'Entropy between'
            print self.data[x_index]
            print self.data[y_index]
        # For each random
        for value_x in values_x:
            for value_y in values_y:
                pxy = len(where(in1d(where(self.data[x_index]==value_x)[0],
                                where(self.data[y_index]==value_y)[0])==True)[0]) / self.n_cols
                if pxy > 0.0:
                    summation += pxy * math.log(pxy, log_base)
                if debug:
                    print '(%d,%d) pxy:%f' % (value_x, value_y, pxy)
        if summation == 0.0:
            return summation
        else:
            return - summation



    def mutual_information(self, x_index, y_index, log_base, debug = False):
        """
        Calculate and return Mutual information between two random variables
        """
        # Check if index are into the bounds
        assert (x_index >= 0 and x_index <= self.n_rows)
        assert (y_index >= 0 and y_index <= self.n_rows)
        # Variable to return MI
        summation = 0.0
        # Get uniques values of random variables
        values_x = set(self.data[x_index])
        values_y = set(self.data[y_index])
        # Print debug info
        if debug:
            print 'MI between'
            print self.data[x_index]
            print self.data[y_index]
        # For each random
        for value_x in values_x:
            for value_y in values_y:
                px = shape(where(self.data[x_index]==value_x))[1] / self.n_cols
                py = shape(where(self.data[y_index]==value_y))[1] / self.n_cols
                pxy = len(where(in1d(where(self.data[x_index]==value_x)[0],
                                where(self.data[y_index]==value_y)[0])==True)[0]) / self.n_cols
                if pxy > 0.0:
                    summation += pxy * math.log((pxy / (px*py)), log_base)
                if debug:
                    print '(%d,%d) px:%f py:%f pxy:%f' % (value_x, value_y, px, py, pxy)
        return summation


