import numpy as np
from sklearn.base import BaseEstimator
from joblib import Parallel, delayed

##################### No Threads ##############################################

n_threads = 1


#====================  Multi-processing mapper =================================


def identity(x):
    return x

class SimpleTransform(BaseEstimator):
    def __init__(self, transformer=identity):
        self.transformer = transformer

    def fit(self, X, y=None):
        return self

    def fit_transform(self, X, y=None):
        return self.transform(X)

    def transform(self, X, y=None):
        t = []
        for i,x in enumerate(X):
            print self.transformer.__name__, i
            t.append(self.transformer(x))

        return np.array(t, ndmin=2).T

class MultiColumnTransform(BaseEstimator):
    def __init__(self, transformer, direction):
        self.transformer = transformer
        self.direction = direction


    def fit(self, X, y=None):
        return self

    def fit_transform(self, X, y=None):
        return self.transform(X)

    def transform(self, X, y=None):
        t = []
        for i,x in enumerate(X.iterrows()):
            print self.transformer.__name__, i
            t.append(self.transformer(*x[1], name=x[0], type_map=self.type_map, direction = self.direction))
        return np.array(t, ndmin=2).T



def execute_fit_transform(f,type_map, X,y):
    f.type_map = type_map
    return f.fit_transform(X,y)




class FeatureMapper:
    def __init__(self, features, train_info= None):
        self.features = features
        self.train_info = train_info


    def fit(self, X, y=None):
        for feature_name, column_names, extractor in self.features:
            extractor.fit(X[column_names], y)

    def transform(self, X):
        extracted = []
        for feature_name, column_names, extractor in self.features:
            fea = extractor.transform(X[column_names])
            if hasattr(fea, "toarray"):
                extracted.append(fea.toarray())
            else:
                extracted.append(fea)
        if len(extracted) > 1:
            return np.concatenate(extracted, axis=1)
        else:
            return extracted[0]


    def fit_transform_multi(self, X, y=None,type_map = None):
        extracted = []

        #asynch_results = {}
        asynch_results = Parallel(n_jobs=n_threads)(delayed(execute_fit_transform)(extractor,type_map, X[column_names], y) for i, (feature_name, column_names, extractor) in enumerate(self.features))

        for fea in asynch_results:
            if hasattr(fea, "toarray"):
                extracted.append(fea.toarray())
            else:
                extracted.append(fea)
        if len(extracted) > 1:
            return np.concatenate(extracted, axis=1)
        else:
            return extracted[0]

    # def fit_transform_multi(self, X, y=None,type_map = None):
    #     extracted = []

    #     asynch_results = {}
    #     try:
    #         for i, (feature_name, column_names, extractor) in enumerate(self.features):
    #             #print i,execute_fit_transform
    #             extractor.type_map = type_map
    #             ar = pool.apply_async(execute_fit_transform, [extractor,X[column_names], y])
    #             asynch_results[i] = ar
    #     except KeyboardInterrupt:
    #         print "Caught KeyboardInterrupt, terminating workers"
    #         pool.terminate()
    #         sys.exit(0)


    #     for i, (feature_name, column_names, extractor) in enumerate(self.features):
    #         #print i,execute_fit_transform
    #         fea = asynch_results[i].get()
    #         if hasattr(fea, "toarray"):
    #             extracted.append(fea.toarray())
    #         else:
    #             extracted.append(fea)
    #     if len(extracted) > 1:
    #         return np.concatenate(extracted, axis=1)
    #     else:
    #         return extracted[0]

    def fit_transform(self, X, y=None, type_map = None):

        if(n_threads > 1):
            return self.fit_transform_multi(X, y,type_map)
        extracted = []
        for feature_name, column_names, extractor in self.features:
            #print feature_name,column_names
            #print type(X[column_names])
            extractor.type_map = type_map
            fea = extractor.fit_transform(X[column_names], y)
            if hasattr(fea, "toarray"):
                extracted.append(fea.toarray())
            else:
                extracted.append(fea)
        if len(extracted) > 1:
            return np.concatenate(extracted, axis=1)
        else:
            print "extracted"
            return extracted[0]
