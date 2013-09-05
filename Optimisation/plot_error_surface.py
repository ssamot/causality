import csv
import numpy as np
from sklearn.gaussian_process import GaussianProcess
from matplotlib import pyplot as pl

# Observations and noise
X = []
y = []
with open('stoSOO-samples.csv', 'rb') as csvfile:

    spamreader = csv.reader(csvfile, delimiter=',')
    for i, row in enumerate(spamreader):
        X.append(float(row[0]))
        y.append(float(row[1]))



# Mesh the input space for evaluations of the real function, the prediction and
# its MSE
x = np.atleast_2d(np.linspace(0.05, 0.7, 1000)).T

# Instanciate a Gaussian Process model
gp = GaussianProcess( theta0=1e-2, thetaL=1e-4, thetaU=1e-1,
                     random_start=100, nugget = 0.0001)

# Fit to data using Maximum Likelihood Estimation of the parameters
X = np.array(X, ndmin = 2)
#X = X.T
y = np.array(y, ndmin = 2)
#print X
X = X.T
y = y.T
print X.shape, y.shape
gp.fit(X, y)

# Make the prediction on the meshed x-axis (ask for MSE as well)
y_pred, MSE = gp.predict(x, eval_MSE=True)
sigma = np.sqrt(MSE)

# Plot the function, the prediction and the 95% confidence interval based on
# the MSE
fig = pl.figure()
#pl.plot(x, f(x), 'r:', label=u'$f(x) = x\,\sin(x)$')
pl.plot(X, y, 'r.', markersize=10, label=u'Observations')
pl.plot(x, y_pred, 'b-', label=u'Prediction')
pl.fill(np.concatenate([x, x[::-1]]),
        np.concatenate([y_pred - 1.9600 * sigma,
                       (y_pred + 1.9600 * sigma)[::-1]]),
        alpha=.5, fc='b', ec='None', label='95% confidence interval')
pl.xlabel('Learning Rate')
pl.ylabel('R2')
pl.ylim(-10, 20)
pl.legend(loc='upper left')

pl.savefig("surface.pdf")