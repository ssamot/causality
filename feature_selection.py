# -*- coding: utf-8 -*-
"""
Created on Wed Jul 24 20:39:01 2013

@author: ssamot
"""
import data_io
from sklearn.feature_selection import f_classif as chi2
from math import log






def get_top_features(X, y, min_score):
    c, p = chi2(X,y)
    print p, X.shape,c
    importantances = {}
    for i in xrange(0, len(p)):
        p[i]+=0.0000000001
        importantances[i] = -log(p[i])
    #print "OOB Score", clf.oob_score_
    import operator
    sorted_x = sorted(importantances.iteritems(),
                      key=operator.itemgetter(1), reverse=True)
    print "*" * 80
    top_features = []
    for i, val in enumerate(sorted_x):
        print i, X.columns[val[0]], val[1]
        if(val[1] > min_score):
            top_features.append(X.columns[val[0]])
    print top_features
    top_f = X[top_features]
    print top_f.shape
    return top_f

def main():

    X = data_io.load_train_features()
    if(type(X) == type(None)):
        print("No feature file found!")
        exit(1)
    y = data_io.read_train_target()


    #min_max_scaler = preprocessing.MinMaxScaler()


    #X = min_max_scaler.fit_transform(X)
    get_top_features(X,y.Target,20)
    

#==============================================================================
#     skf = cross_validation.StratifiedShuffleSplit(y.Target, n_iter=1, test_size = 0.1)
#     
#     for train_index, test_index in skf:
#        X_sampled = X.iloc[test_index]
#        y_sampled = y.iloc[test_index]
#        
# #==============================================================================
# #     X_sampled = X
# #     y_sampled = y    
# #     
# #         
# #     print y_sampled.Target
# # 
# #     
# #     print X.shape, y.shape, X_sampled.shape, y_sampled.shape
# #     
# #     
# #     
# #     
# #     
# #     #svc = SVC(kernel="linear")
# #     
# #     
# #     cval(X_sampled, y_sampled, clf, n_folds = 1, test_size = 0.90)
# #==============================================================================
#     clf = CausalClassifier()
#    
#     rfecv = RFECV(estimator=clf, step=1,loss_func = lambda y_true, y_pred:  -r2_score(y_true, y_pred))
#     rfecv.fit(X_sampled, y_sampled.Target)
#     
#     print_importances(X,rfecv)
#     
#     print "Optimal number of features : %d" % rfecv.n_features_
#     
#     # Plot number of features VS. cross-validation scores
#     import pylab as pl
#     pl.figure()
#     pl.xlabel("Number of features selected")
#     pl.ylabel("Cross validation score (nb of misclassifications)")
#     pl.plot(xrange(1, len(rfecv.cv_scores_) + 1), rfecv.cv_scores_)
#==============================================================================
    #4pl.savefig("features.pdf")


    


if __name__=="__main__":
    main()
