from sklearn.ensemble import GradientBoostingClassifier as Gbc
import numpy as np
from joblib import Parallel, delayed
from sklearn import linear_model

from sklearn.preprocessing import StandardScaler


# lame , in order to avoid pickling instancemethods
def fit(X,y,clf):
    clf.fit(X,y)
    return clf
class Adaptor():
    def __init__(self, est):
       
       self.est = est
    def predict(self, X):
        X  = self.scaler.transform(X.copy())
        print self.est.predict_proba(X).shape, X.shape
        
        
        return np.array(self.est.predict_proba(X)[:, 1],ndmin = 2).T
    def fit(self, X, y):
        #print X.shape,y.shape        
        #exit()
        self.scaler = StandardScaler().fit(X.copy())  
        X = self.scaler.transform(X.copy())
        self.est.fit(X, y)

class CausalClassifier():
    def __init__(self, n_estimators = 10000, min_samples_leaf = 100, max_depth = 7, learning_rate = 0.05,subsample = 0.6 , min_samples_split = 1, verbose = 1000, random_state = 0):
        self.params_ = {'n_estimators': n_estimators,
          'max_depth': max_depth,
          'learning_rate': learning_rate,
          'subsample' : subsample,
          'min_samples_split' :min_samples_split,
          'verbose': verbose,
          'random_state':random_state,
          'min_samples_leaf':min_samples_leaf
        
         # 'max_features': None,
           }
        #print self.params_
        p0 = self.params_.copy()
        #p0["init"] = Adaptor(SVC(probability=True))
      
        
        
        p1 = self.params_.copy()
        #p1["init"] = Adaptor(SVC(probability=True))
        
        self.svm = [linear_model.LogisticRegression(class_weight= "auto"),  linear_model.LogisticRegression(class_weight= "auto")]
        self.clf = [Gbc(**p0),Gbc(**p1) ]
        
   
    def fit(self,X,y):
     
        #print X.values.shape
        #self.scaler = StandardScaler().fit(X)   
        #X = self.scaler.transform(X)
        #X = pd.DataFrame(data = self.scaler.transform(X), index = X.index, copy = True)
        #self.svm.fit(X.copy(),y.copy())
        y_1 = y.copy()        
        y_1[y==-1] = 0
        y_2 = y.copy()
        y_2[y==1] = 0
        #y_2[y==-1] = 1
        
        y = [y_1,y_2]
        #print y_2[y == -1].shape
        print y[0].shape, y[1].shape
        print (y[0][y[0]==0].shape[0]),(y[0][y[0]==1].shape[0])
        print (y[1][y[1]==0].shape[0]),(y[1][y[1]==-1].shape[0])
      
        #y = [y.replace(-1, 0),y.replace(1, 0) ]

        self.clf = Parallel(n_jobs=2)(delayed(fit)(X,y[i],self.clf[i]) for i in range(2))
        self.feature_importances_ = [0,1]
        self.feature_importances_[0] = self.clf[0].feature_importances_
        self.feature_importances_[1] = self.clf[1].feature_importances_
        #self.feature_importances_ = self.clf[0].feature_importances_        
        self.oob_score_ = self.clf[0].oob_score_ + self.clf[1].oob_score_
        self.oob_score_ = self.oob_score_/2.0
        ## post processing!
        # for the first one :
#        for i in xrange(0,2):
#            X_post = []
#            for estimator in self.clf[i].estimators_:
#                
#                prediction =  estimator[0].predict(X)
#                X_post.append(prediction)
#            X_post = np.array(X_post).T
#            print X_post.shape
#            self.svm[i].fit(X_post, y[i])     
#            print self.svm[i].coef_
        
        

    def predict(self,X):
       
        #X  = self.scaler.transform(X)
        #return (self.predict_svm(X.copy()) + self.predict_trees(X.copy()))/2.0
        return self.predict_trees(X.copy())
        
    def predict_pruned(self,X, val):
        
        for i,(y_1,y_2) in enumerate(self.staged_predict_proba(X.copy())):
                if(i == val):                
                    y_pred = y_1[:,1]-y_2[:,0]
                    break
        return y_pred
    
    def predict_trees(self,X):
        y_1 = self.clf[0].predict_proba(X)
        y_2 = self.clf[1].predict_proba(X)

        A = y_1[:,1]
        C = y_2[:,0]
    
#        X = X[['B Type', 'A type', 'Number of Samples', 'Number of Unique Samples B', 'Number of Unique Samples A', 'Spears R Magnitude', 'Noise Independence B --> A (trees)', 'Noise Independence A --> B (trees)', 'Noise Independence B --> A (trees) - overfit', 'Noise Independence A --> B (trees) - overfit', 'Metric Entropy B', 'Metric Entropy A', 'Uncertainty Coefficient B', 'Uncertainty Coefficient A', 'Predicts B --> A (trees)', 'Predicts A --> B (trees)', 'Predicts U --> A (trees)', 'Predicts U --> B (trees)', 'Predicts B --> A (trees) - overfit', 'Predicts A --> B (trees) - overfit', 'Predicts U --> A (trees) - overfit', 'Predicts U --> B (trees) - overfit', 'Uniform Symmetrised Divergence B', 'Uniform Symmetrised Divergence A', 'Uniform Symmetrised Divergence Difference', 'KL Divergence from Normal B', 'KL Divergence from Normal A', 'KL Divergence from Normal Difference', 'KL Divergence from Uniform B', 'KL Divergence from Uniform A', 'KL Divergence from Uniform Difference', 'Noise Independence B --> A (trees) - spearman', 'Noise Independence A --> B (trees) - spearman', 'igci_gi', 'igci_ui', 'lingam']]  
#        X['lingam']  *=-1 
#        X["igci_ui"] *=-1 
#        X["igci_gi"] *=-1 
#        
#        X['KL Divergence from Uniform Difference'] *=-1 
#        X['KL Divergence from Normal Difference'] *=-1
#        X['Uniform Symmetrised Divergence Difference'] *=-1
#        y_3 = self.clf[0].predict_proba(X)
#        y_4 = self.clf[1].predict_proba(X)
#        #y_all = []
#        
#        C_sym = y_3[:,1]
#        A_sym = y_4[:,0]
#           
#        #return (A-C)/2.0 +  
#        ret = ((A_sym-C_sym))/2.0 + (A-C)/2.0
        ret = (A-C)
        return ret
        
    def predict_svm(self,X):
        #return 0.5   
        y = [0,0]
        for i in xrange(0,2):
            X_post = []
            for estimator in self.clf[i].estimators_:
                
                prediction =  estimator[0].predict(X)
                X_post.append(prediction)
            X_post = np.array(X_post).T
            print X_post.shape
            y[i] = self.svm[i].predict_proba(X_post)
        
       
        #y_all = []
        
        return  y[0][:,1]-y[1][:,0]
        

    def staged_predict_proba(self, X):
        #return self.clf[i].staged_predict(X)
        g1 = self.clf[0].staged_predict_proba(X)
        g2 = self.clf[1].staged_predict_proba(X)
        
        for i in g1:
            yield(i,g2.next())
        
        #return [self.clf[0].staged_predict_proba(X),self.clf[1].staged_predict_proba(X)]
    def loss_(self, y_test, y_pred,i):
        return self.clf[i].loss_(y_test, y_pred)
        #return [self.clf[0].loss_(y_test, y_pred),self.clf[1].loss_(y_test, y_pred)]

    def __repr__(self):
        return "CausalClassifier with " + str(self.params_)