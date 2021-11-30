# -*- coding: utf-8 -*-
"""
Created on Thu Nov 25 16:47:15 2021

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

from PIL import Image
from pylab import *

# read image to array
im = array(Image.open('im.jpg'))

# plot the image
imshow(im)

# some points
x = [100,100,400,400]
y = [200,500,200,500]

# plot the points with red star-markers
plt.plot(x,y,'r*')


# line plot connecting the first two points
plt.plot(x[:2],y[:2])
plt.ylim(0,1000)
plt.xlim(0,1000)

# add title and show the plot
plt.title('Plotting: "im.jpg"')
plt.show()