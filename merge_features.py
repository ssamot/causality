# -*- coding: utf-8 -*-
"""
Created on Mon Aug 12 22:01:11 2013

@author: ssamot
"""
from train import load_train_set
import data_io
def main():

    y = data_io.read_train_target()
    X = data_io.load_train_features()
    if(type(X) == type(None)):
        print("No feature file found!")
        exit(1)
    
    X_old = data_io.load_features("./Models/old_csv/features_train_en_python.csv")
    print X.shape
    X = X_old.join(X)
    print X.shape
    #print X
    data_io.save_train_features(X,y)
    
    X = data_io.load_valid_features()
    X_old = data_io.load_features("./Models/old_csv/features_valid_en_python.csv")
    print X.shape
    X = X_old.join(X)
    print X.shape
    data_io.save_valid_features(X)
    
if __name__=="__main__":
    main()
    
    