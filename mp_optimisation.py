from train import cross_val as cva
from train import fit_auc
import causal_classifier as causal_classifier
import data_io
import numpy as np
from sto_SOO import stoSOO, State, calc_best_from_node
import random
from sklearn import gaussian_process
from matplotlib import pyplot as pl
from train import sample, load_train_set, delete_unused_columns
import time
import itertools

clf = causal_classifier.CausalClassifier
         
class Scorer:
    
   

    def __init__(self, X, y):
        self.X = X
        self.y = y
        #print self.y.shape

    def score(self, x):


            X,y = self.X, self.y
            #X,y = sample(X,y,0.1)
               
            

            params = {'n_estimators': 1500,
                      'max_depth': x[0],
                      'learning_rate': x[1],
                      'subsample' : x[2],
                      'min_samples_split' :5,
                      'min_samples_leaf' : x[3],
                      'verbose' : 0
            }

         
         
            
            #print params                       
         
            score = cva(X, y, clf, params = params,  n_folds = 2, shuffle=True, test_size = 0.1, print_stage = False)
            #score = 1

            #print "SCORE", x, score
            return score[0].mean()
            
            


def plot_gp(X, y, root_state, gp):
    fig = pl.figure()
    print root_state.min_array[0], root_state.max_array[0]
    x_learned = np.linspace(root_state.min_array[0], root_state.max_array[0], 2000)
    x_learned = np.atleast_2d(x_learned).T
    print x_learned.shape, "learned"
    
    y_pred, MSE = gp.predict(x_learned, eval_MSE=True)

    sigma = np.sqrt(MSE)
    
    pl.plot(x_learned, y_pred, 'b-', label=u'Prediction')
    pl.fill(np.concatenate([x_learned, x_learned[::-1]]),
    np.concatenate([y_pred - 1.9600 * sigma,
                       (y_pred + 1.9600 * sigma)[::-1]]),
                alpha=.5, fc='b', ec='None', label='95% confidence interval')
    pl.axis([root_state.min_array[0],root_state.max_array[0],0.0, 1.0])
    pl.savefig("surrogate.pdf")
    #exit(0)


def surrogate_search():
    ## sample three times
    
    
    iterations = 300
    epsilon = 0.1
    
    X,y = load_train_set()
    #X,y = sample(X,y,0.1)
    sc = Scorer(X,y)
    min_v = [5, 0.001, 0.1]
    max_v = [20, 0.1, 0.8]
    root_state = State(min_v, max_v, K = 3)
    
    X = []
    y = []
    n_lims  = np.array([min_v, max_v])    
    extremes =  list(itertools.product(*n_lims.T))
    for i, extreme in enumerate(extremes):
            #draw = root_state.sample()
            
            val = sc.score(extreme)
            print "Extreme", i, extreme, val
            X.append(extreme)
            y.append(val)     
    

    for iteration in xrange(0,iterations):
        ## fit a regressor over the samples
        #clf = DecisionTreeRegressor()
        
        clf = gaussian_process.GaussianProcess()
      
        
        clf.fit(X,y)
        #print X, y, clf.predict(X)
        #exit()
        #plot_gp(X,y,root_state,clf)
        best_node = stoSOO(root_state,  10000, lambda x: clf.predict([x])[0], verbose = False, det = False,output_dir = "./Optimisation")
        r = random.random()
        if(r > epsilon):
            draw = best_node.state.sample()
        else:
            draw = root_state.sample()
      
        
        val = sc.score(draw)
        X.append(draw)
        y.append(val) 
        print "DRAW",draw, val
        
        print "Best So Far", best_node, best_node.depth, best_node.state._n_splits
        print "Surrogate Best", calc_best_from_node(best_node)
       
        #print "BEST", best_node.state, y[-1], best_node.score()
    #return clf
    #root_state = State([5, 0.001, 10000], [20, 0.8, 10001], K = 3)
    #best_node = stoSOO(root_state,  1000, lambda x: clf.predict([x])[0], verbose = False, det = False,output_dir = "./Optimisation")
    #print "10-kBEST", best_node.state, y[-1], best_node.score()
    #best = calc_best_from_node(soo)
    #print best
    #print X,y
        

def grid_search():
    
    X = data_io.load_train_features()
    if(type(X) == type(None)):
        print("No feature file found!")
        exit(1)
    y = data_io.read_train_target()    
    
    tree_depth = [5, 7, 9 , 10, 12, 14]
    learning_rate = [0.01, 0.05, 0.1, 0.2]
    scorer = Scorer(X,y)
    for d in tree_depth:
        for l in learning_rate:
            r = scorer.score([d,l])
            print "Score", d,l,r
            
def test_speed():
    X,y = load_train_set()
    #X,y = sample(X,y,0.01)
    sc = Scorer(X,y)
    v = [5, 0.0010679012345679011, 0.6087791495198902]
    start_time = time.time()
    print sc.score(v)
    elapsed_time = time.time() - start_time
    print elapsed_time, "seconds"

def main():
    X,y = load_train_set()
    #X,y = sample(X,y,0.1)
    X = delete_unused_columns(X)
    sc = Scorer(X,y)
    min_v = [5, 0.001, 0.1,20]
    max_v = [20, 0.1, 0.8,100]
     #root = State([0.0], [1.0], f_0_noisy, K = 3 )
    root_state = State(min_v, max_v, K = 3)

    best_node = stoSOO(root_state, 300, sc.score,  verbose = True, det = True, output_dir = "./Optimisation")
    print "BEST", best_node.state,  best_node.score()
    # best = (np.array(best_node.state.max_array) - np.array(best_node.state.min_array))/2.0
    # #print best
    best = calc_best_from_node(best_node)
    print best




if __name__ == "__main__":
    #test_speed()
    #grid_search()
    #surrogate_search()    
    main()
    #stoch()