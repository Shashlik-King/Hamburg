# -*- coding: utf-8 -*-
"""
Created on Mon Dec 14 09:21:29 2020

@author: CGQU
"""

import os, sys, math
import pandas as pd
import csv, xlsxwriter
import numpy as np
import xlrd
from Inp_writing_functions import *
from scipy.interpolate import interp1d
import re
import matplotlib.pyplot as plt
#from test_classes import *

file = 'Input_paramis.xlsx'
xl = pd.ExcelFile(file)
excel_sheets=(xl.sheet_names)
df_test=xl.parse(excel_sheets[0])
df_param=pd.read_excel(file,sheet_name=excel_sheets[1],skiprows=3)
cwd = os.getcwd()

workbook = xlrd.open_workbook(file)
worksheet = workbook.sheet_by_name('Constitutive model')

Constitutive_model= worksheet.cell(0, 1).value
Nstate_var = worksheet.cell(1, 1).value


class real_test():    
    def __init__(self,test_type,test_name,X,Y,Z):
        self.X=np.array(X)
        self.Y=np.array(Y)
        self.Z=np.array(Z)
        self.test_type=test_type
        self.test_name=test_name
        
class All_tensors():
    def __init__(self,stress,strain):
        self.stress=stress
        self.strain=strain
        
class simulated_test():
    def __init__(self,var,X_hat,Y_hat):
        self.parm_var=var
        self.X_hat=np.array(X_hat)
        self.Y_hat=np.array(Y_hat)


##############################################################################################################
#------------------------------------------- Input Parameters -----------------------------------------------#
##############################################################################################################
        
var_dict={}
const_dict={}
all_var_dict={}
bound_dict={}

for z in range(len(df_param)):
    if df_param['Constant/Variable'][z]==0:
        const_dict[df_param['Parameters'][z]]=df_param['Init_Value'][z]
        all_var_dict[df_param['Parameters'][z]]=df_param['Init_Value'][z]
    else:
        var_dict[df_param['Parameters'][z]]=df_param['Init_Value'][z]
        all_var_dict[df_param['Parameters'][z]]=df_param['Init_Value'][z]
        bound_dict[df_param['Parameters'][z]]=[df_param['LB'][z],df_param['UB'][z]]
        
const_names=list(const_dict.keys())
const_values=list(const_dict.values())
var_names=list(var_dict.keys())
var_values=list(var_dict.values())
all_var_names=list(all_var_dict.keys())
# =============================================================================

##############################################################################################################
#------------------------------------------- WRITING INPUT FILES --------------------------------------------#
##############################################################################################################

try:
    os.mkdir('Input_files')
except OSError:
    print ("Creation of the directory failed")
else:
    print ("Successfully created the directory")
    
os.chdir(cwd+"\Input_files")
cwd2 = os.getcwd()

def forwardmodel(df_test,xl,cwd2,df_param,Constitutive_model,Nstate_var):
    alldata=[]
    allSimulated=[]


    for j in range(len(df_test['File_name'].values.tolist())):
        if int(df_test['Use_test'][j])==1:
            
            test_name=[df_test['File_name'][j]]

            #------------------------------------ WRITING TEST.INP ----------------------------------------#
            
            if df_test['Test_type'][j]=='DSS':
                df=xl.parse(excel_sheets[2])
                indx=df["File_name"].values.tolist().index(df_test['File_name'].values.tolist()[j])
                            
                write_DSS_inp(df_test['File_name'][j],df,indx)         # Writing test.inp            
               
            elif df_test['Test_type'][j]=='TX':
                df=xl.parse(excel_sheets[3])
                indx=df["File_name"].values.tolist().index(df_test['File_name'].values.tolist()[j])
                
                write_TX_inp(df_test['File_name'][j],df,indx)          # Writing test.inp  
                sigma_initial=sigma_test(df_test['Test_type'][j],df,indx)
                
                write_initial_cond(df_test['File_name'][j],df,indx,sigma_initial,Nstate_var)
                
            elif df_test['Test_type'][j]=='CyclicTX':
                df=xl.parse(excel_sheets[4])
                indx=df["File_name"].values.tolist().index(df_test['File_name'].values.tolist()[j])
                
                write_CyclicTX_inp(df_test['File_name'][j],df,indx)    # Writing test.inp  
                sigma_initial=sigma_test(df_test['Test_type'][j],df,indx)
                
                write_initial_cond(df_test['File_name'][j],df,indx,sigma_initial,Nstate_var)
                
            elif df_test['Test_type'][j]=='Oed':
                df=xl.parse(excel_sheets[5])
                indx=df["File_name"].values.tolist().index(df_test['File_name'].values.tolist()[j])
                
                write_Oed_inp(df_test['File_name'][j],df,indx)         # Writing test.inp 
                sigma_initial=sigma_test(df_test['Test_type'][j],df,indx)
                
                write_initial_cond(df_test['File_name'][j],df,indx,sigma_initial,Nstate_var)
    
           #------------------------------------ WRITING INITIAL CONDITIONS.INP -----------------------------------------#
                
            sigma_initial=sigma_test(df_test['Test_type'][j],df,indx)
                
            write_initial_cond(df_test['File_name'][j],df,indx,sigma_initial,Nstate_var)        # Writing initial conditions.inp
            
           #----------------------------------------- WRITING PARAMETERS.INP --------------------------------------------#
            
            #write_params(var_name,const_name,var_val,con_val) 
           
            write_params(all_var_names,const_names,const_values,var_names,var_values,Constitutive_model)                                  # Writing parameters.inp
           
    ##############################################################################################################
    #------------------------------------------- RUNNING WRAPPER ------------------------------------------------#
    ##############################################################################################################
                    
            os.system(str(cwd2) + "\\umatTest_release64.exe wrapperPlaxisToUMAT test "+str(cwd2))
            
    ##############################################################################################################
    #------------------------------------------- IMPORTING ouput text --------------------------------------------#
    ##############################################################################################################
            
            f=open("output.txt","r")
            lines=f.readlines()
            result_prev=[]
            results=[]
            for x in lines:
                result_prev.append(re.sub(r"\s+"," ", x, flags = re.I)) #\t
            for n in result_prev:
                results.append(re.sub(r"^\s+", "", n))
            f.close()
            
            del lines, result_prev
            
            list_of_lists = []
            for line in results:
                list_of_lists.append(line.split())
            
            del list_of_lists[0]
            
            strain_tensor={}
            stress_tensor={}
            
            strain_tensor["strain_xx"]=[]
            strain_tensor["strain_yy"]=[]
            strain_tensor["strain_zz"]=[]
            strain_tensor["strain_xy"]=[]
            strain_tensor["strain_xz"]=[]
            strain_tensor["strain_yz"]=[]        
            stress_tensor["stress_xx"]=[]
            stress_tensor["stress_yy"]=[]
            stress_tensor["stress_zz"]=[]
            stress_tensor["stress_xy"]=[]
            stress_tensor["stress_xz"]=[]
            stress_tensor["stress_yz"]=[]  
            
            for m in range(len(list_of_lists)):
                strain_tensor["strain_xx"].append(list_of_lists[m][2])
                strain_tensor["strain_yy"].append(list_of_lists[m][3])
                strain_tensor["strain_zz"].append(list_of_lists[m][4])
                strain_tensor["strain_xy"].append(list_of_lists[m][5])
                strain_tensor["strain_xz"].append(list_of_lists[m][6])
                strain_tensor["strain_yz"].append(list_of_lists[m][7])
                stress_tensor["stress_xx"].append(list_of_lists[m][8])
                stress_tensor["stress_yy"].append(list_of_lists[m][9])
                stress_tensor["stress_zz"].append(list_of_lists[m][10])
                stress_tensor["stress_xy"].append(list_of_lists[m][11])
                stress_tensor["stress_xz"].append(list_of_lists[m][12])
                stress_tensor["stress_yz"].append(list_of_lists[m][13])
            
    ##############################################################################################################
    #------------------------------------------- IMPORTING REAL TEST --------------------------------------------#
    ##############################################################################################################        
            os.chdir(cwd+"\Post_process\TX")
            
            def_real=pd.ExcelFile(df_test["File_name"].values.tolist()[j]+".xlsx").parse((pd.ExcelFile(df_test["File_name"].values.tolist()[j]+".xlsx")).sheet_names[0])
            ### there would be another function here reading the real style of furgo test 
            
            alldata.append(real_test(df_test['Test_type'][j],test_name[0],def_real[def_real.columns[0]],def_real[def_real.columns[1]],def_real[def_real.columns[3]]))
            
            allSimulated.append(All_tensors(stress_tensor,strain_tensor))
            
            os.chdir(cwd2)
            
    return alldata, allSimulated
            
alldata, allSimulated=forwardmodel(df_test,xl,cwd2,df_param,Constitutive_model,Nstate_var)        

##############################################################################################################
#------------------------------------------- PLOTTING FUNCTIONS ---------------------------------------------#
##############################################################################################################  

# =============================================================================
# for n in range(len(alldata)):
#     if alldata[n].test_type=="TX":
#         
#         q=[]
#         stress_xx=[-float(i) for i in allSimulated[n].stress["stress_xx"]]
#         stress_zz=[float(i) for i in allSimulated[n].stress["stress_zz"]]
#         zip_object = zip(stress_xx, stress_zz)
#         for list1_i, list2_i in zip_object:
#             q.append(-(-(list1_i+list2_i)))
#         
#         eps1=[-1*float(i) for i in allSimulated[n].strain["strain_xx"]]
#         
#         eps_list=[[1*float(i) for i in allSimulated[n].strain["strain_xx"]],[1*float(j) for j in allSimulated[n].strain["strain_yy"]],[1*float(m) for m in allSimulated[n].strain["strain_zz"]]]
#         epsV = [sum(x) for x in zip(*eps_list)]
#         
#         df=xl.parse(excel_sheets[3])
#         indx=df["File_name"].values.tolist().index(alldata[n].test_name)
#         
#         if df["involvment_q-eps1"][indx]!=-1:
#             fig = plt.figure(figsize=(10, 5))
#             ax1 = fig.add_subplot(111)
#             plt.title(alldata[n].test_name+" - "+alldata[n].test_type)
#             plt.plot(alldata[n].X, alldata[n].Y)
#             plt.plot(eps1,q)
#             ax1.set_xlabel('eps1')
#             ax1.set_ylabel('q')
#             
#         if df["involvment-EpsV-eps1"][indx]!=-1:
#             fig = plt.figure(figsize=(10, 5))
#             ax1 = fig.add_subplot(111)
#             plt.title(alldata[n].test_name+" - "+alldata[n].test_type)
#             #ax1.scatter(eps1, epsV, color="r", marker="s", s=10)
#             plt.plot(eps1,epsV)
#             ax1.set_xlabel('eps1')
#             ax1.set_ylabel('epsV')
# =============================================================================

fig = plt.figure(figsize=(10, 7))
ax1 = fig.add_subplot(111)
plt.title("q vs eps1")

#colors = np.random.rand(len(alldata), len(alldata))
colors = ['#8B008B','#008000','#FF4500', '#000000','#D2691E', '#ADFF2F', '#AFEEEE','#FFFF00']
col=0
for n in range(len(alldata)):
    if alldata[n].test_type=="TX":
        q=[]
        stress_xx=[-float(i) for i in allSimulated[n].stress["stress_xx"]]
        stress_zz=[float(i) for i in allSimulated[n].stress["stress_zz"]]
        zip_object = zip(stress_xx, stress_zz)
        for list1_i, list2_i in zip_object:
            q.append(-(-(list1_i+list2_i)))
        
        eps1=[-1*float(i) for i in allSimulated[n].strain["strain_xx"]]
        
        eps_list=[[1*float(i) for i in allSimulated[n].strain["strain_xx"]],[1*float(j) for j in allSimulated[n].strain["strain_yy"]],[1*float(m) for m in allSimulated[n].strain["strain_zz"]]]
        epsV = [sum(x) for x in zip(*eps_list)]
        
        df=xl.parse(excel_sheets[3])
        indx=df["File_name"].values.tolist().index(alldata[n].test_name)
        if df["involvment_q-eps1"][indx]!=-1:
            line1=plt.plot(alldata[n].X, alldata[n].Y,label=alldata[n].test_name+ " Real test", color=colors[col],marker='o')
            line2=plt.plot(eps1,q,label=alldata[n].test_name+ " Simulated test", color=colors[col])
            #line1.set_label(alldata[0].test_name+ " Real test")
            #line2.set_label(alldata[0].test_name+ " Simulated test")
            ax1.legend()
            col=col+1
        
            
ax1.set_xlabel('eps1')
ax1.set_ylabel('q')

fig = plt.figure(figsize=(10, 7))
ax1 = fig.add_subplot(111)
plt.title("epsV vs eps1")


for n in range(len(alldata)):
    if alldata[n].test_type=="TX":
        
        eps1=[-1*float(i) for i in allSimulated[n].strain["strain_xx"]]
        
        eps_list=[[1*float(i) for i in allSimulated[n].strain["strain_xx"]],[1*float(j) for j in allSimulated[n].strain["strain_yy"]],[1*float(m) for m in allSimulated[n].strain["strain_zz"]]]
        epsV = [sum(x) for x in zip(*eps_list)]
        
        df=xl.parse(excel_sheets[3])
        indx=df["File_name"].values.tolist().index(alldata[n].test_name)
        if df["involvment-EpsV-eps1"][indx]!=-1:
            line1=plt.plot(alldata[n].X, -alldata[n].Z/100,label=alldata[n].test_name+ " Real test")
            line2=plt.plot(eps1,epsV,label=alldata[n].test_name)
            #ax1.set_xlim(0,0.01)
            #ax1.set_ylim(-0.01,0.01)
            #line1.set_label(alldata[0].test_name+ " Real test")
            #line2.set_label(alldata[0].test_name+ " Simulated test")
            ax1.legend()
ax1.set_xlabel('eps1')
ax1.set_ylabel('epsV')
# =============================================================================
# 
#         if df["involvment-pwp-eps1"][indx]!=-1:
#             fig = plt.figure(figsize=(10, 5))
#             ax1 = fig.add_subplot(111)
#             plt.title(alldata[n].test_name+" - "+alldata[n].test_type)
#             ax1.scatter(eps1, q, color="r", marker="s", s=10)
#             plt.plot(eps1,q)
#             ax1.set_xlabel('eps1')
#             ax1.set_ylabel('q')        
#         
# =============================================================================
        
        
        

        
                    