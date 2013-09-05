import data_io
import pandas as pd
import glob
import ntpath
import data_io


# a bit lame, but it's ok

train_data_dir = "./Competition/train_data"
class index_renamer:
    def __init__(self,suffix):
        self.suffix = suffix

    def index_rename(self, idx):
        return  str(idx) + "_" + str(self.suffix)

def process_indices(X, y, info, file_name):

    r = index_renamer(file_name)
    X = X.rename(index = r.index_rename)
    y = y.rename(index = r.index_rename)
    info = info.rename(index = r.index_rename)

    print "Data to be appended", X.shape,y.shape, file_name
    return X.copy(),y.copy(),info.copy()


def merge_data():
    #print train_data_dir + "/train_pair*"
    train_pairs = glob.glob(train_data_dir + "/*train_pairs*")
    print list(zip(train_pairs, list(xrange(0,4))))

    for i, train_pair in enumerate(train_pairs):
        dir_name = ntpath.dirname(train_pair)
        pref = ntpath.basename(train_pair).split("train_pairs")[0]
        suffix = ntpath.basename(train_pair).split("train_pairs")[-1]
        #print pref, suffix
        info = dir_name + "/" + pref + "train_publicinfo" + suffix
        target = dir_name + "/" + pref + "train_target" + suffix
        print info, pref, suffix
        X = data_io.read_train_pairs(train_pair)
        y = data_io.read_train_target(target)
        inf_data = data_io.read_train_info(info)
        X, y, inf_data = process_indices(X, y, inf_data, i)
        if 'X_merged' not in locals():
            X_merged = X
            y_merged = y
            info_merged = inf_data
        else:
            print "Shape before appending", X_merged.shape, y_merged.shape, X.shape, y.shape
            X_merged = X_merged.append(X)
            y_merged = y_merged.append(y)
            info_merged = info_merged.append(inf_data)
            print "Shape thus far", X_merged.shape, y_merged.shape


    return X_merged, y_merged, info_merged

    # for data in reversed_values:
    #     X = X.append(data[0])
    #     y = y.append(data[1])
    #     info = info.append(data[2])
    # return X,y, info


def main():

    #X = data_io.read_train_pairs()
    #y = data_io.read_train_target()
    #info = data_io.read_train_info()


    #X,y, info = exploit_symmetries(X,y, info)

    X,y, info = merge_data()

    #data_io.save_train_data(X, "./Competition/CEfinal_train_pairs.csv")
    #data_io.save(y, "./Competition/CEfinal_train_target.csv")
    #data_io.save(info, "./Competition/CEfinal_train_publicinfo.csv")

    print X.shape, y.shape

    # print X.shape, y.shape
    # print "-1", len(y[y['Target']==-1])
    # print "0", len(y[y['Target']==0])
    # print "1", len(y[y['Target']==1])

    # X = X.iloc[:10]
    # y = y.iloc[:10]
    # info = info.iloc[:10]

    # data_io.save_train_data(X, "./Competition/CEfinal_train_pairs-sym.csv")
    # data_io.save(y, "./Competition/CEfinal_train_target-sym.csv")
    # data_io.save(info, "./Competition/CEfinal_train_publicinfo-sym.csv")


if __name__=="__main__":
    main()
