import matplotlib
matplotlib.use('Agg')

import data_io
import numpy as np
import pandas as pd
from sklearn import cross_validation
from sklearn.grid_search import GridSearchCV
from sklearn import metrics
from sklearn.metrics import mean_squared_error as mse
from joblib import Parallel, delayed
from sklearn.metrics import r2_score
from feature_selection import get_top_features
from multiprocessing.pool import ThreadPool as Pool
import os

import causal_classifier
#import trees_causal_classifier
clf = causal_classifier.CausalClassifier
#clf = trees_causal_classifier.CausalClassifier





def auc(y, y_pred):
  
    #y_1 = y[(y['Target'] == 0) | (y['Target'] == 1)]
    y_1 = y.copy()
    y_1[y.Target == 0] = -1
    #print y_1
    #predictions = y_p.ix[y_1.index]
    auc1 = metrics.auc_score(np.array(y_1.Target), y_pred)

    #y_2 = y[(y['Target'] == 0) | (y['Target'] == -1)]
    #predictions = y_p.ix[y_2.index]
    #predictions = predictions * (-1)
    y_2 = y.copy()
    y_2[y.Target == 0] = 1
    #y_2 = y_2.replace(-1, 1)
    #print predictions.shape, y_2.shape
    #print len(y_1),len(y_2.Target)

    auc2 = metrics.auc_score(np.array(y_2.Target), y_pred)

    auc = 0.5 * auc1 + 0.5 * auc2
    #print "AUC", auc, auc1, auc2
    return auc, auc1, auc2

def R2_score(X, y, clf):

    predictions = clf.predict(X)
    r2 = r2_score(y.Target, predictions)
    #print "AUC", auc
    return r2


def selectAllNumerical(X, y):
    info = data_io.read_train_info()
    info = info[(info['A type'] == "Numerical") & (info['B type'] == "Numerical")]

    X = X.ix[info.index]
    y = y.ix[X.index]
    return X, y

def selectAllCategorical(X, y):
    info = data_io.read_train_info()
    info = info[(info['A type'] != "Numerical") & (info['B type'] != "Numerical")]

    X = X.ix[info.index]
    y = y.ix[X.index]
    return X, y

def selectAllMixed(X, y):
    info = data_io.read_train_info()
    info = info[(info['A type'] != "Numerical") | (info['B type'] != "Numerical")]

    X = X.ix[info.index]
    y = y.ix[X.index]
    return X, y


def print_importances(X, clf, min_score):
    importantances = {}
    for i in xrange(0, len(clf.feature_importances_[0])):
        importantances[i] = (clf.feature_importances_[0][i])
    for i in xrange(0, len(clf.feature_importances_[1])):
        importantances[i] += (clf.feature_importances_[0][1])
    #print "OOB Score", clf.oob_score_
    import operator
    sorted_x = sorted(importantances.iteritems(),
                      key=operator.itemgetter(1), reverse=True)
    print "*" * 80
    
    top_features = []
    for i, val in enumerate(sorted_x[0:-1]):
        print i, X.columns[val[0]], val[1]
        if(val[1] > min_score):
            top_features.append(X.columns[val[0]])
    print top_features
        #c_names.append(X.columns[val[0]])
    return top_features
    #return X[c_names]


def fit_auc(X_train, X_test,y_train, y_test,clf):
    try:
        clf.fit(X_train,y_train.Target)
    except Exception as e:
        print e
    return auc(y_test, clf.predict(X_test))



# def cross_val_auc_split(X,y,clf):
#     X_train, X_test, y_train, y_test = cross_validation.StratifiedShuffleSplit(X, y.Target, test_size=0.10)
#     clf.fit(X.iloc[train_index],y.iloc[train_index])






def fit_clf(X_train, X_test,y_train, y_test,clf):
    clf.fit(X_train,y_train.Target)
    return clf, X_train, y_train,  X_test, y_test

def cross_val(X, y, clf, params = None, n_folds = 4, shuffle = False, score_func = fit_clf, test_size = 0.10, print_stage = True ):
   
    pool = Pool(processes=n_folds)       

    if(shuffle):
        skf = cross_validation.StratifiedShuffleSplit(y.Details, n_iter=n_folds, random_state  = 0)
       
    else:
        skf = cross_validation.StratifiedKFold(y.Details, n_folds=n_folds)
    
    # prints "100" unless your computer is *very* slow
    args = [(X.iloc[train_index], 
                                   X.iloc[test_index],
                                   y.iloc[train_index], 
                                   y.iloc[test_index],clf(**params))
                                    for i,(train_index, test_index) in enumerate(skf)]
    
    scores = []
    def log_result(result):
    # This is called whenever foo_pool(i) returns a result.
    # result_list is modified only by the main process, not the pool workers.
        scores.append(result)
    for i, arg in enumerate(args):
        pool.apply_async(score_func, args = arg, callback = log_result)
    pool.close()
    pool.join()
    
    params = clf(**params).params_
    
    aucs = np.zeros(params["n_estimators"])
    #print scores
    overall = 0
    
    for count, (clf, X_train, y_train,  X_test, y) in enumerate(scores):
        pred = auc(y,clf.predict(X_test))
        overall+=pred[0]
        print "OVERALL BEST",  pred,params,pred
        if(print_stage):
            for i,(y_1,y_2) in enumerate(clf.staged_predict_proba(X_test)):
                y_pred = y_1[:,1]-y_2[:,0]
                result = auc(y,y_pred)
                print result
                aucs[i]+=result[0]
#
    scores = np.array(aucs)/float(len(scores))
    count+=1
    print "Mean Best " , np.argmax(aucs),max(aucs)
    print "Final " , overall/float(count),count
    
    
    return overall/float(count),clf


    
    #print "Best", np.argmax(aucs[:,1]),np.argmax(aucs[:,2]),  max(aucs[:,0]), (max(aucs[:,1])+max(aucs[:,2]))/2.0
    
def sample(X,y, perc):
    skf = cross_validation.StratifiedShuffleSplit(y.Target, n_iter=1, test_size = perc)
    for train_index, test_index in skf:
        X = X.iloc[test_index]
        y = y.iloc[test_index]    
        
    return X,y
    
def delete_unused_columns(X):
    #pass
    del X['Number of Samples']
    #del X['Spears R Magnitude']
    del X["Spears R p"]
    #del X["lingam"]
    #del X["igci_ui"]
    #del X["igci_gi"]
    del X["A type"]
    del X["B Type"]
    #del X["Number of Unique Samples B"]
    #del X["Number of Unique Samples A"]
    del X["Uniform Symmetrised Divergence Difference"]
    del X['KL Divergence from Normal Difference']
    del X['KL Divergence from Uniform Difference']
    
    #del X['Metric Entropy A']
    #del X['Metric Entropy B']
  
    #c = ["Metric Entropy A","Metric Entropy B","Uncertainty Coefficient A","Uncertainty Coefficient B",'Noise Independence B --> A (trees)', 'lingam', 'Noise Independence A --> B (trees)', 'Predicts B --> A (trees)', 'Predicts A --> B (trees)']
    return X
        
def load_train_set():
    X = data_io.load_matlab_train_features()
    if(X is None):
        print("No feature file found!")
        exit(1)
    y = data_io.read_train_target()
    X = X.fillna(0)
    return X,y
        
def main():

    X,y = load_train_set()
    X = delete_unused_columns(X)
    #X,y = sample(X,y, 0.1)
    #X,y = selectAllCategorical(X,y)
    #print X.shape
    #exit()
#
#    import re
#    prog = re.compile(".*_[1,3]")
#    matches = [prog.match(i) is not None for i in X.index]
#    X,y = X[matches],y[matches]
    
    
    params = {'n_estimators': 3000, 'subsample': 0.6, 'random_state': 0, 'verbose':90, 'min_samples_split': 5, 'learning_rate': 0.00636406103119062, 'max_depth': 12, 'min_samples_leaf': 59}
    #params = {'n_estimators': 3000, 'subsample': 0.6, 'random_state': 0, 'verbose':90, 'min_samples_split': 5, 'learning_rate': 0.1, 'max_depth': 12, 'min_samples_leaf': 59}
    
    print params    
    score, c = cross_val(X, y, clf,params = params, n_folds = 2, shuffle = True, score_func = fit_clf, test_size = 0.10 )
  
    #bestClf = data_io.load_model();print "AUC", auc(y, bestClf.predict(X));exit(0)
    bestClf = clf(**params);bestClf.fit(X, y.Target);print "AUC", auc(y, bestClf.predict(X))

    #print_importances(X, bestClf, 1)

    print("Saving the classifier")
    data_io.save_model(bestClf)


if __name__ == "__main__":
    main()
