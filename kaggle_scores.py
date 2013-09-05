# -*- coding: utf-8 -*-
"""
Created on Tue Jul 16 14:54:23 2013

@author: ssamot
"""

#title           :compMonitor.py
#description     :Sends an email alert if people pass a threshold on the Kaggle public leaderboards
#author          :William Cukierski
#date            :2013-05-06
#python_version  :2.7 
#==============================================================================
from bs4 import BeautifulSoup
import urllib2
import numpy as np
import json
import smtplib #For sending emails
import re

# Competition settings (JSON)
# title = URL of competition
# operator = One of {eq = equals, gt = greater than, lt = less than}
# value = threshold to trigger a warning (usually, a perfect score)
s = json.loads("""[
    {"title":"cause-effect-pairs","operator":"gt","value":0.77}
    ]""")


#==============================================================================

warnings = ""
for competition in range(0,len(s)):

    # Get competition public leaderboard
    try:
        print("Checking " + s[competition]["title"])
        
        page = urllib2.urlopen("http://www.kaggle.com/c/"+s[competition]["title"]+"/leaderboard")
        soup = BeautifulSoup(page.read())

        allLinks = soup.find_all('abbr', "score" )
        allNames = soup.find_all('a', "team-link" )
    except:
        print("Could not resolve competition:" + s[competition]["title"])
        continue

     # Parse public leaderboard values
    w = ""
    leaderboardScores = np.zeros(len(allLinks))
    names = []
    for i in range(0,len(allLinks)):
         leaderboardScores[i] = (allLinks[i].string)
         name = allNames[i].string
         name = name.strip()
         names.append(name)
   
    m = max([len(name) for name in names])
    for i,  name in enumerate(names):
        print name.ljust(m,' '), leaderboardScores[i]
    if s[competition]["operator"]=="eq":
        if  s[competition]["value"] in leaderboardScores:
            w = "WARNING: A score equal to " + str(s[competition]["value"]) + " was found in " + s[competition]["title"]
    elif s[competition]["operator"]=="lt":
        if  s[competition]["value"] > min(leaderboardScores):
            w = "WARNING: A score less than " + str(s[competition]["value"]) + " was found in " + s[competition]["title"]
    elif s[competition]["operator"]=="gt":
        if  s[competition]["value"] < max(leaderboardScores):
            w = "WARNING: A score greater than " + str(s[competition]["value"]) + " was found in " + s[competition]["title"]
    if w != "":
        print(w)
        warnings = warnings + "\n" + w
    

