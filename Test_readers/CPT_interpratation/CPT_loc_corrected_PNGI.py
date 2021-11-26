# -*- coding: utf-8 -*-
"""
Created on Tue Feb  9 12:48:26 2021

@author: MDGI
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
import math
import pandas as pd
from sklearn.linear_model import LinearRegression 
from math import *
import os, xlsxwriter,openpyxl
from scipy.stats import kde
from scipy.stats import gaussian_kde

def OCR_Fun_PL(depth,A,P):
    '''
    

    Parameters
    ----------
    depth : TYPE
        DESCRIPTION.
    A : TYPE
        DESCRIPTION.
    P : TYPE
        DESCRIPTION.

    Returns
    -------
    OCR_fit : TYPE
        DESCRIPTION.

    '''
    OCR_fit=A*(depth**P)
    return OCR_fit
def OCR_Fun_Pc(depth,A):
    '''
    

    Parameters
    ----------
    depth : TYPE
        DESCRIPTION.
    A : TYPE
        DESCRIPTION.

    Returns
    -------
    OCR_fit : TYPE
        DESCRIPTION.

    '''
    OCR_fit = (depth*10 + A)/(depth*10)
    return OCR_fit

def unique(list1): 
    '''
    

    Parameters
    ----------
    list1 : TYPE
        DESCRIPTION.

    Returns
    -------
    unique_list : TYPE
        DESCRIPTION.

    '''
  
    # intilize a null list 
    unique_list = [] 
      
    # traverse for all elements 
    for x in list1: 
        # check if exists in unique_list or not 
        if x not in unique_list: 
            unique_list.append(x)
    return  unique_list        

from os import walk

cwd = os.getcwd()
file_names = []
BH_names = []
name = []

# get_ipython().run_line_magic('matplotlib', 'qt')


loc_excel="Backup.xlsx"
xl = pd.ExcelFile(loc_excel)
excel_sheets=(xl.sheet_names)

df_loc=pd.read_excel(loc_excel,sheet_name="Input")
locations=df_loc[df_loc["Use"]==1]["Location"].values.tolist()

my_dict={}

for i in range(len(locations)):
    df0=pd.read_excel(loc_excel,sheet_name=locations[i])
    
    Depth_density = np.array(df0["Depth [m]"])
    density= np.array(df0["SBH_BDEN"])
    density = (1000*0.00982*density)- 9.81
    sigmaV = np.zeros(len(Depth_density))
    sigmaV[0] = Depth_density[0]*density[0]
    for i in range(len(Depth_density)-1):  
        sigmaV[i+1] = sigmaV[i] + density[i+1]*(Depth_density[i+1]-Depth_density[i])
        
    df0["SIGMA_V"] =  sigmaV
    
    soil_units= unique(df0["Unit"].values.tolist())
       
    for j in range(len(soil_units)):
        my_dict[soil_units[j]]=df0[df0["Unit"]==soil_units[j]]
        
def getList(my_dict):
      
    return [*my_dict]



inventory_excel="Backup.xlsx"
xl = pd.ExcelFile(inventory_excel)
excel_sheets=(xl.sheet_names)
Input=pd.read_excel(inventory_excel,sheet_name="Units_data",index_col=0,usecols=None)
print(Input)


# Driver program

df_post_processed_data = pd.DataFrame({"depth": [], "qc": [] , "fs":[] , "qnet":[],"phi":[],"DR":[],"K0_NC":[],"K0_OC":[],"OCR":[],"SU":[],"Sigma_v":[],"Unit":[] })

units = (getList(my_dict))   
colors = ['#1f27b4','#ff1f0e','#2ca02c','#d69728','#9497bd','#8c564b','#e377c2','#7f7f5f','#bcbd72','#17becf','#1a55FF','#8B008B','#008000','#FF4500', '#000000','#D2691E', '#ADFF2F', '#AFEEEE','#FFFF00']
col=0
fig, axs = plt.subplots(1,6,figsize=(25,20))

for i in range(len(units)):
    
    Soil_unit = units[i]
    # Sand units
    if "S" in Soil_unit: 
        print("Sand-"+Soil_unit)
               
        phi_peak = Input[Soil_unit]["Peak_friction_angle"] 
        phi_coeff = Input[Soil_unit]["Coeff_friction_angle"] 
        phi_critica =Input[Soil_unit]["Critical_friction_angle"] 
        OCR_coeff1 = Input[Soil_unit]["OCR_coeff1_S"] 
        OCR_coeff2 = Input[Soil_unit]["OCR_coeff2_S"] 
        OCR_cap = Input[Soil_unit]["OCR_CAP"]
        max_Dr = Input[Soil_unit]["max_Dr"]
        max_depth = Input[Soil_unit]["depth_limit_max"]
        min_depth = Input[Soil_unit]["depth_limit_min"]
        Consolidation = Input[Soil_unit]["Consolidation_S"]
        max_k0_S = Input[Soil_unit]["max_k0_S"]
        phi_Dr = Input[Soil_unit]["Friction_Dr"]
        
        df = my_dict[Soil_unit]
        
        df2=df[df["Depth [m]"] > min_depth] 
        df2=df2[df2["Depth [m]"] < max_depth]
        df2=df2[df2["SBH_QNET"] < 100]
        df2=df2[df2["SBH_QNET"] > 0]
        df2=df2[df2["SBH_NQT"] > 0]
        df2=df2[df2["SBH_RES"] > 0] 
        # df2=df2[df2["SBH_FRES"] > 0]
        print(df2)
        depth=np.array(df2["Depth [m]"])
        
        qt=np.array(df2["SBH_QNET"])
        qc=np.array(df2["SBH_RES"])
        nqt = np.array(df2["SBH_NQT"]) 
        fs = np.array(df2["SBH_FRES"])
        sigmv = np.array(df2["SIGMA_V"]) 
        
        k0_cpt_fugro = np.zeros(len(depth))
        k0_cpt_Lunne = np.zeros(len(depth))
        OCR_cpt_Lunne = np.zeros(len(depth))
        phi= np.zeros(len(depth))
        k0_nc = np.zeros(len(depth))
        sin_phi = np.zeros(len(depth))
        Dr_fugro_dry = np.zeros(len(depth))
        Dr_fugro_sat = np.zeros(len(depth))
        Dr_Baldi = np.zeros(len(depth))
        Depth_OCR = np.zeros((len(depth),2))
        
        All_data = np.zeros((len(depth) , 10))
    
        phi = 17.6 + 11.0 *np.log10( (10.0*qt) / ( (sigmv/100.0)**0.5 ) ) 
        phi_rad = phi*3.1415/180.0
           
        sin_phi = np.sin(phi_rad)
        
        k0_cpt_fugro = ( (sigmv**(1.15*sin_phi/(1-3.7*sin_phi)))*( (1-sin_phi)**(1/(1-3.7*sin_phi))) 
                                                      / ( (2.876**(sin_phi/(1-3.7*sin_phi)))
                                                          * (qt**(0.815*sin_phi/(1-3.7*sin_phi)))    )
                                                      )
        
        OCR_cpt_Lunne = (0.33*((1000*qt)**0.72))/sigmv
        
        index = np.nonzero(OCR_cpt_Lunne < 1.0)
        OCR_cpt_Lunne[index] = 1.0 # OCR cannot be less than one
        index = np.nonzero(OCR_cpt_Lunne > OCR_cap)
        OCR_cpt_Lunne[index] = OCR_cap # OCR cannot be less than one    
        
        # Fitting OCR
        # # Power Law
        # popt, pcov = curve_fit(OCR_Fun_PL,depth,OCR_cpt_Lunne)
        # OCR_pred_PL = popt[0]*(depth**popt[1])
        # # Simple OCR defination
        # popt, pcov = curve_fit(OCR_Fun_Pc,depth,OCR_cpt_Lunne)
        # OCR_pred_Pc = (popt[0]+depth*10)/(depth*10)
        OCR_trend  = (OCR_coeff1+sigmv)/sigmv   
        # OCR_trend  = OCR_coeff1*(depth**OCR_coeff2) 
        
        if Consolidation=="trend":   
            OCR_cal = OCR_trend
        elif Consolidation=="CPT":
            OCR_cal = OCR_cpt_Lunne
        elif Consolidation=="Const":
            OCR_cal = OCR_input
        elif Consolidation=="NC":
            OCR_cal = 0            
               
        K0_OC = (1- np.sin(3.14*phi_critica/180))*(OCR_cal**np.sin(3.14*phi_critica/180))
        index = np.nonzero(K0_OC > max_k0_S)
        K0_OC[index] = max_k0_S # OCR cannot be less than one
        
        K0_dr =  K0_OC

        #################################Calculation of the Dr based on the formulation sent by Orsted 
        # K0_Dr_orsted=K0_OC
        # index_high_depth = np.nonzero(depth > 5)  ###   consider the k0 = 0.5 for the depth more than 5 m, based on Orsted report 
        # K0_Dr_orsted[index_high_depth] = 0.5 # correction of K0 to be alighend with orsted method
        
        #######################################################################################################
        
        
              
        # sigmaV_in_bar=sigmv*0.01
        
        # qc_in_bar=(qc*1000)/100
        
        # P_mean_in_bar=sigmaV_in_bar*((1+2*K0_dr)/3)
            
        
        # Dr_fugro_dry=(1/2.96)*np.log(qc_in_bar/(24.94*((P_mean_in_bar)**0.46)))*100
        
        # Dr_fugro_sat= ((Dr_fugro_dry/100)*(-1.87+2.32*np.log(qc_in_bar/((sigmaV_in_bar*1)**0.5))))+Dr_fugro_dry
        
        
        
        ###########################################################################################
        

        ##########  Old formulation which was QAed by SPSO
 
        ''' calculation of the dr
        
        '''
 
    
 
        
        Dr_fugro_dry= (1/0.0296)*np.log((qc/(2.494*(0.01*sigmv*((1+2*K0_dr)/3))**0.46)))
        
        Dr_fugro_sat= (0.01*(-1.87 + 2.32*np.log((1000.0*qc)/((100*sigmv)**0.5)))+1)*Dr_fugro_dry

        ##########################################################################################
        
        Dr_fugro_dry_wrong =  (1/0.0296)*np.log((qc/(2.494*0.01*sigmv*(((1+2*K0_dr)/3)**0.46))))    ##### Wrong formulation used in the prious versions of submitions 
        Dr_fugro_sat_wrong = ( 0.01*(-1.87+2.32*np.log( 1000.0*qc/( (100*sigmv)**0.5 )  ) ) + 1 )*Dr_fugro_dry_wrong     ##### Wrong formulation used in the prious versions of submitions
        

        
        
        
        index = np.nonzero(Dr_fugro_sat > max_Dr)
        Dr_fugro_sat[index] = max_Dr # OCR cannot be less than one   
        
        
        
        
    
        sigmm = (sigmv +2*K0_dr*sigmv)/3
        Dr_Baldi = (100/2.61) * np.log( 1000*qc/ ( 181*( sigmm**0.55 )  )   )
        # Dr_Baldi = (100/3.1) * np.log( (1000*qc/98.1)/ ( 181*( (sigmv/98.1)**0.55 )  )   )
        
        if phi_Dr==1:
            phi_lab = phi_critica+phi_coeff*(0.01*Dr_fugro_sat)
            K0_NC = 1-np.sin(phi_lab*3.1415/180)     
            phi_cri = np.zeros(len(depth)) + phi_critica
        else:
            phi_lab = np.zeros(len(depth)) + phi_peak
            phi_cri = np.zeros(len(depth)) + phi_critica
            K0_NC = 1-np.sin(phi_lab*3.1415/180)

        # Plotting        
        axs[0].scatter(qc, depth ,  label="qc-"+Soil_unit,color=colors[col])
        axs[0].legend(loc='best',fontsize=14)
        axs[0].set_xlabel('Cone resistance [MPa]', fontsize = 14)
        axs[0].set_ylabel('Depth [m]', fontsize = 14)
        axs[0].set_ylim([0, max(Depth_density)+5])
        axs[0].tick_params(direction='out', length=6, width=2, grid_alpha=0.5, labelsize=14)
        axs[0].invert_yaxis()
    
        axs[2].scatter(K0_OC, depth, label="K0-OC-"+Soil_unit,color=colors[col])
        # axs[2].plot(K0_NC, depth ,linestyle='dashed', label="K0-NC-"+Soil_unit,color=colors[col])
        axs[2].legend(loc='best',fontsize=14)
        axs[2].set_ylim([0, max(Depth_density)+5])
        axs[2].tick_params(direction='out', length=6, width=2, grid_alpha=0.5, labelsize=14)
        axs[2].invert_yaxis()
        axs[2].set_xlabel('K0 [-]', fontsize = 14)
        
        axs[1].scatter(OCR_cpt_Lunne, depth ,  label="OCR-Mayne (2009)-"+Soil_unit,color=colors[col])
        # axs[1].scatter(OCR_pred_Pc, depth ,  label="OCR-fit-Pc"color=colors[col])
        # axs[1].scatter(OCR_pred_PL, depth ,  label="OCR-fit-Power Law")
        axs[1].plot(OCR_trend, depth ,linestyle='dashed', label="OCR-site trend-"+Soil_unit,color=colors[col])
        axs[1].legend(loc='best',fontsize=14)
        axs[1].set_xlabel('OCR [-]', fontsize = 14)
        axs[1].set_ylim([0, max(Depth_density)+5])
        axs[1].tick_params(direction='out', length=6, width=2, grid_alpha=0.5, labelsize=14)
        axs[1].invert_yaxis()
        
        axs[3].scatter(Dr_fugro_sat, depth ,  label="Jamiolkowski (2003)-"+Soil_unit,color=colors[col])
        axs[3].plot(Dr_fugro_sat_wrong, depth , label="wrong-"+Soil_unit,color=colors[col+1])
        axs[3].legend(loc='best',fontsize=14)
        axs[3].set_xlabel('Relative Density [%]', fontsize = 14)           
        axs[3].set_ylim([0, max(Depth_density)+5])
        axs[3].set_xlim([0, 120])
        axs[3].tick_params(direction='out', length=6, width=2, grid_alpha=0.5, labelsize=14)
        axs[3].invert_yaxis()
        
        # axs[4].scatter(sigmv, depth ,  label=Soil_unit,color=colors[col])
        #axs[3].scatter(Dr_Baldi, depth , label="Baldi")
        axs[4].legend(loc='best',fontsize=14)
        axs[4].set_xlabel('Su [kPa]', fontsize = 14)   
        axs[4].set_ylim([0, max(Depth_density)+5])
        axs[4].tick_params(direction='out', length=6, width=2, grid_alpha=0.5, labelsize=14)
        axs[4].invert_yaxis()
        
        axs[5].scatter(phi_cri, depth ,  label="Lab-"+Soil_unit,color=colors[col])
        axs[5].legend(loc='best',fontsize=14)
        axs[5].set_xlabel('φ [deg]', fontsize = 14)    
        axs[5].set_ylim([0, max(Depth_density)+5])
        axs[5].tick_params(direction='out', length=6, width=2, grid_alpha=0.5, labelsize=14)
        axs[5].invert_yaxis()
        
        Unit_list = [Soil_unit for x in range(len(depth))]
        Su = np.zeros(len(depth))
        
        for i in range(len(depth)):
            df_temp=[depth[i],qc[i],fs[i],qt[i],phi_lab[i],Dr_fugro_sat[i],K0_NC[i],K0_OC[i],OCR_cal[i],Su[i],sigmv[i],Soil_unit]
            df_length = len(df_post_processed_data)
            df_post_processed_data.loc[df_length] = df_temp

     # Clay units  
    if "C" in Soil_unit:
        print("Clay-"+Soil_unit)
        
        Nkt = Input[Soil_unit]["Nkt"] 
        SU_trend = Input[Soil_unit]["SU_trend"] 
        SU = Input[Soil_unit]["SU"] 
        C = Input[Soil_unit]["SU_z"] 
        OCR_coeff1 = Input[Soil_unit]["OCR_coeff1_C"] 
        OCR_coeff2 = Input[Soil_unit]["OCR_coeff2_C"] 
        OCR_cap = Input[Soil_unit]["OCR_CAP"]
        max_Dr = Input[Soil_unit]["max_Dr"]
        max_depth = Input[Soil_unit]["depth_limit_max"]
        min_depth = Input[Soil_unit]["depth_limit_min"]
        Consolidation = Input[Soil_unit]["Consolidation_C"]
        max_k0_C = Input[Soil_unit]["max_k0_C"]
 
        df = my_dict[Soil_unit]
        
        df2=df[df["Depth [m]"] > min_depth] 
        df2=df2[df2["Depth [m]"] < max_depth]
        df2=df2[df2["SBH_QNET"] < 15]
        df2=df2[df2["SBH_QNET"] > 0]
        df2=df2[df2["SBH_NQT"] > 0]
        df2=df2[df2["SBH_RES"] > 0]
        df2=df2[df2["SBH_FRES"] > 0]
        
        
        depth=np.array(df2["Depth [m]"])
        qt=np.array(df2["SBH_QNET"])
        qc=np.array(df2["SBH_RES"])
        nqt = np.array(df2["SBH_NQT"]) 
        fs = np.array(df2["SBH_FRES"]) 
        Bq = np.array(df2["SBH_BQ"])
        sigmv = np.array(df2["SIGMA_V"]) 
        
        OCR_trend  = (OCR_coeff1+sigmv)/sigmv

        if Consolidation=="trend":   
            OCR_cal = OCR_trend
        elif Consolidation=="CPT":
            OCR_cal = OCR_trend
        elif Consolidation=="Const":
            OCR_cal = OCR_input
        elif Consolidation=="NC":
            OCR_cal = 0
        
        if SU_trend == "Const":
            Su_input = np.zeros(len(depth)) + SU
        elif SU_trend=="liner":
            Su_input = Su + (depth - depth[0])*SU_z
            
        Su_cpt = (qt)/(Nkt*0.001)
        OCR_trend  = (OCR_coeff1+sigmv)/sigmv   
        
        phi=30.8*(np.log10(1000*fs/sigmv)+1.26)
        phi_rad = phi*3.1415/180.0
        sin_phi = np.sin(phi_rad)
        K0_OC = (1-sin_phi)*(OCR_trend**sin_phi)
        index = np.nonzero(K0_OC > max_k0_C)
        K0_OC[index] = max_k0_C # OCR cannot be less than one        
        # phi=29.5 * (Bq**0.121)*(np.log10(qt)+0.256+0.336*Bq)
        # phi_rad = phi*3.1415/180.0
        # sin_phi = np.sin(phi_rad)
        # k02 = (1-sin_phi)*(OCR_trend**sin_phi)
        K0_NC = (1-sin_phi)
 
        axs[0].scatter(qc, depth ,  label="qc-"+Soil_unit,color=colors[col])
        axs[0].legend(loc='best',fontsize=14)
        axs[0].set_xlabel('Cone resistance [MPa]', fontsize = 14)
        axs[0].set_ylabel('Depth [m]', fontsize = 14)
        axs[0].set_ylim([0, max(Depth_density)+5])
        axs[0].tick_params(direction='out', length=6, width=2, grid_alpha=0.5, labelsize=14)
        axs[0].invert_yaxis()
        
        # axs[1].scatter(OCR_cpt_Lunne, depth ,  label="OCR-Mayne (2009)-"+Soil_unit,color=colors[col])
        # axs[1].scatter(OCR_pred_Pc, depth ,  label="OCR-fit-Pc"color=colors[col])
        # axs[1].scatter(OCR_pred_PL, depth ,  label="OCR-fit-Power Law")
        axs[1].plot(OCR_trend, depth , linestyle='dashed', label="OCR-site trend-"+Soil_unit,color=colors[col])
        axs[1].legend(loc='best',fontsize=14)
        axs[1].set_xlabel('OCR [-]', fontsize = 14)
        axs[1].set_ylim([0, max(Depth_density)+5])
        axs[1].tick_params(direction='out', length=6, width=2, grid_alpha=0.5, labelsize=14)
        axs[1].invert_yaxis()
        
        axs[2].scatter(K0_OC, depth, label="K0-OC-"+Soil_unit,color=colors[col])
        # axs[2].plot(K0_NC, depth , linestyle='dashed', label="K0-NC-"+Soil_unit,color=colors[col])
        axs[2].legend(loc='best',fontsize=14)
        axs[2].set_ylim([0, max(Depth_density)+5])
        axs[2].invert_yaxis()
        axs[2].tick_params(direction='out', length=6, width=2, grid_alpha=0.5, labelsize=14)
        axs[2].set_xlabel('K0 [-]', fontsize = 14)    
        
        axs[4].scatter(Su_cpt, depth ,  label="Nkt="+str(round(Nkt,1))+"-"+Soil_unit,color=colors[col])
        axs[4].plot(Su_input, depth , linestyle='dashed', label="Lab-"+Soil_unit,color=colors[col])
        #axs[3].scatter(Dr_Baldi, depth , label="Baldi")
        axs[4].legend(loc='best',fontsize=14)
        axs[4].set_xlabel('Su [kPa]', fontsize = 14)        
        axs[4].set_ylim([0, max(Depth_density)+5])
        axs[4].tick_params(direction='out', length=6, width=2, grid_alpha=0.5, labelsize=14)
        axs[4].invert_yaxis()
        
        axs[5].scatter(phi, depth ,  label="CPT-"+Soil_unit,color=colors[col])
        axs[5].legend(loc='best',fontsize=14)
        axs[5].set_xlabel('φ [deg]', fontsize = 14)          
        axs[5].set_ylim([0, max(Depth_density)+5])
        axs[5].tick_params(direction='out', length=6, width=2, grid_alpha=0.5, labelsize=14)
        axs[5].invert_yaxis()
        
        Dr_fugro_sat = np.zeros(len(depth))
        # phi_lab = np.zeros(len(depth))
        for i in range(len(depth)):
            df_temp=[depth[i],qc[i],fs[i],qt[i],phi[i],Dr_fugro_sat[i],K0_NC[i],K0_OC[i],OCR_cal[i],Su_cpt[i],sigmv[i],Soil_unit]
            df_length = len(df_post_processed_data)
            df_post_processed_data.loc[df_length] = df_temp

    col=col+1
    
plt.suptitle("Location - "+locations[0],fontsize=20)
plt.savefig("Location - "+locations[0]+'.png')

