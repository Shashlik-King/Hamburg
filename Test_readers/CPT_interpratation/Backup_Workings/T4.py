# -*- coding: utf-8 -*-
"""
Created on Tue Nov 30 22:08:46 2021

@author: SHAK
"""

"""
Created on Tue Nov 30 16:24:53 2021

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
from openpyxl import load_workbook
# from PIL import Image, ImageTkq
import cv2




refPt1 = []
imagecoordinates = []
x1=0
x2=70
y1=0
y2=60
FilePath = r'C:\Users\SHAK\OneDrive - COWI\Desktop\t0\1.xlsx'
ExcelWorkbook = load_workbook(FilePath)
writer = pd.ExcelWriter(FilePath, engine = 'openpyxl')

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
        font = cv2.FONT_HERSHEY_SIMPLEX
        cv2.putText(img, str(x) + ',' +
                    str(y), (x,y), font,
                    1, (255, 0, 0), 2)
        cv2.imshow('image', img)
       
       
    elif event == cv2.EVENT_LBUTTONUP:
   

        # print(refPt)
    
        refPt1.append(refPt)
        # b = img[y, x, 0]
        # g = img[y, x, 1]
        # r = img[y, x, 2]
        # cv2.putText(img, str(b) + ',' +
        #             str(g) + ',' + str(r),
        #             (x,y), font, 1,
        #             (255, 255, 0), 2)
        
        
        
        
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
        dfjoin.to_excel(writer, sheet_name = 'Data1')
        writer.save()
        writer.close()
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
                 imagecoordinates.append(self.image_coordinates)
     
                 dfline = pd.DataFrame(imagecoordinates)
                 dfline.columns=['XPointsLine','YPointsLine']
                 dfline1=dfline.XPointsLine.apply(lambda x: pd.Series(str(x).split(',')))
                 dfline2=dfline.YPointsLine.apply(lambda x: pd.Series(str(x).split(',')))
                 dfjoinline = pd.merge(left=dfline1, left_index=True, right=dfline2, right_index=True, how='inner')
                 dfjoinline.columns=['X1','Y1','X2','Y2']
                 dfjoinline['X1'] = dfjoinline['X1'].map(lambda x: x.lstrip('('))
                 dfjoinline['Y1'] = dfjoinline['Y1'].map(lambda x: x.rstrip(')'))
                 dfjoinline['X2'] = dfjoinline['X2'].map(lambda x: x.lstrip('('))
                 dfjoinline['Y2'] = dfjoinline['Y2'].map(lambda x: x.rstrip(')'))
                 dfjoinline = dfjoinline.apply(pd.to_numeric)
                 print(dfjoinline)
                 dfjoinline.to_excel(writer, sheet_name = 'Data2')
                 writer.save()
                 writer.close()

                 
     
             # Clear drawing boxes on right mouse button click
             elif event == cv2.EVENT_RBUTTONDOWN:
                 self.clone = self.original_image.copy()

         # dfline.to_excel(writer, sheet_name = 'Data2')
         # writer.save()
         # writer.close()
        


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
    
   
# Scaling to convert Pixels to Graphical CPT units    
dfdata1 = pd.read_excel(FilePath, sheet_name='Data1', usecols = "B:E")
dfdata2a = pd.read_excel(FilePath, sheet_name='Data2', usecols = "B:C")
dfdata2a.columns=['Points1','Points2']

dfdata2b = pd.read_excel(FilePath, sheet_name='Data2', usecols = "D:E")
dfdata2b.columns=['Points1','Points2']

result1 = dfdata1.append([dfdata2a])
result2 = dfdata1.append([dfdata2b])
result1 = result1.rename({'Points1': 'IX1', 'Points2': 'IY1'}, axis=1)
result2 = result2.rename({'Points1': 'IX2', 'Points2': 'IY2'}, axis=1)
# result1 = result1.apply(pd.to_numeric)
# print(result1)
result1['RefX'] = result1.set_index('IX1')['RefX'].interpolate('index').values
result1['RefY'] = result1.set_index('IY1')['RefY'].interpolate('index').values
result2['RefX'] = result2.set_index('IX2')['RefX'].interpolate('index').values
result2['RefY'] = result2.set_index('IY2')['RefY'].interpolate('index').values
result1 = result1.rename({'RefX': 'X1', 'RefY': 'Y1'}, axis=1)
result1= result1.reset_index(drop=True)
result2 = result2.rename({'RefX': 'X2', 'RefY': 'Y2'}, axis=1)
result2 = result2.reset_index(drop=True)
print(result1)
print(result2)
FinalResult = result1.merge(result2,left_index=True, right_index=True)
FinalResult = FinalResult.reindex(columns=['IX1','IY1','IX2','IY2','X1','Y1','X2','Y2'])
print(FinalResult)   
FinalResult.to_excel(writer, sheet_name = 'CPT Values')
writer.save()
writer.close()
