# -*- coding: utf-8 -*-
"""
Created on Thu Nov  5 12:58:09 2020

@author: CGQU

"""
import numpy as np
import pandas as pd
from math import *
import os, xlsxwriter
from TXD_translator import *
from Paramis_xlsx_writer import *
from os import walk
import sys

sys.path.append(r'C:\Users\CGQU\OneDrive - COWI\Desktop\SVN_paramis\sqlconnect')
import sql_connect

##############################################################################################################
#--------------------------------- Reading test to convert from database ------------------------------------#
##############################################################################################################

copilod = sql_connect.Copilod("owdb")#, user = 'users', password = 'password', host = 'host')
copilod.connect()
#Inventory_mysql = copilod.get_table('Test_inventory_DSS_CSS',outlier= "0", DSSG_TYPE = "CDSS" )
Inventory_mysql = copilod.get_table('Test_inventory_CID')
used_tests=Inventory_mysql[Inventory_mysql["Use"]==1]
copilod.close() 

##############################################################################################################
#----------------------------------------- Functions and classes --------------------------------------------#
##############################################################################################################

class Triaxial_tests():
    
    def __init__(self, Conf, Eini,eps1,S3,S1,p,q,pwp,epsV): 
        self.conf_pressure=Conf
        self.Eini=Eini        
        self.eps1=eps1 
        self.S3=S3
        self.S1=S1
        self.p=p
        self.q=q
        self.pwp=pwp
        self.epsV=epsV
        self.qsimulation=[]
        self.epsS = self.eps1-(self.epsV - self.eps1)/2
        self.SS = (self.S1-self.S3)/2   
        
def unique(list1): 
  
    # intilize a null list 
    unique_list = [] 
      
    # traverse for all elements 
    for x in list1: 
        # check if exists in unique_list or not 
        if x not in unique_list: 
            unique_list.append(x)
    return  unique_list

##############################################################################################################
#------------------------------------- Inputs from database -------------------------------------------------#
##############################################################################################################

cwd = os.getcwd()
test_folder=cwd+"\TX_tests"

file_names = []
BH_names = []
Samp_ref_names = []
Tests_type = []
Test_name = []
Dr =[]
e_0 = []
e_min=[]
e_max=[]

for j in range(len(used_tests)):
    #name=used_tests["PointID"].values.tolist()[j]+"_"+used_tests["Samp_Ref"].values.tolist()[j]
    BH_names.append(used_tests["LOCA_ID"].values.tolist()[j])
    Samp_ref_names.append(used_tests["Samp_ID"].values.tolist()[j])
    Tests_type.append(used_tests["Test_type"].values.tolist()[j])
    #Dr.append(used_tests["Initial DR"].values.tolist()[j])
    e_0.append((used_tests["Specific_Gravity"].values.tolist()[j]*9.81/(used_tests["Initial_Dry_Unit_Weight"].values.tolist()[j]*9.81))-1)
    #e_min.append(used_tests["emin"].values.tolist()[j])
    #e_max.append(used_tests["emax"].values.tolist()[j])
    
##############################################################################################################
#------------------------- Matching real tests names with input from Database -------------------------------#
##############################################################################################################
    
for (dirpath, dirnames, filenames) in walk(test_folder):
    file_names.extend(filenames)
    break

final_tests=[]
for x in range(len(BH_names)):
    for z in range(len(file_names)):
        if (BH_names[x] in file_names[z]) and (Samp_ref_names[x] in file_names[z]) and (Tests_type[x] in file_names[z]):
            final_tests.append(file_names[z])
            break
        
final_tests=unique(final_tests)
Samp_ref_names=unique(Samp_ref_names)
BH_names=unique(BH_names)

BH_final=[]
for i in range(len(final_tests)):
    for x in range(len(BH_names)):
        if BH_names[x] in final_tests[i]:
            BH_final.append(BH_names[x])
            break
        
Samp_final=[]
for i in range(len(final_tests)):
    for x in range(len(Samp_ref_names)):
        if Samp_ref_names[x] in final_tests[i]:
            Samp_final.append(Samp_ref_names[x])
            break

##############################################################################################################
#------------------------------ Reading the tests and defining variales -------------------------------------#
##############################################################################################################

All_tests_data={}
test_name=[]

os.chdir(cwd+"\TX_tests")

for tests in np.arange(len(final_tests)):
    
       
    filename=final_tests[tests] 
    
    xl = pd.ExcelFile(filename)
    excel_sheets=(xl.sheet_names)
    
    for i in range(3):
        
        Initial_cell_pressure, df = TPC(filename,excel_sheets,i)
        dataname=BH_final[tests]+"_"+Samp_final[tests]+"_"+str(round(Initial_cell_pressure))
        
        S1 = df.p + (2*df.q/3)
        S3 = df.p - (df.q/3)
        
        All_tests_data[dataname]=Triaxial_tests(Initial_cell_pressure, e_0[tests], np.divide(df.eps1,100),S3,S1,df.p,df.q,df.Excess_PWP, np.divide(df.epsv,100))
        #All_tests_data[dataname]=Triaxial_tests(Initial_cell_pressure, e_0[tests], df.eps1,S3,S1,df.p,df.q,df.Excess_PWP, df.epsv)
        
        test_name.append(dataname)
        
##############################################################################################################
#------------------------------ Writing formmated xlsx with test data-- -------------------------------------#
##############################################################################################################

os.chdir(cwd)
cwd2= cwd.replace('Test_readers\TXD_TPC2', 'Post_process\TXD')    
os.chdir(cwd2)    
write_postprocessing(All_tests_data,test_name)
os.chdir(cwd)


    
   
  