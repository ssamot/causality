# -*- coding: utf-8 -*-
"""
Created on Mon Aug 12 21:41:04 2013

@author: ssamot
"""

import numpy as np
from scipy.stats.stats import pearsonr,spearmanr
from sklearn import tree
from sklearn.svm import SVR,SVC
from feature_functions import min_samples_split,min_samples_leaf
from sklearn.decomposition import FastICA
from feature_functions import mutual_information


from sklearn import preprocessing

def noise_independence(x, y, name = None, type_map = None ,direction = None):
    if(direction > 0 ):
        #reverse direction
        # No need to reverse, we have done that in feaure level
        #x, y = y, x
        y_type = type_map.loc[name]["A type"]
    else:
        # normal direction
        y_type = type_map.loc[name]["B type"]



    if(y_type == "Binary" or y_type == "Categorical"):
        clf = tree.DecisionTreeClassifier(min_samples_split=min_samples_split(x),min_samples_leaf = min_samples_leaf(x), random_state = 0)
    else:
        clf = tree.DecisionTreeRegressor(min_samples_split=min_samples_split(x),min_samples_leaf = min_samples_leaf(x), random_state = 0)

    x_arr = np.array(x, ndmin=2)
    X = x_arr.transpose()

    clf.fit(X,y)
    scores = clf.predict(X)

    if(y_type == "Binary" or y_type == "Categorical"):
        residual = []
        #print y_type, "type", name
        for i,score in enumerate(scores):
            if(abs(y[i] - score )> 0.01):
                residual.append(0)
            else:
                residual.append(1)
    else:
        residual = y - scores

    score = abs(spearmanr(x, residual)[0])

    #print "NOISE", name, type_map.loc[name]["A type"], type_map.loc[name]["B type"], direction, y_type, score #type(type_map[name])
    return score

def acm(x, y, name = None, type_map = None ,direction = None):
    if(direction > 0 ):
        #reverse direction
        # No need to reverse, we have done that in feaure level
        #x, y = y, x
        y_type = type_map.loc[name]["A type"]
        x_type = type_map.loc[name]["B type"]
    else:
        x_type = type_map.loc[name]["A type"]
        y_type = type_map.loc[name]["B type"]



    if(y_type == "Binary" or y_type == "Categorical"):
        clf_1 = tree.DecisionTreeClassifier(min_samples_split=min_samples_split(x),min_samples_leaf = min_samples_leaf(x), random_state = 0)
        clf_2 = tree.DecisionTreeClassifier(min_samples_split=min_samples_split(x),min_samples_leaf = min_samples_leaf(x), random_state = 0)
    else:
        clf_1 = tree.DecisionTreeRegressor(min_samples_split=min_samples_split(x),min_samples_leaf = min_samples_leaf(x), random_state = 0)
        clf_2 = tree.DecisionTreeRegressor(min_samples_split=min_samples_split(x),min_samples_leaf = min_samples_leaf(x), random_state = 0)

    X = np.array(x, ndmin=2).T
    Y = np.array(y, ndmin=2).T
      
    
    clf_1.fit(X,y)
    clf_2.fit(Y,x)
    
    y_pred = clf_1.predict(X) - clf_2.predict(Y)

    if(y_type == "Binary" or y_type == "Categorical" or x_type == "Binary" or x_type == "Categorical"):
        score = mutual_information(y,y_pred, name, type_map, direction)
    else:
        score = abs(spearmanr(y, y_pred)[0])

    

    #print "NOISE", name, type_map.loc[name]["A type"], type_map.loc[name]["B type"], direction, y_type, score #type(type_map[name])
    return score


def noise_independence_overfit(x, y, name = None, type_map = None ,direction = None):
    if(direction > 0 ):
        #reverse direction
        # No need to reverse, we have done that in feaure level
        #x, y = y, x
        y_type = type_map.loc[name]["A type"]
    else:
        # normal direction
        y_type = type_map.loc[name]["B type"]


   
    if(y_type == "Binary" or y_type == "Categorical"):
        clf = SVC()
    else:
        clf = SVR()

    x_arr = np.array(x, ndmin=2)
    X = x_arr.transpose()


    scaler = preprocessing.StandardScaler().fit(X)      
    X  = scaler.transform(X)
    clf.fit(X,y)
    scores = clf.predict(X)

    if(y_type == "Binary" or y_type == "Categorical"):
        residual = []
        #print y_type, "type", name
        for i,score in enumerate(scores):
            if(abs(y[i] - score )> 0.01):
                residual.append(0)
            else:
                residual.append(1)
    else:
        residual = y - scores


    score =abs(spearmanr(x, residual)[0])

    #print "NOISE", name, type_map.loc[name]["A type"], type_map.loc[name]["B type"], direction, y_type, score #type(type_map[name])
    return score