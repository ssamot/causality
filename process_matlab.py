import data_io
import pandas as pd
import glob
import os
from natsort import natsorted
from optparse import OptionParser

def add_matlab_samples(X, file_pattern):
    files = natsorted(glob.glob(file_pattern))

    for source_file_name in files:
        print source_file_name
        filename = os.path.basename(source_file_name)[6:-4]
        mdata = pd.read_csv(source_file_name, header = None)
        mdata.index = X.index
        mdata.columns = [filename]
        X = X.join(mdata)
    return X

def merge(prefix, X):
    pr = prefix
    if(pr == "test"):
        pr = "valid"
    file_name = data_io.get_json()["feature_" + pr + "_path_matlab"]
    X = add_matlab_samples(X, "./Models/Matlab/" + prefix + "*.csv")
    print "Saving features with shape", X.shape, "at", file_name
    data_io.save(X, file_name)
    return file_name

def main(valid):
 
    X_train = data_io.load_train_features()
    X_valid = data_io.load_valid_features()
    t_file = merge("train", X_train)
    v_file = merge(valid, X_valid)
    #te_file = merge("test", X_valid)
  

if __name__=="__main__":
    parser = OptionParser()
    parser.add_option("-t", "--type", dest="type",
                  help="'valid' or 'test'", metavar="TYPE")
    (options, args) = parser.parse_args()
    if(options.type is None):
        parser.print_help()
        exit(1)
    main(options.type)
    

