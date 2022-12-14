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
import itertools

def connection():

    db_connection_str = 'mysql+pymysql://owdb_user:ituotdowdb@172.30.112.80/owdb'
    print(db_connection_str)
    Project = "'EW2'"
    Borehole = "'BH-46'"
    Rev = "'01'"
    Str1 = "SELECT * FROM cpt_data WHERE (Project_name,bh,rev) = "
    Str2 = "("+Project +","+ Borehole +","+ Rev+")"
    Str3 = Str1+Str2
    Str4 = "SELECT * FROM stratigraphy WHERE (project_name,bh,rev) = "
    Str5 = Str4+Str2
    
    
    
    db_connection = create_engine(db_connection_str)
    
    # df_CPT = pd.read_sql("SELECT * FROM cpt_data WHERE (Project_name,bh,rev) = ('EW2','BH-46','01') or (Project_name,bh,rev) = ('TPC2','DH-01','01')", con=db_connection)
    # df_Strata = pd.read_sql("SELECT * FROM stratigraphy WHERE (project_name,bh,rev) = ('EW2','BH-46','01') or (project_name,bh,rev) = ('TPC2','DH-01','01')", con=db_connection)
    
    
    df_CPT = pd.read_sql(Str3, con=db_connection)
    df_Strata = pd.read_sql(Str5, con=db_connection)
    
    
    
    df_CPT=df_CPT.add_prefix('1_')
    df_Strata=df_Strata.add_prefix('2_')
    
    
    Strata_top = df_Strata['2_top'].values
    Strata_bottom = df_Strata['2_bottom'].values
    Strata_projectname = df_Strata['2_project_name'].values
    Strata_bh = df_Strata['2_bh'].values
    
    CPT_depth = df_CPT['1_depth'].values[:, None]
    CPT_projectname = df_CPT['1_Project_name'].values[:, None]
    CPT_bh = df_CPT['1_bh'].values[:, None]
    
    mask = (Strata_projectname == CPT_projectname) & (Strata_bh == CPT_bh) & (Strata_top <= CPT_depth) & (CPT_depth <= Strata_bottom)
    CPT_Unit = np.argmax(mask, axis=1)
    df_CPTOutput=df_CPT.assign(CPT_Unit=CPT_Unit).join(df_Strata, on='CPT_Unit')
    
    
    
    df_CPTOutput.drop(df_CPTOutput.columns[26:32], axis=1, inplace=True)
    df_CPTOutput.drop(df_CPTOutput.columns[27:32], axis=1, inplace=True)
    df_CPTOutput.drop(df_CPTOutput.columns[25], axis=1, inplace=True)
    df_CPTOutput.drop(df_CPTOutput.columns[20], axis=1, inplace=True)
    df_CPTOutput.columns = df_CPTOutput.columns.str.lstrip("1_")
    df_CPTOutput.columns = df_CPTOutput.columns.str.lstrip("2_")
    
    
    df_CPTOutput.drop(df_CPTOutput.columns[20:24], axis=1, inplace=True)
    df_CPTOutput.drop(df_CPTOutput.columns[2:4], axis=1, inplace=True)
    df_CPTOutput.drop(df_CPTOutput.columns[11:13], axis=1, inplace=True)
    df_CPTOutput.drop(df_CPTOutput.columns[0], axis=1, inplace=True)
    
    df_CPTOutput.rename(columns={'bh': 'BH','depth': 'Depth [m]','qc': 'SBH_RES','fres': 'SBH_FRES','pwp2': 'SBH_PWP2',
                        'frr': 'SBH_FRR','qt': 'SBH_QT','ft': 'SBH_FT','qe': 'SBH_QE','bden': 'SBH_BDEN','qnet': 'SBH_QNET',
                        'frrc': 'SBH_FRRC','bq': 'SBH_BQ','nqt': 'SBH_NQT','nfr': 'SBH_NFR','unit': 'Unit'},
              inplace=True, errors='raise')
    df_CPTOutput = df_CPTOutput.replace(to_replace = ["None"], value=0)
    df_CPTOutput = df_CPTOutput.replace(to_replace = np.nan, value = 0)
    df_CPTOutput['Unit'] = df_CPTOutput['Unit'].astype(str) + "S"
    print(df_CPTOutput)
    return df_CPTOutput
    

