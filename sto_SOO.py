# This is a very simple implementation of the UCT Monte Carlo Tree Search algorithm in Python 2.7.
# The function UCT(rootstate, itermax, verbose = False) is towards the bottom of the code.
# It aims to have the clearest and simplest possible code, and for the sake of clarity, the code
# is orders of magnitude less efficient than it could be made, particularly by using a
# state.GetRandomMove() or state.DoRandomRollout() function.
#
# Example GameState classes for Nim, OXO and Othello are included to give some idea of how you
# can write your own GameState use UCT in your 2-player game. Change the game to be played in
# the UCTPlayGame() function at the bottom of the code.
#
# Written by Peter Cowling, Ed Powley, Daniel Whitehouse (University of York, UK) September 2012.
#
# Licence is granted to freely use and distribute for any sensible/legal purpose so long as this comment
# remains in any distributed code.
#
# For more information about Monte Carlo Tree Search check out our web site at www.mcts.ai
#
# Modified to StoSOO by Spyridon Samothrakis (2013)

from math import sqrt, log, pow, sin, floor, ceil
import numpy as np
import csv

##################### No Threads ##############################################

n_threads = 2

###############################################################################

class State:
    """
        A State in the StoSOO tree.
    """
    def __init__(self, min_array, max_array, K = 2):

        self.min_array = min_array
        self.max_array = max_array
        self.K = K
        self._n_splits = [0]*len(min_array)
      
        


    def clone(self):
        """
            Clone a Node.
        """
        cloned = State(self.min_array[:],
                      self.max_array[:],
                      self.K)
        return cloned


    def children(self):
        """ split the node into K subnodes across a single dimension
        """
        # Choose a dimension at random
        dim = np.random.randint(len(self.min_array))

        dim = np.random.randint(len(self.min_array))
        #dim = np.random.randint(len(self.min_array))
        # Choose a dimension with the lowest spliting number
        n_splits = self._n_splits[:]
        #min_index, min_value = min(enumerate(values), key=operator.itemgetter(1))

        # Make sure it makes sense to split in a certain dimension
        #print dim
        should_return_empty = True
        for i in range(len(self.min_array)):
            if isinstance(self.min_array[i],float):
                should_return_empty = False
            dist = self.max_array[dim] - self.min_array[dim]
            #print dist
            if(dist > 1):
                should_return_empty = False
        if(should_return_empty):
            return []

        dim = (np.array(n_splits)).argmin()

        while(self.max_array[dim] - self.min_array[dim] <= 1 and isinstance(self.min_array[dim],int)):
            dim = np.random.randint(len(self.min_array))
        #print dim
        #print n_splits
        #children = [self.clone() for i in range(self.K)]
        n_splits[dim]+=1
        
        

        #print "dim", dim
        splits = self._split(self.K,self.min_array[dim], self.max_array[dim])
        #print n_splits, splits
        #print "splits", len(splits)
        children = []
        for i, split in enumerate(splits):
            child = self.clone()
            child.min_array[dim] = split[0]
            child.max_array[dim] = split[1]
            child._n_splits = n_splits
            children.append(child)

        return children


    def _split(self, K, min_x, max_x):
        """ Split a value into K intervals
        """

        interval = abs(float(max_x) - float(min_x))/  K
        splits = [[min_x + i * interval,min_x + (i + 1) * interval] for i in range(K)]
        if(isinstance(min_x, int)):
            if  interval < 1:
                #print interval, K
                K = max_x - min_x
                interval = 1
                splits = [[min_x + i * interval,min_x + (i + 1) * interval] for i in range(K)]
            #print splits, K, max_x
            # floor to turn into integers
            for split in splits:
                split[0] = int(floor(split[0]))
                split[1] = int(floor(split[1]))

            # check last interval and change to max_x
            splits[-1][1] = max_x
            #print splits, K
        #print "==================="
        return splits



    def sample(self):
        """ sample func for a random value between min and max of each dimension.
        """
        draw = []

        for i in xrange(len(self.min_array)):
            if(isinstance(self.min_array[i], int)):
                r = np.random.randint(self.min_array[i], self.max_array[i])
                #print r
            else:
                r = self.min_array[i] + abs(self.max_array[i] - self.min_array[i]) * np.random.rand(1)[0]
            draw.append(r)

        return draw


    def is_within_intervals(self, sample):
        for i in range(len(sample)):
            if(self.min_array[i] < sample[i] or self.max_array[i] >=  sample[i]  ):
                return False
        return True

    def __repr__(self):
        return "[" + " Min:" + str(self.min_array) + ", Max:" + str(self.max_array) +  " ]"




class Node:
    """ A node in StoSOO tree.
    """




    def __init__(self, parent, state, depth, func):
        self.parentNode = parent # "None" for the root node
        self.state = state
        self.childNodes = []
        self.reward = 0
        self.visits = 0.0
        self.depth = depth
        self.samples = []
        self.func = func


    def b_value(self,n,k,delta):
        if(self.visits == 0):
            return 999999+np.random.random()
        else:
            #return self.reward/self.visits + sqrt(log((n*k)/delta)/(2*self.visits))
            return self.reward/self.visits + sqrt(log((n)**2/delta)/2.0)

    def rand_score(self,n,k,delta):
        return -999999+np.random.random()


    def score(self):
        if(self.visits == 0):
            return -999999+np.random.random()
        else:
            return self.reward/self.visits

    def select_child(self, n, k, delta):
        """ Choose a child
        """
        s = sorted(self.childNodes, key = lambda c: c.b_value(n, k, delta))
        #print s
        return s[-1]

    def belongs(self, sample):
        for i in range(len(self.state.min_array)):
            if(sample[i] >= self.state.max_array[i] or sample[i] < self.state.min_array[i] ):
                return False

        return True


    def expand(self):
        if(self.childNodes == []):
            self.childNodes = [Node(self, child_state, self.depth+1, self.func) for child_state in self.state.children()]
        # if(len(self.childNodes)%2!=0):
        #     middle = len(self.childNodes)/2
        #     #print middle
        #     self.childNodes[middle].reward = self.reward/self.visits
        #

        # for child_node in self.childNodes:
        #     child_node.reward = self.reward/self.visits
        #     child_node.visits = 1.0

        for sample in self.samples:
            for child in self.childNodes:
                if(child.belongs(sample[0])):
                    child.update(sample[1])

        if(self.childNodes!=[]):
            return True
        else:
            return False

    def update(self, reward):
        """ Update this node - one additional visit and sample score increase
        """
        self.visits += 1.0
        self.reward += reward

    def sample(self):
        draw = self.state.sample()
        val = self.func(draw)
        smpl = (draw,val)
        self.samples.append(smpl)
        return smpl

    def __repr__(self):
        return "[" + " R/V:" + str(self.reward) + "/" + str(self.visits) + ", " + str(self.state) + "]"




def sample_update(leaf):
    sample, reward = leaf.sample()
    return (sample,leaf,reward)

def calc_best_from_node(node):
    best = []
    for i in range(len(node.state.max_array)):
        if(isinstance(node.state.min_array[i], int)):
            best.append(node.state.min_array[i])
        else:
            middle = (node.state.max_array[i] - node.state.min_array[i])/2.0
            best.append(node.state.min_array[i] + middle)
    return best

def stoSOO(rootstate, itermax, func, verbose = False, det = False, output_dir = None):
    """ Conduct a UCT search for itermax iterations starting from rootstate.
        Return the state with the highest mean"""

    writer = None
    if(output_dir!=None):
        writer = csv.writer(open(output_dir + "/stoSOO.csv", "wb"))
        writer_samples = csv.writer(open(output_dir + "/stoSOO-samples.csv", "wb"))

    #if(n_threads > 1):
    #    pool = LoggingPool(n_threads)
    #print "sdfasldjfa;slkjf"
    # set reasonable constants
    k = int(ceil(itermax/ pow(log (itermax),3)))
    h_max = int(ceil(sqrt(float(itermax)/float(k))))

    if(det):
        h_max = int(ceil(sqrt(float(itermax))))
    else:
        h_max = int(ceil(sqrt(float(itermax)/float(k))))

    delta = 1.0/ sqrt(itermax)

    if (verbose):
        print "n = ", itermax
        print "k = ", k
        print "h_max", h_max
        print "delta", delta
        print "log(nk/delta)",log((itermax*k)/delta)

    rootnode = Node(None,rootstate,0,func)
    rootnode.expand()

    leaves_at_depth = {}
    leaves_at_depth[0] = rootnode.childNodes
    #depth = 0
    max_depth = 0
    evals = 0

    best_score_overall = float("-inf")
    best_leaf_overall = rootnode
    for i in range(0,itermax) :

        if(evals >= itermax):
            break

        if(verbose):
            print "StoSOO Evals" + str(evals)

        b_max = float("-inf")

        for h in range(min(max_depth+1,h_max)):

            leaf_nodes = leaves_at_depth[h]
            #print depth, leaf_nodes
            expanded_nodes = []
            #print i, h, leaf_nodes
            #print evals, h, len(leaf_nodes)
            #if(len(leaf_nodes) == 0):
            #    continue
            best_leaf = None
            best_ih = float("-inf")
            for leaf in leaf_nodes:
                b = leaf.b_value(itermax,k,delta)
                #print b, best_ih
                score = leaf.score()
                if(score > best_score_overall and (leaf.visits+1)== k):
                    best_score_overall = score
                    best_leaf_overall = leaf
                if(b > best_ih):
                    best_leaf = leaf
                    best_ih = b

            #print best_ih, h, best_leaf, len(leaf_nodes)
            # if (best_leaf != None):
            #     print best_leaf.childNodes
            #print best_leaf, best_ih, evals
            if(best_ih > b_max):
                    if(best_leaf.visits+1 < k):

                        sample, c_leaf, reward = sample_update(best_leaf)
                        best_leaf.update(reward)
                        if(writer):

                            line = []
                            line.extend(best_leaf.state.min_array)
                            line.extend(best_leaf.state.max_array)
                            line.extend(calc_best_from_node(best_leaf))
                            line.append(reward)
                            line.extend(calc_best_from_node(best_leaf_overall))
                            line.append(best_score_overall)
                            writer.writerow(line)
                            #print line

                            line = []
                            line.extend(sample)
                            line.append(reward)
                            #print line
                            writer_samples.writerow(line)
                        evals+=1

                        if(evals >= itermax):
                            break

                        #print evals, itermax
                        #print reward

                    elif(best_leaf.depth+1 < h_max):
                        if(best_leaf.expand()):
                            expanded_nodes.append(best_leaf)
                            #print "expanded", leaf, leaf.childNodes
                            n_h = h+1
                            #print best_leaf.depth, h
                            if(n_h not in leaves_at_depth ):
                                leaves_at_depth[n_h] = best_leaf.childNodes
                            else:
                                leaves_at_depth[n_h].extend(best_leaf.childNodes)
                            max_depth = max(n_h, max_depth)
                        #print leaf.visits
                            b_max = best_ih
            # remove nodes that have been expanded
            for expanded in expanded_nodes:
                leaf_nodes.remove(expanded)



    # Output some information about the tree - can be omitted
    #if (verbose): print rootnode.TreeToString(0)
    #else: print rootnode.ChildrenToString()
    leaf_nodes = []
    for i in range(max_depth, 0, -1):
        leaf_nodes.extend(leaves_at_depth[i])
        #1print leaf_nodes

        for leaf in leaf_nodes:
            if(leaf.visits >= k):
                break
    return sorted(leaf_nodes, key = lambda c: c.score())[-1] # return the node with the highest mean

    #collect_leaf_nodes(rootnode, leaf_nodes, None)
    #return best_leaf_overall

def f_0(x):
    #if(abs(x[1] -1 )< 0.01):
        return ((1.0/2.0)*(sin(13*x[0]) * sin(27*x[0])) + 0.5 )
    #else:
        #print x
    #    return 0.0

def f_0_noisy(x):
    #if(abs(x[1] -1 )< 0.01):
        return f_0(x)+ (np.random.random()-0.5)/10.0
    #else:
        #print x
    #

def f_1(x):
    if(abs(x[1] -1 )< 0.01):
        return (1.0/2.0)*(sin(13*x[0]) * sin(27*x[0])) + 0.5
    else:
        #print x
        return 0.0

def f_2(x):
    #print "score", abs(x[0] -1 ), x[0]
    #print "x", x
    if(abs(x[0] -1 )< 0.01):
        #print "sucess"
        return 1.0
    else:
        #print x
        return 0.0

def stoSOOTest():
    """ Testing on function f_1
    """

    root = State([0.0], [1.0], K = 3 )
    #root = State([0.0, 0], [1.0, 10], f_1, K = 3)
    #root = State([-1], [30], f_2, K = 3 )
    best_node = stoSOO(root, 1000,f_0,  verbose = True, det = False, output_dir = "./Optimisation")
    print "Best", best_node, best_node.depth, best_node.state._n_splits
    # best = (np.array(best_node.state.max_array) - np.array(best_node.state.min_array))/2.0
    # #print best
    best = calc_best_from_node(best_node)
    print best
    print "Regret", f_0(best) - np.array([0.975599143811574975870826165191829204559326171875])
    # print "Distance", 0.867526 - best[0]
    print "Best Values",


if __name__ == "__main__":
    """ Play a single game to the end using UCT for both players.
    """
    stoSOOTest()





