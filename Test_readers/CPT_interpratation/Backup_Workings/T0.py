# -*- coding: utf-8 -*-
"""
Created on Sun Nov 28 20:47:48 2021

@author: SHAK
"""

import tables
from tabulate import tabulate 
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from pylab import *
from numpy import arange
from cycler import cycler
import xlsxwriter
from matplotlib.cm import get_cmap
import seaborn as sns
import matplotlib.pylab as plt
from scipy.optimize import curve_fit
from numpy import exp, loadtxt, pi, sqrt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.widgets import Cursor, Button
import matplotlib.animation as matani
from scipy import stats
from scipy import optimize
from matplotlib.animation import FuncAnimation
import seaborn as sns
sns.set_style('whitegrid')
# import mplcursors
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score
from scipy.stats import linregress
from sqlalchemy import create_engine
import pymysql
import mysql.connector
import itertools
import tkinter as tk
import time
from tkinter import *
# from PIL import Image, ImageTkq

import cv2

refPt1 = []
x1=0
x2=70
y1=0
y2=60

data = {'Ref1':[x1, x2, x1, x1],
        'Ref2':[y1, y1, y1, y2]}
dfref = pd.DataFrame(data)
print(dfref)


def click_Extreme(event, x, y, flags, params):
    global refPt
    global refPt1
    # checking for left mouse clicks
    if event == cv2.EVENT_LBUTTONDOWN:
        refPt = [(x, y)]
       
       
    elif event == cv2.EVENT_LBUTTONUP:

        # print(refPt)
    
        refPt1.append(refPt)
   
        df = pd.DataFrame(refPt1)
        df.columns=['Points']
       
        df=df.Points.apply(lambda x: pd.Series(str(x).split(',')))
        df.columns=['Points1','Points2']
        df['Points1'] = df['Points1'].map(lambda x: x.lstrip('('))
        df['Points2'] = df['Points2'].map(lambda x: x.rstrip(')'))
        # print(df)
        dfjoin = pd.merge(left=df, left_index=True, right=dfref, right_index=True, how='inner')
        dfjoin = dfjoin.apply(pd.to_numeric)
        
        #Rotation Correction of Axis Points to help in Smooth Interpolation
        dfjoin.iloc[(2,0)]=dfjoin.iloc[(0,0)]
        dfjoin.iloc[(3,0)]=dfjoin.iloc[(0,0)]
        dfjoin.iloc[(1,1)]=dfjoin.iloc[(0,1)]
        dfjoin.iloc[(1,2)]=dfjoin.iloc[(0,1)]
        
        print(dfjoin)

        dfjoin.to_excel(r'C:\Users\SHAK\OneDrive - COWI\Desktop\t0\1.xlsx', sheet_name='Sheet1', index=False) 


         
# driver function
if __name__=="__main__":
  
    # reading the image
    img = cv2.imread('im.jpg', 1)
    
    # displaying the image
    cv2.imshow('image', img)
    
    # setting mouse handler for the image
    # and calling the click_event() function
    cv2.setMouseCallback('image', click_Extreme)
 
    # wait for a key to be pressed to exit
    cv2.waitKey(0)
 
    # close the window
    cv2.destroyAllWindows()

                 
            