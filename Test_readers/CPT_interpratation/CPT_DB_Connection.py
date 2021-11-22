# -*- coding: utf-8 -*-
"""
Created on Mon Nov 22 10:56:43 2021

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


db_connection_str = 'mysql+pymysql://owdb_user:ituotdowdb@172.30.112.80/owdb'
print(db_connection_str)

db_connection = create_engine(db_connection_str)
df_CPT = pd.read_sql("SELECT * FROM cpt_data WHERE (Project_name,bh,rev) = ('EW2','BH-46','01') or (Project_name,bh,rev) = ('TPC2','DH-01','01')", con=db_connection)
df_Strata = pd.read_sql("SELECT * FROM stratigraphy WHERE (project_name,bh,rev) = ('EW2','BH-46','01') or (project_name,bh,rev) = ('TPC2','DH-01','01')", con=db_connection)
# df_CPT.columns += '_1'
# df_Strata.columns += '_2'
df_CPT=df_CPT.add_prefix('1_')
df_Strata=df_Strata.add_prefix('2_')



# idx = pd.IntervalIndex.from_arrays(df_Strata['top'], df_Strata['bottom'], closed='both')
# unit = df_Strata.iloc[idx.get_indexer(df_CPT.depth), 'unit']
# df_CPT['unit'] = unit.to_numpy()

Strata_top = df_Strata['2_top'].values
Strata_bottom = df_Strata['2_bottom'].values
Strata_projectname = df_Strata['2_project_name'].values
Strata_bh = df_Strata['2_bh'].values

CPT_depth = df_CPT['1_depth'].values[:, None]
CPT_projectname = df_CPT['1_Project_name'].values[:, None]
CPT_bh = df_CPT['1_bh'].values[:, None]

mask = (Strata_projectname == CPT_projectname) & (Strata_bh == CPT_bh) & (Strata_top <= CPT_depth) & (CPT_depth <= Strata_bottom)
CPT_Unit = np.argmax(mask, axis=1)
print(CPT_Unit)
df_CPTOutput=df_CPT.assign(CPT_Unit=CPT_Unit).join(df_Strata, on='CPT_Unit')
cols = df_CPTOutput.columns.tolist()
cols = cols[0:25] + cols[33:]
print(cols)


# #Trial1
# idx = pd.IntervalIndex.from_arrays(df_Strata['top'], df_Strata['bottom'], closed='both')
# df_Strata.index=idx
# df_CPT['unit']=df_Strata.loc[df_CPT.depth,'unit'].values

# #Trial2
# df_Strata['depth']=df_Strata['bottom']
# # pd.merge_asof(df_CPT,df_Strata[['depth','bottom']].sort_values('depth'),on='depth')
# pd.merge_asof(df_CPT,df_Strata[['depth','bottom']].sort_values('bottom'),on='bottom',direction ='forward',allow_exact_matches =True)
