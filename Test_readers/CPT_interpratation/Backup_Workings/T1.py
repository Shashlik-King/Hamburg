# -*- coding: utf-8 -*-
"""
Created on Tue Nov 30 00:17:33 2021

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




data = {'RefX':[x1, x2, x1, x1],
        'RefY':[y1, y1, y1, y2]}
dfref = pd.DataFrame(data)
# print(dfref)


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
        dfjoin.iloc[(2,1)]=dfjoin.iloc[(0,1)]
        
        # print(dfjoin)
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
    
   
class DrawLineWidget(object):
    def __init__(self):
        self.original_image = cv2.imread('im.jpg')
        self.original_image  = cv2.resize(self.original_image,None,fx=1,fy=1, interpolation = cv2.INTER_CUBIC)

        self.clone = self.original_image.copy()


        cv2.namedWindow('image')
        cv2.setMouseCallback('image', self.extract_coordinates)

        # List to store start/end points
        self.image_coordinates = []

    def extract_coordinates(self, event, x, y, flags, parameters):
        # Record starting (x,y) coordinates on left mouse button click
        
        if event == cv2.EVENT_LBUTTONDOWN:
            self.image_coordinates = [(x,y)]

        # Record ending (x,y) coordintes on left mouse bottom release
        elif event == cv2.EVENT_LBUTTONUP:
            self.image_coordinates.append((x,y))
            print('Starting: {}, Ending: {}'.format(self.image_coordinates[0], self.image_coordinates[1]))

            # Draw line
            cv2.line(self.clone, self.image_coordinates[0], self.image_coordinates[1], (0,250,10), 2)
            cv2.imshow("image", self.clone) 

            dfline = pd.DataFrame(self.image_coordinates)
            dfline.columns=['XPointsLine','YPointsLine']
            print(dfline)
            # dfjoin.to_excel(r'C:\Users\SHAK\OneDrive - COWI\Desktop\t0\1.xlsx', sheet_name='Sheet1', index=False) 
            # dfline.to_excel(r'C:\Users\SHAK\OneDrive - COWI\Desktop\t0\1.xlsx', sheet_name='Sheet2', index=False) 
            

        # Clear drawing boxes on right mouse button click
        elif event == cv2.EVENT_RBUTTONDOWN:
            self.clone = self.original_image.copy()

    def show_image(self):
        return self.clone

if __name__ == '__main__':
    draw_line_widget = DrawLineWidget()
    while True:
        cv2.imshow('image', draw_line_widget.show_image())
        key = cv2.waitKey(1)

        # Close program with keyboard 'q'
        if key == ord('c'):
            cv2.destroyAllWindows()
            exit(1)


