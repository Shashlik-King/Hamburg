# -*- coding: utf-8 -*-
"""
Created on Tue Nov 30 20:00:09 2021

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


FilePath = r'C:\Users\SHAK\OneDrive - COWI\Desktop\t0\1.xlsx'
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