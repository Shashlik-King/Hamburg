# -*- coding: utf-8 -*-
"""
Created on Sun Nov 28 17:50:07 2021

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
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import cv2


#Reading the image
img = mpimg.imread('im.jpg')
#Printing the image array
# print(img)
# print(img.shape)

#Displaying the image
imgplot = plt.imshow(img)

ax = imgplot.add_subplot(111)
ax.transData.transform([(5, 0), (1,2)])
inv = ax.transData.inverted()
inv.transform((335.175,  247.))

