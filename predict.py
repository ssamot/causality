import data_io
from train import print_importances, delete_unused_columns
import pkg_resources


def main():

    print "sklearn version", pkg_resources.get_distribution("scikit-learn").version
    print "numpy version", pkg_resources.get_distribution("numpy").version
    print "pandas version", pkg_resources.get_distribution("pandas").version
    print("Loading the classifier")
    clf = data_io.load_model()

    X = data_io.load_matlab_valid_features()
    X = delete_unused_columns(X)
    X = X.fillna(0)
    
    if(X is None):
        print("No feature file found!")
        exit(1)

    print_importances(X,clf, 0.0)
    print("Predictions outcomes with shape: " + str(X.shape))
    print clf
    predictions = clf.predict(X)
    #predictions = clf.predict_pruned(X,3000)
   
    predictions = predictions.flatten()
    
   
    print("Writing predictions to file")
    data_io.write_submission(predictions)

if __name__=="__main__":
    main()