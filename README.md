Cause Effect Pairs Challenge FirfiD Submission
============================

Pre-requisites:
You need the following installed:
python 2.7.1
python sklearn version 0.13.1
python numpy version 1.7.1
python joblib
python pandas version >=0.11

Matlab
Preferably Debian Based Linux Installation

Kaggle Causality Challenge framework. Mostly based on kaggle's python code code for the challenge.

To train:
A. Configure
1. Put your training data in the following files (or modify file names accordingly):

"train_pairs_path": "./Competition/CEdata_final_train_pairs.csv"
"train_info_path": "./Competition/CEdata_final_train_publicinfo.csv"
"train_target_path": "./Competition/CEdata_final_train_target.csv"

B. Extracting Features

1. Modify SETTINGS.json "feature_extraction_threads" to the number of threads your machine can handle.
2. Run "python fe.py"
3. Add Matlab features by running "./extract_matlab_valid.sh"
4. Merge the futures by running "python process_matlab.py -t valid"

C. Train:

1. Run "python train.py"


To predict:

A. Clean-up

1. Replace ./Competition/CEfinal_valid*.csv with the respective files you are interested in extracting features from. By default this is set to a minimal subset of valid features.
2. Run "./clean.sh"

B. Extracting Features

1. Modify SETTINGS.json "feature_extraction_threads" to the number of threads your machine can handle.
2. Run "python fe.py"
3. Add Matlab features by running "./extract_matlab_valid.sh"
4. Merge the futures by running "python process_matlab.py -t valid"

C. Generating results

5. Run "python predict.py". The results file should be "./Submisions/firfi-tree-trees.csv".