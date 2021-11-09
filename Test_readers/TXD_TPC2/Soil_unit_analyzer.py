# -*- coding: utf-8 -*-
"""
Created on Thu Oct 21 18:02:34 2021

@author: CGQU
"""


import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
import scipy.optimize as opt
import math
import numpy as np
import pandas as pd
from math import *
import os, xlsxwriter
from Paramis_xlsx_writer import *
import pdb
import codecs
from os import walk
import sys

sys.path.append(r'C:\Users\CGQU\OneDrive - COWI\Desktop\SVN_paramis\sqlconnect')
import sql_connect


get_ipython().run_line_magic('matplotlib', 'qt')
# %matplotlib inline
##############################################################################################################
#----------------------------------------- Reading from database --------------------------------------------#
##############################################################################################################

copilod = sql_connect.Copilod("owdb")#, user = 'users', password = 'password', host = 'host')
copilod.connect()
#Inventory_mysql = copilod.get_table('Test_inventory_DSS_CSS',outlier= "0", DSSG_TYPE = "CDSS" )
Inventory_mysql = copilod.get_table('Test_inventory_CID')
used_tests=Inventory_mysql[Inventory_mysql["Use"]==1]

control = copilod.get_table('Control_panel',Active=1)

Project_name=control['project_name'][0]

stratigraphy = copilod.get_table('stratigraphy',project_name=Project_name)

Sample_results= copilod.get_table('output_CID')

cpt_data= copilod.get_table('cpt_data',Project_name=Project_name)

copilod.close() 
##############################################################################################################
#------------------------------ Finding tests for selected soil units ---------------------------------------#
##############################################################################################################

for i in range(len(control)):
    
    indx=[]
    Soil_unit=control['Soil_unit'].values.tolist()[i]
    
    for j in range(len(Sample_results)):
        print(j)
        BH = Sample_results['LOCA_ID'][j]
        depth = Sample_results['Depth'][j]
        
        stratrigraphy_BH=stratigraphy[stratigraphy['bh']==BH][stratigraphy['top']<=depth][stratigraphy['bottom']>depth]
        
        if len(stratrigraphy_BH)>0:
            
            Sample_soil_unit=stratrigraphy_BH['unit'].values.tolist()[0]
            
            if Sample_soil_unit==Soil_unit:
                indx.append(j)
                
    Location_sample=Sample_results['LOCA_ID'][indx].values.tolist()
    phi_TX=Sample_results['phi'][indx].values.tolist()
    depth_TX=Sample_results['Depth'][indx].values.tolist()
    average_qc=[]                                               # No values from qt, qc used instead, to be substituted once database is populated
    
    for j in range(len(indx)):   
        
        top_bound = depth_TX[j]-0.5
        bot_bound = depth_TX[j]+0.5
        
        cpt_data_bh=cpt_data[cpt_data['bh']==Location_sample[j]]
        
        cpt_data_sample_0=cpt_data_bh[cpt_data_bh['depth']>(top_bound)]
        cpt_data_sample=cpt_data_sample_0[cpt_data_sample_0['depth']<(bot_bound)]
        average_qc.append(sum(cpt_data_sample['qc'].dropna().values.tolist())/len(cpt_data_sample['qc'].dropna().values.tolist()))  # No values from qt, qc used instead, to be substituted once database is populated
    
    plt.figure(figsize=(8,5))
    #plt.scatter(phi_TX,depth_TX)
    plt.scatter(average_qc,phi_TX)
        
        
        