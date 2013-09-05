import csv
from pylab import *
import subprocess

def f_0(x):
    return ((1.0/2.0)*(sin(13*x) * sin(27*x)) + 0.5 )


x=arange(0,1,0.001)

y = f_0(x)

#print x.shape,y.shape
axis([0.0,0.8,0.0, 1.0])
#plot(x,y)
title("Gradient Boosting Classifier")
xlabel('Learning Rate')
ylabel('AUC')


#savefig("./func-0.png")

with open('stoSOO.csv', 'rb') as csvfile:

    spamreader = csv.reader(csvfile, delimiter=',')
    for i, row in enumerate(spamreader):
        print i
        #errorbar([float(row[0])], [f_0(float(row[0]))], yerr=[0.1], fmt='r', capsize=0)
        #errorbar([float(row[1])], [f_0(float(row[1]))], yerr=[0.1], fmt='r', capsize=0)
        plot([float(row[2])], [(float(row[3]))], 'ro')
        #x = '%03d' % n
        savefig("./func-%04d.png" %i)

#ffmpeg -r 10 -b 800 -i func-%04d.png video.mp4

subprocess.call(["ffmpeg","-y",  "-r", "10", "-b", "800", "-i", "func-%04d.png", "GBG.mp4" ])

