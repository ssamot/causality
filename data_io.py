import csv
import json
import numpy as np
import os
import pandas as pd
import pickle


config_file = "SETTINGS.json"

def get_paths():
    paths = json.loads(open(config_file).read())
    return paths
    
def get_json():
    return json.loads(open(config_file).read())
    
def save_json(config):
    json_file = open(config_file, "w")
    
    json_file.write(json.dumps(config, sort_keys=True, indent=4))
    json_file.close()
    

def parse_dataframe(df):
    parse_cell = lambda cell: np.fromstring(cell, dtype=np.float, sep=" ")
    df = df.applymap(parse_cell)
    return df

def read_train_pairs(path = None):
    if(path == None):
        path = get_paths()["train_pairs_path"]


    for i, chunk in enumerate(pd.read_csv(path, index_col="SampleID", chunksize=10000)):
        print "Reading chunk ", i
        X_c = parse_dataframe(chunk)
        if 'X' not in locals():
            X = X_c
        else:
            X = X.append(X_c)
        print X.shape

    return X
    #return parse_dataframe()

def read_train_target(path = None):
    if(path == None):
         path = get_paths()["train_target_path"]
    df = pd.read_csv(path, index_col="SampleID")
    df = df.rename(columns = dict(zip(df.columns, ["Target", "Details"])))
    return df

def read_train_info(path = None):
    if(path == None):
        path = get_paths()["train_info_path"]
    return pd.read_csv(path, index_col="SampleID")

def read_valid_pairs():
    valid_path = get_paths()["valid_pairs_path"]
    return parse_dataframe(pd.read_csv(valid_path, index_col="SampleID"))

def read_valid_info():
    path = get_paths()["valid_info_path"]
    return pd.read_csv(path, index_col="SampleID")

def read_solution():
    solution_path = get_paths()["solution_path"]
    return pd.read_csv(solution_path, index_col="SampleID")

def save_model(model):
    out_path = get_paths()["model_path"]
    pickle.dump(model, open(out_path, "w"))

def save_train_features(X,y):
    feature_path = get_paths()["feature_train_path"]
    X.to_csv(feature_path);

def save(X,file_name):
    X.to_csv(file_name)


def save_train_data(X,file_name):
    #print X.values
    writer = csv.writer(open(file_name, "w"), lineterminator="\n")
    writer.writerow(["SampleID","A","B"])
    for i,x in enumerate(X.T.iteritems()):
        s_id = x[0]

        #print x, type(x), len(x),x[1][1]
        A = ' '.join(map(str, x[1][0]))
        B = ' '.join(map(str, x[1][1]))

        writer.writerow([s_id,A,B])
        print s_id


def save_valid_features(X):
    feature_path = get_paths()["feature_valid_path"]
    X.to_csv(feature_path);

def load_features(feature_path):
    try:
        with open(feature_path):
            X = pd.io.parsers.read_csv(feature_path, index_col=0)
            return X
    except IOError:
        print "Feature file not found " + feature_path
        return None

def load_train_features():
    feature_path = get_paths()["feature_train_path"]
    return load_features(feature_path)

def load_valid_features():
    feature_path = get_paths()["feature_valid_path"]
    return load_features(feature_path)

def load_matlab_valid_features():
    feature_path = get_paths()["feature_valid_path_matlab"]
    return load_features(feature_path)

def load_matlab_train_features():
    feature_path = get_paths()["feature_train_path_matlab"]
    return load_features(feature_path)

def load_model():
    in_path = get_paths()["model_path"]
    return pickle.load(open(in_path))

def read_submission():
    submission_path = get_paths()["submission_path"]
    return pd.read_csv(submission_path, index_col="SampleID")

def write_submission(predictions):
    submission_path = get_paths()["submission_path"]
    writer = csv.writer(open(submission_path, "w"), lineterminator="\n")
    valid = read_valid_pairs()
    rows = [x for x in zip(valid.index, predictions)]
    writer.writerow(("SampleID", "Target"))
    writer.writerows(rows)

def write_dummy(predictions,f):
    submission_path = "./test2.csv"
    writer = csv.writer(open(submission_path, "w"), lineterminator="\n")
    header = []
    for r in f:
        header.append(r[0])
    #valid = read_valid_pairs()
    #rows = [x for x in zip(valid.index, predictions)]
    writer.writerow(header)
    writer.writerows(predictions)

