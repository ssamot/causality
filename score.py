import ml_metrics as metrics

def forward_auc(labels, predictions):
    target_one = [1 if x==1 else 0 for x in labels]
    score = metrics.auc(target_one, predictions)
    return score

def reverse_auc(labels, predictions):
    target_neg_one = [1 if x==-1 else 0 for x in labels]
    neg_predictions = [-x for x in predictions]
    score = metrics.auc(target_neg_one, neg_predictions)
    return score

def bidirectional_auc(labels, predictions):
    score_forward = forward_auc(labels, predictions)
    score_reverse = reverse_auc(labels, predictions)
    score = (score_forward + score_reverse) / 2.0
    return score

if __name__=="__main__":
    import pandas as pd
    import data_io
    
    solution = data_io.read_solution()
    submission = data_io.read_submission()

    score_forward = forward_auc(solution.Target, submission.Target)
    print("Forward Auc: %0.6f" % score_forward)

    score_reverse = reverse_auc(solution.Target, submission.Target)
    print("Reverse Auc: %0.6f" % score_reverse)

    score = bidirectional_auc(solution.Target, submission.Target)
    print("Bidirectional AUC: %0.6f" % score)