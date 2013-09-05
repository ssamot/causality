import numpy as np
from scipy import log2

from scipy.special import psi
from scipy.stats.stats import pearsonr,spearmanr


from sklearn import tree

from it_tool import InformationTheoryTool

from sklearn.cluster import KMeans
from sklearn.svm import SVR,SVC
from sklearn.metrics.pairwise import euclidean_distances

from math import log


from sklearn import preprocessing




def min_samples_split(x):
    return 4*int(max(int(len(x)/100),5))

def min_samples_leaf(x):
    return int(max(int(min_samples_split(x)/10),20))

############################# Feature extractor functions #####################

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

    score = mutual_information(x,residual, name, type_map, direction)

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


    score = mutual_information(x,residual, name, type_map, direction)

    #print "NOISE", name, type_map.loc[name]["A type"], type_map.loc[name]["B type"], direction, y_type, score #type(type_map[name])
    return score


def coefficient_variation(x, y, name = None, type_map = None, direction = None):
    v = float(np.std(x))/float(np.mean(x))
    #print v
    return v


def metric_entropy(x, y, name = None, type_map = None, direction = None):
    if(sum(x) == 0 ):
        return 1;

    #x = np.array(x[:])
    #y = np.array(y[:])
    #x = np.ndarray.flatten(x)
    #y = np.ndarray.flatten(y)

    if(direction == 0):
        x_type = type_map.loc[name]["A type"]
        y_type = type_map.loc[name]["B type"]
    else:
        x_type = type_map.loc[name]["B type"]
        y_type = type_map.loc[name]["A type"]

    if(x_type == "Numerical"):
        x = cluster(x)
    if(y_type == "Numerical"):
        y = cluster(y)


    data = np.zeros((2, len(x)))

    #print name, x_type,y_type,len(x),type(x), "data.shape"


    data[0] = x
    data[1] = y
    it = InformationTheoryTool(data)

    entropy = float(it.single_entropy(0,2))/log(float(count_unique(x)),2)

    H = float(entropy)
    return H

###################  Predict using trees ###################################
def predict(x, y, name = None, type_map = None ,direction = None):
    if(direction > 0 ):
        #reverse direction
        # No need to reverse, we have done that in feaure level
        #x, y = y, x
        y_type = type_map.loc[name]["A type"]
    else:
        # normal direction
        y_type = type_map.loc[name]["B type"]



    if(y_type == "Binary" or y_type == "Categorical"):
        clf = tree.DecisionTreeClassifier(min_samples_split=min_samples_split(x), min_samples_leaf = min_samples_leaf(x), random_state = 0)
    #    #clf = linear_model.LogisticRegression(C=1.0, penalty='l1', tol=1e-6)
    else:
        clf = tree.DecisionTreeRegressor(min_samples_split=min_samples_split(x),min_samples_leaf = min_samples_leaf(x), random_state = 0)
        #clf = linear_model.LinearRegression()

    #clf = tree.DecisionTreeRegressor(min_samples_split=10)
    x = np.array(x, ndmin=2)
    X = x.transpose()

    clf.fit(X,y)
    score = clf.score(X,y)


    #score = sum(scores)/float(cv)
    #print name, type_map.loc[name]["A type"], type_map.loc[name]["B type"], direction, y_type, score #type(type_map[name])
    return score


def predict_overfit(x, y, name = None, type_map = None ,direction = None):
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
        #clf = linear_model.LinearRegression()

    #clf = tree.DecisionTreeRegressor(min_samples_split=10)
    x = np.array(x, ndmin=2)
    X = x.transpose()

    scaler = preprocessing.StandardScaler().fit(X)      
    x  = scaler.transform(X)
    clf.fit(X,y)
    score = clf.score(X,y)


    #score = sum(scores)/float(cv)
    #print name, type_map.loc[name]["A type"], type_map.loc[name]["B type"], direction, y_type, score #type(type_map[name])
    return score

def predict_vs_random(x, y, name = None, type_map = None,direction = None):

    import random
    random.seed(0)
    if(direction > 0 ):
        #reverse direction
        # No need to reverse, we have done that in feaure level
        #x, y = y, x
        x_type = type_map.loc[name]["B type"]
    else:
        # normal direction
        x_type = type_map.loc[name]["A type"]

    if(x_type == "Binary" or x_type == "Categorical"):
        new_x = []
        possible_states = tuple(set(x))
        for i in xrange(0,len(x)):
            new_x.append(random.choice(possible_states))
        #clf = linear_model.LogisticRegression(C=1.0, penalty='l1', tol=1e-6)
    else:
        new_x = []
        min_x = min(x)
        max_x = max(x)
        for i in xrange(0,len(x)):
            new_x.append(random.randint(min_x,max_x))
        #clf = linear_model.LinearRegression()

    score = predict(new_x,y, name, type_map, direction)
    return score


def predict_vs_random_overfit(x, y, name = None, type_map = None,direction = None):
    import random
    random.seed(0)
    if(direction > 0 ):
        #reverse direction
        # No need to reverse, we have done that in feaure level
        #x, y = y, x
        x_type = type_map.loc[name]["B type"]
    else:
        # normal direction
        x_type = type_map.loc[name]["A type"]

    if(x_type == "Binary" or x_type == "Categorical"):
        new_x = []
        possible_states = tuple(set(x))
        for i in xrange(0,len(x)):
            new_x.append(random.choice(possible_states))
        #clf = linear_model.LogisticRegression(C=1.0, penalty='l1', tol=1e-6)
    else:
        new_x = []
        min_x = min(x)
        max_x = max(x)
        for i in xrange(0,len(x)):
            new_x.append(random.randint(min_x,max_x))
        #clf = linear_model.LinearRegression()

    score = predict_overfit(new_x,y, name, type_map, direction)
    return score


def max_f(x):
    return max(x)

def sample_ratio(x):
    return float(count_unique(x))/float(len(x))




# def predict_node_count(x, y, name = None, type_map = None ,direction = None):
#     if(direction > 0 ):
#         #reverse direction
#         # No need to reverse, we have done that in feaure level
#         #x, y = y, x
#         y_type = type_map.loc[name]["A type"]
#     else:
#         # normal direction
#         y_type = type_map.loc[name]["B type"]



#     if(y_type == "Binary" or y_type == "Categorical"):
#         clf = tree.DecisionTreeClassifier(min_samples_split=min_samples_split(x),min_samples_leaf = min_samples_leaf(x))
#         #clf = linear_model.LogisticRegression(C=1.0, penalty='l1', tol=1e-6)
#     else:
#         clf = tree.DecisionTreeRegressor(min_samples_split=min_samples_split(x),min_samples_leaf = min_samples_leaf(x))
#         #clf = linear_model.LinearRegression()


#     #clf = tree.DecisionTreeRegressor(min_samples_split=10)
#     x = np.array(x, ndmin=2)
#     X = x.transpose()

#     clf.fit(X,y)
#     score = clf.tree_.node_count


#     #score = sum(scores)/float(cv)
#     print "node_count", name, type_map.loc[name]["A type"], type_map.loc[name]["B type"], direction, y_type, score #type(type_map[name])
#     return score








def count_unique(x):
    return len(set(x))


def kl(p, q):
    """Compute the KL divergence between two discrete probability distributions

    The calculation is done directly using the Kullback-Leibler divergence,
    KL( p || q ) = sum_{x} p(x) log_2( p(x) / q(x) )

    Base 2 logarithm is used, so that returned values is measured in bits.
    """

    if (p==0.).sum()+(q==0.).sum() > 0:
        raise Exception, "Zero bins found"
    return (p*(log2(p) - log2(q))).sum()


def kl_divergence_uniform_difference(x, y, name = None, type_map = None, direction = None):
    return (kl_divergence_uniform(x,0,name, type_map, direction) - kl_divergence_uniform(y,0,name, type_map, direction))

def kl_divergence_uniform(x,y, name = None, type_map = None, direction = None):
    x = (x - min(x)) / (max(x) - min(x))
    x = np.sort(x)

    hx = 0.0;
    for i in range(len(x)-1):
        delta = x[i+1] - x[i];
        if delta != 0:
            hx += np.log(np.abs(delta));
    hx = hx / (len(x) - 1) + psi(len(x)) - psi(1);
    return hx

def kl_divergence_normal_difference(x, y, name = None, type_map = None, direction = None):
    return (kl_divergence_normal(x,0,name, type_map, direction) - kl_divergence_normal(y,0,name, type_map, direction))

def kl_divergence_normal(x,y, name = None, type_map = None, direction = None):
    x = (x - np.mean(x)) / np.std(x)
    x = np.sort(x)

    hx = 0.0;
    for i in range(len(x)-1):
        delta = x[i+1] - x[i];
        if delta != 0:
            hx += np.log(np.abs(delta));
    hx = hx / (len(x) - 1) + psi(len(x)) - psi(1);
    return hx



def uniform_symmetrised_divergence_difference(x, y, name = None, type_map = None, direction = None):
    return (uniform_symmetrised_divergence(x,0,name, type_map, 0) - uniform_symmetrised_divergence(y,1,name, type_map, 1))


def uniform_symmetrised_divergence(x,y, name = None, type_map = None, direction = None):
    #var_type = type_map.loc[name]["A type"]

    #if(var_type == "Numerical"):
    #    return -1000;

    if(direction > 0 ):
        #reverse direction
        # No need to reverse, we have done that in feaure level
        #x, y = y, x
        x_type = type_map.loc[name]["B type"]
    else:
        # normal direction
        x_type = type_map.loc[name]["A type"]

    if(x_type == "Binary" or x_type == "Categorical"):
        x = x[:]
    else:
        x = cluster(x)
        x = np.array(x)

    unique = len(set(x))
    x = x.astype(np.int64)
    x_h =np.bincount(x)

    d_dim = len(x)/unique

    uni  = np.array([d_dim]*unique)

    # remove empty bins (!!!!)
    x_h = x_h.tolist()
    zeros = x_h.count(0)
    for i in xrange(zeros):            #print x
        x_h.remove(0)

    x_h = np.array(x_h)
        #print unique, x_h.shape, uni.shape, name, x_type,direction, sum(x_h), sum(uni)
    s = sum(x_h)
    p = x_h/float(s)

    s = sum(uni)
    q = uni/float(s)
    #print x_h.shape, uni.shape
    hx = kl(p, q) + kl(q, p)
    #print name,hx,sum(q), sum(p)

    return hx


def cluster(X):

    #n_clusters = int(round(sqrt(len(X)/2.0)))
    #print n_clusters
    n_clusters = 10
    #print len(X), "X full"
    X = np.array(X, ndmin=2)
    X = X.transpose()



    k_means = KMeans(init='k-means++', n_clusters=n_clusters, n_init=5, max_iter = 100, random_state=0)
    k_means.fit(X)
    k_means_cluster_centers = k_means.cluster_centers_
    distance = euclidean_distances(k_means_cluster_centers,
                                   X,
                                   squared=True)

    new_x = []
    distance = distance.transpose()
    for d in distance:
        new_x.append(np.argmin(d)+1)
    #print new_x
    #print len(new_x), "lensflsajdalsj"
    return new_x

def uncertainty_coeff(x, y, name = None, type_map = None, direction = None):
    ##n_bins = 10

    if(sum(y) == 0 ):
        return 0;

    #x = np.array(x[:])
    #y = np.array(y[:])
    #x = np.ndarray.flatten(x)
    #y = np.ndarray.flatten(y)

    if(direction == 0):
        x_type = type_map.loc[name]["A type"]
        y_type = type_map.loc[name]["B type"]
    else:
        x_type = type_map.loc[name]["B type"]
        y_type = type_map.loc[name]["A type"]

    if(x_type == "Numerical"):
        x = cluster(x)
    if(y_type == "Numerical"):
        y = cluster(y)


    data = np.zeros((2, len(x)))

    #print name, x_type,y_type,len(x),type(x), "data.shape"


    data[0] = x
    data[1] = y
    it = InformationTheoryTool(data)
    mutual_info = it.mutual_information(0,1,2)
    #print len(y)
    #g = float(mi)/(2.0*len(y))
    #print x,y
    entropy = it.single_entropy(1,2)

    C = float(mutual_info)/(float(entropy))
    return C


def mutual_information(x, y, name = None, type_map = None, direction = None):

    if(sum(y) == 0 ):
        return 0;

    #x = np.array(x[:])
    #y = np.array(y[:])
    #x = np.ndarray.flatten(x)
    #y = np.ndarray.flatten(y)

    if(direction == 0):
        x_type = type_map.loc[name]["A type"]
        y_type = type_map.loc[name]["B type"]
    else:
        x_type = type_map.loc[name]["B type"]
        y_type = type_map.loc[name]["A type"]

    if(x_type == "Numerical"):
        x = cluster(x)
    if(y_type == "Numerical"):
        y = cluster(y)


    data = np.zeros((2, len(x)))

    #print name, x_type,y_type,len(x),type(x), "data.shape"


    data[0] = x
    data[1] = y
    it = InformationTheoryTool(data)
    mutual_info = it.mutual_information(0,1,2)
    #print len(y)
    #g = float(mi)/(2.0*len(y))
    #print x,y
    # entropy = it.single_entropy(0,2)
    # if(entropy == 0):
    #     return 1000


    C = float(mutual_info)
    return C



def var_type(x, y, name = None, type_map = None, direction = None):
    if(direction == 0):
        var_type_x = type_map.loc[name]["A type"]
    else:
        var_type_x = type_map.loc[name]["B type"]
    if(var_type_x == "Binary"):
        return 1
    if(var_type_x == "Categorical"):
        return 2
    if(var_type_x == "Numerical"):
        return 3


#####################  Correlation ###############################################################

def correlation(x, y, name = None, type_map = None, direction = None):
    #print pearsonr(x, y)
    return spearmanr(x, y)[1]

def correlation_magnitude(x, y, name = None, type_map = None, direction = None):
    return abs(spearmanr(x, y)[0])


def pcorrelation(x, y, name = None, type_map = None, direction = None):
    #print pearsonr(x, y)
    return pearsonr(x, y)[1]

def pcorrelation_magnitude(x, y, name = None, type_map = None, direction = None):
    return abs(pearsonr(x, y)[0])

#from sklearn.preprocessing import scale


