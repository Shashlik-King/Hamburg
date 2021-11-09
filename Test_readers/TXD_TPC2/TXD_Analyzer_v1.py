# -*- coding: utf-8 -*-
"""
Created on Thu Nov  5 12:58:09 2020

@author: PNGI

Changed: CGQU  2021.10.20
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
#--------------------------------- Reading test to convert from database ------------------------------------#
##############################################################################################################

copilod = sql_connect.Copilod("owdb")#, user = 'users', password = 'password', host = 'host')
copilod.connect()
#Inventory_mysql = copilod.get_table('Test_inventory_DSS_CSS',outlier= "0", DSSG_TYPE = "CDSS" )
Inventory_mysql = copilod.get_table('Test_inventory_CID')
used_tests=Inventory_mysql[Inventory_mysql["Use"]==1]

##############################################################################################################
#----------------------------------------- functions and classes --------------------------------------------#
##############################################################################################################

class Triaxial_tests():
    
    def __init__(self, Conf, Eini,eps1,S3,S1,p,q,epsV,pwp,Test): 
        self.conf_pressure=Conf
        self.Eini=Eini        
        self.eps1=eps1 
        self.S3=S3
        self.S1=S1
        self.p=p
        self.q=q
        self.epsV=epsV
        self.qsimulation=[]
        self.pwp=pwp
        self.Test=Test
        self.epsS = self.eps1-(self.epsV - self.eps1)/2
        self.SS = (self.S1-self.S3)/2
        
    def peak_failure_point_ISO(self,criterion,Rf):
        idx=np.abs(self.eps1 - criterion).argmin()
        idx_max_q=np.argmax(self.q[0:idx])
#        p_failure=[self.p[idx_max_q],0]
        p_failure=self.p[idx_max_q]
        q_failure=self.q[idx_max_q]

        # data resolution is low so accurate E_50 and e1_50 need interpolation
        q_50 = Rf*q_failure/2       
        idx_50 = np.abs(self.q[0:idx_max_q] - q_50).argmin()
        qs  = [ self.q[idx_50] , self.q[idx_50+1] ]
        e1s = [ self.eps1[idx_50] ,self.eps1[idx_50+1] ]
        p1 = np.polyfit(qs, e1s, 1)        
        e1_50 = p1[1] + p1[0]*q_50
        E_50 =  q_50/e1_50

        eps_i = 0.001
        idx_i = np.abs(self.eps1 - eps_i).argmin()
        qs  = [ 0.0 , self.q[idx_i] ]
        e1s = [ 0.0 , self.eps1[idx_i] ]        
        p2 = np.polyfit(e1s, qs, 1)
        q_i = p2[1] + p2[0]*eps_i
        E_i =  q_i/eps_i
        
        return p_failure,q_failure,E_50,e1_50,q_50,E_i

def fit_line_to_X(Pfail,M_star):
# Curve fitting function
    return M_star * Pfail # b=0 is zero to force zero cohesion for sand 
    
def Hyperpolic(eps1,phi,sigma,sigma_ref,m,E50_ref,Pfail): 
    Rf=0.9
    C = 0
    phi = phi*3.1415/180
    qfail_1 = Pfail*((6*np.sin(phi)) / (3-np.sin(phi)))
    E50 = E50_ref*((C*math.cos(phi)+sigma*math.sin(phi))/(C*math.cos(phi)+sigma_ref*math.sin(phi)))**m
    E=-2*E50/(2-Rf)    
    qa=qfail_1/Rf
    q=np.divide(-eps1*E*qa,(qa-eps1*E))     
    return q

def Triaxial_single (input_data,Calib_1): 
    E50=Calib_1
    Rf=0.9
#    m=Calib[3]
    eps1=input_data['eps1'] 
    qa=max(input_data['q'])/ Rf 
#    E50 =  E50_ref*(sigma/sigma_ref)**m
    E=2*E50/(2-Rf)
    q=np.divide(-eps1*E*qa,(qa-eps1*E))    
    return q

def Error_func(x0,S3,Dr,E_50):
    E_pre = x0[0]*Dr*((S3/100)**(x0[1]-Dr*x0[2]))
    t_error = (E_pre - E_50)**2
    abs_erro = np.sum(t_error)
    return abs_erro

def E_prediction(x0,S3,Dr,E_50):
    E_pre = x0[0]*Dr*((S3/100)**(x0[1]-Dr*x0[2]))  
    return E_pre

def Average(lst): 
    return sum(lst) / len(lst) 

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
#----------------------------------------------- Inputs -----------------------------------------------------#
##############################################################################################################

write_paramis_HS_model   = 0 #write the parameters and selected tests for HS model


# Initial values for E50_ref=x[0]*Dr ; m = x[1] - Dr*x[2]
x0 = [50000 , 0.3  , 0.01]
# Upper and lowe bounds 
bnds = ((10000,150000),(0.0,2),(-0.5,1))

#------------------------------------------------------------------------------------------------------------

cwd = os.getcwd()

test_folder= cwd.replace('Test_readers\TXD_TPC2', 'Post_process\TXD')
os.chdir(test_folder)

file_names = []

BH_names = []
Samp_ref_names = []
BH_Sample=[]
test_names=[]

Dr_calibration=[]
Dr_calibration=used_tests["Dr_calibration"].values.tolist()[0]      # 1 or 0 - calibration of m and E_50 based on Dr for sand

for j in range(len(used_tests)):

    test_names.append(used_tests["Test_name"].values.tolist()[j])
    Samp_ref_names.append(used_tests["Samp_ID"].values.tolist()[j])
    BH_names.append(used_tests["LOCA_ID"].values.tolist()[j])
    BH_Sample.append(BH_names[-1]+"_"+Samp_ref_names[-1])

unique_BH_Sample=unique(BH_Sample)
    
for (dirpath, dirnames, filenames) in walk(test_folder):
    file_names.extend(filenames)
    break

##############################################################################################################
#---------------------------------------- Looping over selected samples -------------------------------------#
##############################################################################################################

for i in range(len(unique_BH_Sample)):
    
    indx=[z for z, e in enumerate(BH_Sample) if e == unique_BH_Sample[i]]

    used_test_names=[]
    for y in range(len(indx)):
        used_test_names.append(test_names[indx[y]]) 

    print(used_test_names)
    final_tests=[]
    for x in range(len(used_test_names)):
    
        for z in range(len(file_names)):
            
            if (used_test_names[x] in file_names[z]):
                
                final_tests.append(file_names[z])
                break
            
    print(final_tests)       
            
    used_test_sample=used_tests[used_tests["Samp_ID"]==Samp_ref_names[indx[0]]][used_tests["LOCA_ID"]==BH_names[indx[0]]]

    if len(final_tests)!=0:
##############################################################################################################
#--------------------------------- Reading the tests and defining variales ----------------------------------#
##############################################################################################################
    
        sigm_ref=100.0 # Kpa
        Rf = 0.9
        E50 = []
        All_tests_data={}
        Pfail=[]
        qfail=[]
        P_cr=[]
        q_cr=[]
        e1_50  = []
        E_i = []
        q_50 = []
        criterion=10
        sigma3=[]
        Dr=[]
        
        for tests in np.arange(len(final_tests)):
            
            dataname=test_names[tests]    
            filename=final_tests[tests] 
            print(filename)
            
            xl = pd.ExcelFile(filename)
            excel_sheets=(xl.sheet_names)
            
            df1=pd.read_excel(filename,excel_sheets[0])
            df2=pd.read_excel(filename,excel_sheets[1])
            
            Initial_cell_pressure=df2['values'][1]
            e0=df2['values'][0]
            Dr.append(df2['values'][2])
            
            
            eps1=df1['Axial_Strain [%]']
            epsv=df1['epsv [%]']
            p=df1['p [kPa]']
            q=df1['dev_stress [kPa]']
            S1=df1['Sigma_1 [kPa]']
            S3=df1['Sigma_3 [kPa]']
            PWP=df1['Excess_PWP [kPa]']
            
                
            All_tests_data[dataname]=Triaxial_tests(Initial_cell_pressure, e0, eps1,S3,S1,p,q,epsv,PWP,dataname)
            Pfail.append(Triaxial_tests.peak_failure_point_ISO(All_tests_data[dataname],criterion,Rf)[0])
            qfail.append(Triaxial_tests.peak_failure_point_ISO(All_tests_data[dataname],criterion,Rf)[1])
            E50.append(Triaxial_tests.peak_failure_point_ISO(All_tests_data[dataname],criterion,Rf)[2])
            e1_50.append(Triaxial_tests.peak_failure_point_ISO(All_tests_data[dataname],criterion,Rf)[3])
            q_50.append(Triaxial_tests.peak_failure_point_ISO(All_tests_data[dataname],criterion,Rf)[4])
            E_i.append(Triaxial_tests.peak_failure_point_ISO(All_tests_data[dataname],criterion,Rf)[5])
            
            sigma3.append(All_tests_data[dataname].p[0])
            # last five data point for critical state friction angle
            P_cr.append(Average(All_tests_data[dataname].p[-5:]))
            q_cr.append(Average(All_tests_data[dataname].q[-5:]))
        
        # Simply fill m, E50-ref, etc. and later will be rewriten correctly
        m = np.zeros(len(final_tests))
        E50_ref = np.zeros(len(final_tests))
        E_i_ref = np.zeros(len(final_tests))
        phi_cr = np.zeros(len(final_tests))
        phi_deg = np.zeros(len(final_tests))
        phi = np.zeros(len(final_tests))
        phi_deg_cr = np.zeros(len(final_tests))
        phi_cr = np.zeros(len(final_tests))
        sigma3 = np.array(sigma3)
        C= np.zeros(len(final_tests))
        
        os.chdir(cwd)
    
    ##############################################################################################################
    #--------------------------------- Estimation of Strength Parameter -----------------------------------------#
    ##############################################################################################################   
        
        #Critical friction angle
        col=0
        for test in All_tests_data:
            M_star = q_cr[col]/P_cr[col]
            phi_cr[col]=np.arcsin(3*M_star/(6+M_star))
            col +=1
        phi_cr = Average(phi_cr)
        phi_deg_cr = (phi_cr)*180/3.1415
        
        # peak friction angle
        
        if Dr_calibration > 0.01:
            print ('Dr related parameters is activated')
            col=0
            for tests in All_tests_data:
                  
                # Forcing c=0 for sand
                M_star = qfail[col]/Pfail[col]
                phi[col]=np.arcsin(3*M_star/(6+M_star))
                col +=1
                C_star = 0
                C=C_star*(3-np.sin(phi))/(6*np.cos(phi))
        
            phi_deg[:] = phi*180/3.14159
            
            x3 = curve_fit (fit_line_to_X, Dr,phi_deg-phi_deg_cr)
            
            phi_coff = [phi_deg_cr , x3[0]]
            phi_pre =  phi_deg_cr + x3[0]*Dr
            print('Phi_critical=', phi_deg_cr)
            print('Phi_peak=', phi_deg_cr ,"+" ,x3[0] ,"*Dr" )
            
    
        
        else:
            print ('Dr related parameters is deactivated')
            #Forcing c=0 for sand
            M= curve_fit (fit_line_to_X,Pfail,qfail)
            M_star = M[0]
            C_star = 0
            phi=np.arcsin(3*M_star/(6+M_star))
            C[:]=C_star*(3-np.sin(phi))/(6*np.cos(phi))
            q_predict=M_star*(max(Pfail)+100)+C_star
            phi_deg[:] = phi*180/3.14159
            phi_pre = phi_deg
            phi_coff = [0.0 , 0.0]
            print('Phi_critical=', phi_deg_cr)
            print('Phi_peak=', phi_deg[0])
    
    
    ##############################################################################################################
    #-------------------------------- Estimation of Stiffness Parameter -----------------------------------------#
    ##############################################################################################################
    
        # E50
        Y=np.log(E50)
        ratio = sigma3/sigm_ref
        X=np.log(ratio)
        P = np.polyfit(X,Y, 1)
        m_cons= P[0]
        Ln_EG0_Ref = P[1]
        E50_ref[:]=math.exp(Ln_EG0_Ref)
        
        if Dr_calibration > 0.01:
            S3 = np.array(sigma3)
            E_50 = np.array(E50)
            Dr_test = np.array(Dr)
            sol = opt.minimize(Error_func,x0,args=(S3,Dr_test,E_50),
                               method='L-BFGS-B',
                               bounds=bnds,
                               options={'disp':False})
                               # L-BFGS-B , TNC , Nelder-Mead , 
            
            x0_output = sol.x
            E50_ref = Dr_test*x0_output[0]
            m = x0_output[1] - Dr_test*x0_output[2]
            E_pre = E_prediction(x0_output,S3,Dr_test,E_50)
            print('E50_ref =' , x0_output[0],"*Dr" )
            print('m factor =' , x0_output[1] , "-" , x0_output[2],"*Dr" )
    
        else:
            m[:] = m_cons
            print('E50_ref =' ,E50_ref[0] )
            print('m factor =' , m_cons)
            x0_output = [0,0,0]
    
        
    
    # ##############################################################################################################
    # #------------------------------------------ Uploading to database -------------------------------------------#
    # ##############################################################################################################
    
        project_name=used_test_sample["project_name"].values.tolist()[0]
        LOCA_ID=used_test_sample["LOCA_ID"].values.tolist()[0]
        Samp_ID=used_test_sample["Samp_ID"].values.tolist()[0]
        Test_type=used_test_sample["Test_type"].values.tolist()[0]
        depth=(used_test_sample["Sample_top"].values.tolist()[0]+used_test_sample["Sample_bottom"].values.tolist()[0])/2
        
# =============================================================================
#         
#         if Dr_calibration < 0.01:
#         
#             data = (([project_name]), ([LOCA_ID]),([Samp_ID]),([Test_type]),([round(float(depth),2)]),([float(e0)]),([float(C[0])]),
#             ([float(phi_deg[0])]),([float(phi_deg_cr)]),([float(m[0])]),([float(E50_ref[0])]),([-1.0]),([-1.0]),([-1.0]),([-1.0])) 
#             data  = tuple(zip(*data))
#             
#             Table_columns=copilod.table_columns("output_CID")
#             copilod.insert("output_CID",Table_columns,data)
# =============================================================================
        
    # =============================================================================
    #     if Dr_calibration == 1:
    #     
    #         data = (([project_name]), ([LOCA_ID]),([Samp_ID]),([Test_type]),([float(e0)]),([float(C[0])]),
    #         ([float(phi_deg[0])]),([float(phi_deg_cr)]),([float(m[0])]),([float(E50[0])]),([float(E50_ref[0])]),([-1.0]),([-1.0]),([-1.0]),([-1.0])) 
    #         data  = tuple(zip(*data))
    #         
    #         Table_columns=copilod.table_columns("output_CID")
    #         copilod.insert("output_CID",Table_columns,data)
    # =============================================================================
            
        os.chdir(test_folder)
    
copilod.close() 


# ##############################################################################################################
# #------------------------------------------------- Plotting -------------------------------------------------#
# ##############################################################################################################
# 
# input_data={}
# colors = ['#1f27b4','#ff1f0e','#2ca02c','#d69728','#9497bd','#8c564b','#e377c2','#7f7f5f','#bcbd72','#17becf','#1a55FF','#8B008B','#008000','#FF4500', '#000000','#D2691E', '#ADFF2F', '#AFEEEE','#FFFF00']
#     # raw lab data
# # Lab data and fit curves
# plt.figure(figsize=(8,5))
# col=0
# for tests in All_tests_data:
#     eps11=All_tests_data[tests].eps1
#     annn=Hyperpolic(eps11,phi_pre[col],sigma3[col],sigm_ref,m[col],E50_ref[col],Pfail[col])
#     All_tests_data[tests].qsimulation=annn
#     plt.plot(All_tests_data[tests].eps1, All_tests_data[tests].q, marker='o', label='data'+tests,color=colors[col])
#     plt.plot(All_tests_data[tests].eps1,All_tests_data[tests].qsimulation, linewidth=3.0, label='fit'+tests,color=colors[col])
#     col=col+1
# plt.legend(loc='best')
# plt.ylabel('q (kPa)')
# plt.xlabel('eps1')
# plt.show()
    

# # =============================================================================
# # cwd = os.getcwd()
# # cwd2= cwd.replace('Test_readers\TXD', '')    
# # os.chdir(cwd2)    
# # write_paramis_plotter(All_tests_data,final_tests,C,phi_deg,phi_deg_cr,m,E50,E50_ref,Dr_calibration,x0_output,phi_coff,Dr,e_0,e_max)
# # os.chdir(cwd)
# # =============================================================================



# plt.figure(figsize=(8,5))
# col=0
# for tests in All_tests_data:
#     plt.plot(All_tests_data[tests].eps1, All_tests_data[tests].q, marker='o', label='data'+tests,color=colors[col])
#     col=col+1
    
# # plt.legend(loc='best')
# plt.legend(loc='center right')
# plt.ylabel('q (kPa)')
# plt.xlabel('eps1')
# plt.show()

# plt.figure(figsize=(8,5))
# col=0
# for tests in All_tests_data:
#     plt.plot(All_tests_data[tests].eps1, -All_tests_data[tests].epsV, marker='o', label='data'+tests,color=colors[col])
#     col=col+1
    
# # plt.legend(loc='best')
# plt.legend(loc='center right')
# plt.ylabel('eps_v')
# plt.xlabel('eps1')
# plt.show()     
# #=============================================================================
# if Dr_calibration == 1: 
#     col=0
#     plt.figure(figsize=(8,5))
#     for tests in All_tests_data:
#         plt.plot(Dr[col], phi_deg[col], marker='o',  label='data'+tests,color=colors[col])
#         col=col+1   
#     plt.plot([min(Dr),max(Dr)],[phi_deg_cr+x3[0]*min(Dr),phi_deg_cr+x3[0]*max(Dr)], linewidth=3.0, label='fit')
#     plt.legend(loc='best')
#     plt.ylabel('Phi_peak (deg)')
#     plt.xlabel('Relative density (Dr)')
#     plt.show()

#     col=0
#     plt.figure(figsize=(8,5))
#     for tests in All_tests_data:
#         # plt.plot(sigma3[col],E50[col], 'o', label=tests)
#         plt.plot(E_pre[col],E50[col] , marker='o', label=tests, color=colors[col])
#         col +=1
#     max_X = max(E50)
#     min_X = min(E50)
#     plt.plot([min_X,max_X] ,[min_X,max_X] , linewidth=3.0 )
#     plt.ylabel('E_50 (kPa) - Data')
#     plt.xlabel('E_50 (kPa) - fit')
#     plt.legend(loc='best')
#     plt.show()
# else:
#     plt.figure(figsize=(8,5))
#     #q_predict=reg.predict(np.array([[1000,0]]))
#     col=0
#     plt.figure(figsize=(8,5))
#     for tests in All_tests_data:
#         plt.plot(All_tests_data[tests].p, All_tests_data[tests].q, marker='o',  label='data'+tests, color=colors[col])
#         col=col+1
#     plt.plot([0,max(Pfail)+100],[C_star,q_predict], linewidth=3.0, label='fit')
    
#     plt.legend(loc='best')
#     plt.ylabel('q (kPa)')
#     plt.xlabel('p (kPa)')
#     plt.show()

#     plt.figure(figsize=(8,5))
#     col = 0
#     plt.figure(figsize=(8,5))
#     for tests in All_tests_data:
#         #plt.plot(sigma3[col],E50[col], 'o', label=tests)
#         plt.plot(X[col],Y[col] , marker='o', label=tests, color=colors[col])
#         col +=1
#     max_X = max(X)
#     min_X = min(X)
#     plt.plot([min_X,max_X] , [(Ln_EG0_Ref + m_cons*min_X) , (Ln_EG0_Ref + m_cons*max_X) ], linewidth=3.0, label='fit' )
#     plt.ylabel('Ln(E_50)')
#     plt.xlabel('ln(Sigma_3/sigma_ref)')
#     # plt.legend(loc='best')
#     plt.show()

# #=============================================================================     

# plt.figure(figsize=(8,5))
# col =0
# for tests in All_tests_data:
#     plt.plot(sigma3[col],E50[col], 'o', label=tests)
#     #plt.plot(X[col],Y[col] , marker='o', label=tests)
#     col +=1

# plt.ylabel('Ln(E_50)')
# plt.xlabel('ln(Sigma_3/sigma_ref)')
# # plt.legend(loc='best')
# plt.show()

# =============================================================================   
# ############################################################################################################
# #-------------------------------------------------------- G/Gmax --------------------------------------------#
# ##############################################################################################################       
#     
#     
# plt.figure(figsize=(8,5))
# col =0
# for tests in All_tests_data:
#     q = All_tests_data[tests].q
#     epsv = All_tests_data[tests].epsV 
#     eps1 = All_tests_data[tests].eps1
#     epsq= eps1 - (epsv/3)
#        
#     G_sec_q = 0.33 * q/epsq
#     
#     E_sec = q/eps1
#     plt.semilogx(epsq*100, G_sec_q, label=test +"_G_q", color=colors[col])
#     # plt.semilogx(eps1*100, E_sec, label=test +"_E_sec", color=colors[col])
#     col +=1
# 
# plt.ylabel('G')
# plt.xlabel('Deviatoric strain')
# plt.legend(loc='best')
# plt.show()
#     
# 
# =============================================================================


# colors = ['#1f27b4','#ff1f0e','#2ca02c','#d69728','#9497bd','#8c564b','#e377c2','#7f7f5f','#bcbd72','#17becf','#1a55FF']