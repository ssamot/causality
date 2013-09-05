import features.feature_processor as fp
import features.feature_functions as ff
import features.feature_functions_spearman as ffs
import data_io
import pandas as pd
import time



def detailToTarget(detail):
    if(detail == 1):
        return 1
    if(detail == 2):
        return 2
    if(detail == 3 or detail == 4):
        return 0


def detailsToTargets(predictions):
    targets = []
    predictions = predictions.flatten()
    for p in predictions:
        targets.append(p)
    return p





def feature_extractor():


    features = [

                ('A type', ['A','B'], fp.MultiColumnTransform(ff.var_type,0)),
                ('B Type', ['B','A'], fp.MultiColumnTransform(ff.var_type,1)),
                ('Spears R p', ['A','B'], fp.MultiColumnTransform(ff.correlation,0)),

                ('Number of Samples', 'A', fp.SimpleTransform(transformer=len)),

                ('Number of Unique Samples A', 'A', fp.SimpleTransform(transformer=ff.count_unique)),
                ('Number of Unique Samples B', 'B', fp.SimpleTransform(transformer=ff.count_unique)),

                
                ('Spears R Magnitude', ['A','B'], fp.MultiColumnTransform(ff.correlation_magnitude,0)),

                ('Noise Independence A --> B (trees)', ['A','B'], fp.MultiColumnTransform(ff.noise_independence,0)),
                ('Noise Independence B --> A (trees)', ['B','A'], fp.MultiColumnTransform(ff.noise_independence,1)),

                ('Noise Independence A --> B (trees) - overfit', ['A','B'], fp.MultiColumnTransform(ff.noise_independence_overfit,0)),
                ('Noise Independence B --> A (trees) - overfit', ['B','A'], fp.MultiColumnTransform(ff.noise_independence_overfit,1)),


                #('Prediction Node Count A --> B (trees)', ['A','B'], fp.MultiColumnTransform(ff.predict_node_count,0)),
                #('Prediction Node Count B --> A (trees)', ['B','A'], fp.MultiColumnTransform(ff.predict_node_count,1)),

                #('Coefficient of Variation A', ['A','B'], fp.MultiColumnTransform(ff.coefficient_variation,0)),
                #('Coefficient of Variation B', ['B','A'], fp.MultiColumnTransform(ff.coefficient_variation,1)),

                ('Metric Entropy A', ['A','B'], fp.MultiColumnTransform(ff.metric_entropy,0)),
                ('Metric Entropy B', ['B','A'], fp.MultiColumnTransform(ff.metric_entropy,1)),

                ('Uncertainty Coefficient A', ['A', 'B'], fp.MultiColumnTransform(ff.uncertainty_coeff,0)),
                ('Uncertainty Coefficient B', ['B', 'A'], fp.MultiColumnTransform(ff.uncertainty_coeff,1)),

                # ('Prediction Score Overfitting A --> B (trees)', ['A','B'], fp.MultiColumnTransform(ff.predict_overfit,0)),
                # ('Prediction Score Overfitting B --> A (trees)', ['B','A'], fp.MultiColumnTransform(ff.predict_overfit,1)),


                ('Predicts A --> B (trees)', ['A','B'], fp.MultiColumnTransform(ff.predict,0)),
                ('Predicts B --> A (trees)', ['B','A'], fp.MultiColumnTransform(ff.predict,1)),
                ('Predicts U --> B (trees)', ['A','B'], fp.MultiColumnTransform(ff.predict_vs_random,0)),
                ('Predicts U --> A (trees)', ['B','A'], fp.MultiColumnTransform(ff.predict_vs_random,1)),


                ('Predicts A --> B (trees) - overfit', ['A','B'], fp.MultiColumnTransform(ff.predict_overfit,0)),
                ('Predicts B --> A (trees) - overfit', ['B','A'], fp.MultiColumnTransform(ff.predict_overfit,1)),
                ('Predicts U --> B (trees) - overfit', ['A','B'], fp.MultiColumnTransform(ff.predict_vs_random_overfit,0)),
                ('Predicts U --> A (trees) - overfit', ['B','A'], fp.MultiColumnTransform(ff.predict_vs_random_overfit,1)),


                # Entropy normalisation methods
                ('Uniform Symmetrised Divergence A', ['A', 'B'], fp.MultiColumnTransform(ff.uniform_symmetrised_divergence,0)),
                ('Uniform Symmetrised Divergence B', ['B', 'A'], fp.MultiColumnTransform(ff.uniform_symmetrised_divergence,1)),
                ('Uniform Symmetrised Divergence Difference', ['A','B'], fp.MultiColumnTransform(ff.uniform_symmetrised_divergence_difference,0)),

                ('KL Divergence from Normal A', ['A', 'B'], fp.MultiColumnTransform(ff.kl_divergence_normal,0)),
                ('KL Divergence from Normal B', ['B', 'A'], fp.MultiColumnTransform(ff.kl_divergence_normal,1)),
                ('KL Divergence from Normal Difference', ['A','B'], fp.MultiColumnTransform(ff.kl_divergence_normal_difference,0)),

                ('KL Divergence from Uniform A', ['A', 'B'], fp.MultiColumnTransform(ff.kl_divergence_uniform,0)),
                ('KL Divergence from Uniform B', ['B', 'A'], fp.MultiColumnTransform(ff.kl_divergence_uniform,1)),
                ('KL Divergence from Uniform Difference', ['A','B'], fp.MultiColumnTransform(ff.kl_divergence_uniform_difference,0)),





                #('Pearson R p', ['A','B'], fp.MultiColumnTransform(ff.pcorrelation,0)),
                #('Pearson R Magnitude', ['A','B'], fp.MultiColumnTransform(ff.pcorrelation_magnitude,0)),
                #('PCA A', ['A','B'], f.MultiColumnTransform(f.pca,0)),
                #('PCA B', ['A','B'], f.MultiColumnTransform(f.pca,0)),

                ('Noise Independence A --> B (trees) - spearman', ['A','B'], fp.MultiColumnTransform(ffs.noise_independence,0)),
                ('Noise Independence B --> A (trees) - spearman', ['B','A'], fp.MultiColumnTransform(ffs.noise_independence,1)),

                #('ACM A --> B (trees) ', ['A','B'], fp.MultiColumnTransform(ffs.acm,0)),
                #('ACM B --> A (trees) ', ['B','A'], fp.MultiColumnTransform(ffs.acm,1)),


                #('Noise Independence A --> B (svn) - spearman', ['A','B'], fp.MultiColumnTransform(ffs.noise_independence_overfit,0)),
                #('Noise Independence B --> A (svn) - spearman', ['B','A'], fp.MultiColumnTransform(ffs.noise_independence_overfit,1)),


                ]


    combined = fp.FeatureMapper(features)
    return combined


def extract_train_features():

    start = time.time()
    features = feature_extractor()
    header = []
    for h in features.features:
        header.append(h[0])

    print("Reading in the training data")

    X = data_io.read_train_pairs()
    y = data_io.read_train_target()

    #X = X.iloc[1:7]
    #y = y.iloc[1:7]
    print("Extracting features: " + str(X.shape))

    extracted = features.fit_transform(X, y,type_map = data_io.read_train_info());


    elapsed = float(time.time() - start)
    print("Features extracted in " + str(elapsed/60.0) + " Minutes")

    print ("Saving features")
    X = pd.DataFrame(extracted, index = X.index)
    X.columns = header
    data_io.save_train_features(X, y.Target)


    return X

def extract_valid_features():
    start = time.time()
    features = feature_extractor()
    header = []
    for h in features.features:
        header.append(h[0])


    print("Reading the valid pairs")
    X = data_io.read_valid_pairs()

    print("Extracting features")
    # well, no fit data, so y = None
    extracted = features.fit_transform(X,y = None,type_map = data_io.read_valid_info())


    elapsed = float(time.time() - start)
    print("Features extracted in " + str(elapsed/60.0) + " Minutes")

    print ("Saving features")
    X = pd.DataFrame(extracted, index = X.index)
    X.columns = header
    data_io.save_valid_features(X)


def main():
    
    fp.n_threads = int(data_io.get_json()["feature_extraction_threads"]) 
    
    print("extracting train data set features")
    X = data_io.load_train_features()
    if(X is None):
        extract_train_features()
    else:
        print("Feature already extracted!")

    print("extracting valid data set features")
    X = data_io.load_valid_features()
    if(X is None):
        extract_valid_features()
    else:
        print("Feature already extracted!")

if __name__=="__main__":
    main()
