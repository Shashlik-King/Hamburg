# -*- coding: utf-8 -*-
"""
Created on Wed Apr 27 16:52:33 2022

@author: MUJI

# panda dataframe for storing data
# https://pandas.pydata.org/docs/user_guide/10min.html
# Got TX function from G:\Other computers\My Laptop\work1\009 EW DD\clay_calibration

"""


from plxscripting.easy import *
import numpy as np; # np.set_printoptions(threshold=np.nan)
import os
import math
import matplotlib.pyplot as plt
import matplotlib
import pandas as pd
from scipy.interpolate import interp1d
import scipy.optimize as opt
from pylab import figure, axes, pie, title, show
from datetime import datetime



PASS_string='EReNc#6S^DX7hgt$';# PASTE THE PASSWORD
s_t, g_t = new_server('localhost', 10000, password=PASS_string)



def element_test_GHS(g_t, E50ref, EoedRef, EurRef, G0ref, gamma07, powerm, cref, phi, psi, K0, MaximumStrain,Steps,sigmaV,DrainageType, test_type, material_model):


    #######################Assign Material Properties#######################
    
    # E50ref  = 100000
    # EoedRef = 100000
    # EurRef  = 300000
    # powerm  = 0.5 
    # cref    = 467.0
    # phi     = 12.0*2;
    # psi     = 0.0
    
    nu=0.25;
    
    Materials=g_t.Materials; print('Function <element_test_GHS> was called')
    g_t.setproperties(Materials[0],'SoilModel',material_model); # hardening (3) soil model with small stiffness (4)
    g_t.setproperties(Materials[0],'DrainageType',DrainageType);
    g_t.setproperties(Materials[0],'E50ref',E50ref);
    g_t.setproperties(Materials[0],'EoedRef',EoedRef);
    g_t.setproperties(Materials[0],'EurRef',EurRef);
    g_t.setproperties(Materials[0],'powerm',powerm);cref
    g_t.setproperties(Materials[0],'cref',cref);
    g_t.setproperties(Materials[0],'phi',phi);
    g_t.setproperties(Materials[0],'psi',psi);
    g_t.setproperties(Materials[0],'TensionCutOff',True);
    g_t.setproperties(Materials[0],'TensileStrength',0);
    g_t.setproperties(Materials[0],'nu',nu);
    g_t.setproperties(Materials[0],'nuu',0.495);
    g_t.setproperties(Materials[0],'gammaUnsat',19);
    g_t.setproperties(Materials[0],'gammaSat',19);
    
    if material_model==4:
        g_t.setproperties(Materials[0],'G0ref',G0ref);
        g_t.setproperties(Materials[0],'gamma07',gamma07);
    
    #g_t.setproperties(Materials[0],'Gref',EurRef/2/(1+nu));
    # nu=0.3; K0=1; OCR=1;
    # params = [("MaterialName", "Soil_test"), 
    # ("SoilModel", 4),
    # ("DrainageType", DrainageType),
    # ("gammaUnsat", 19),
    # ("gammaSat", 19),
    # ("Gref", EurRef/2/(1+nu)),
    # ("E50ref", E50ref),
    # ("EoedRef", EoedRef),
    # ("powerm", powerm),
    # ("G0ref", G0ref),
    # ("gamma07", gamma07),
    # ("nu", nu),
    # ("cref", cref),
    # ("cinc", 0),
    # ("verticalref", 0),
    # ("Rinter", 1),
    # ("K0Determination", 0),
    # ("K0Primary", K0),
    # ("OCR", OCR),
    # ("K0PrimaryIsK0Secondary", True),
    # ("K0nc", 1 - math.sin(math.radians(phi))),
    # ("phi", phi),
    # ("psi", psi)]
    # make_soilmat(g_t,params,Materials[0])
    
    Drainage_String = g_t.echo(Materials[0].DrainageType);
    Drainage_String=Drainage_String[23:-4];
    print(Drainage_String);
    
    ####################### Test Parameters ################################
    # sigmaV = 100; MaximumStrain=15;
    # Steps=200;
    
    if DrainageType == 0:
        Isundrained=int(0);
        print("Drained Analysis was conducted")
    else:
        Isundrained=int(1);

    
    if test_type =="DSS":
    
        
        IsK0consolidation=1; K0=1;
        #MaximumStrain=15; Steps=200;
        AbsSigyyinit=abs(sigmaV);
        
        DSS = g_t.DSS;
        DSS.AbsSigyyinit=AbsSigyyinit; 
        DSS.MaximumShearStrain=MaximumStrain;
        DSS.Behaviour=Isundrained; # 0: drained, 1: undrained
        DSS.Consolidation=IsK0consolidation;
        DSS.PreconsolidationPressure = 0;

        if IsK0consolidation==1:
            DSS.K0=K0;
        DSS.Steps=Steps;
        
        ####################### DSS Plaxis Results #############################
        
        g_t.calculate(DSS);
        Gamxy=DSS.Results.Gamxy.value; #print(Gamxy);
        Sigxy=DSS.Results.Sigxy.value; #print(Sigxy);
        
        strain = Gamxy;
        stress = Sigxy
        
    elif test_type =="Oedometer":
    
       Oedometer = g_t.Oedometer;
       Oedometer.PreconsolidationPressure = 0;
       Oedometer.PhaseTable[0].Siginc = -abs(sigmaV);
       Oedometer.PhaseTable[0].Duration=1;
       Oedometer.Steps=Steps;
       
       ####################### DSS Plaxis Results #############################
       
       g_t.calculate(Oedometer);
       SigyyE=Oedometer.Results.SigyyE.value; 
       Epsyy=Oedometer.Results.Epsyy.value; 
       
       strain = list(-np.array(Epsyy));
       stress = list(-np.array(SigyyE));
       
       
    elif test_type =="TXC":

        Epsyyinc = -abs(MaximumStrain)/1.5;
        Sigyyinit = -abs(sigmaV) ;
        Sigxxinit = -abs(sigmaV)*K0;
        
        TX = g_t.General;
        TX.Behaviour=int(Isundrained); # 0: drained, 1: undrained
        
        # Boundary conditions: yy
        TX.BoundaryConditionyy="FixedStrain"; # stress increment
        TX.Sigyyinit=Sigyyinit; TX.Phases[0].Epsyyinc = Epsyyinc
        
        # Boundary conditions: xx and zz
        TX.BoundaryConditionxx="FixedStress"; # stress increment
        TX.BoundaryConditionzz="FixedStress"; # stress increment
        TX.Sigxxinit=Sigxxinit; TX.Phases[0].Sigxxinc=0;
        TX.Sigzzinit=Sigxxinit; TX.Phases[0].Sigyyinc=0;
        
        # Boundary conditions: xy
        TX.BoundaryConditionxy="FixedStrain"; # strain increment
        TX.Sigxyinit = 0;
        TX.Phases[0].Gamxyinc=0;
        
        # General test settings
        TX.Phases[0].Steps = Steps
        
        # Run and get results
        g_t.calculate(TX);
        
        #out1=dir(TX.Results); #g_t.echo(TX.Results)
        Epsyy  = -np.array(TX.Results.Epsyy.value); #print(Epsyy);
        SigyyE = -np.array(TX.Results.SigyyE.value); #print(Sigyy);
        SigxxE = -np.array(TX.Results.SigxxE.value); #print(Sigxx);
        SigyyMinusSigxx= np.subtract(SigyyE, SigxxE);
        
        strain = list(Epsyy);
        stress = list(SigyyMinusSigxx/2);
       
    
    return strain, stress, Drainage_String




# E50ref  = 100000
# EoedRef = 100000
# EurRef  = 300000
# powerm  = 0.5 
# cref    = 1
# phi     = 12.0*2;
# psi     = 0.0

#sigmaV = 100; 
MaximumStrain=15;
Steps=300;


test_type="TXC"; #TXC, DSS


curve_id = []
Comments = []
time_stamp = [];
sue_suc=[];
suDSS_suc=[];

#dir1="\\COWI.net\projects\A230000\A234416\20-Data\Geo\\02_FEM\FEM_models_representatives\Q3_glauconite";
# dir1="G:\Other computers\My Laptop\work1\\009 EW DD\QA_PlaxisInput";
# input_filename = dir1 + "\\"+"Data_Base_S3.xlsx"


input_filename = 'input_run_plaxis_test_GHS_v3'+".xlsx"

rows2skip = 0;
# xl = pd.ExcelFile(inventory_excel)
# excel_sheets=(xl.sheet_names)
Input=pd.read_excel(input_filename, sheet_name="Input")
fig_name1={};

depth_bot = np.cumsum(Input["t_i"]); var1=pd.Series(0);
depth_top = var1.append(depth_bot[0:-2]); depth_top = depth_top.reset_index(drop=True)

out1={};
#depth_mid =


df1 = pd.DataFrame(np.ones(shape=(len(Input),11))*0)



#### Loop over each row of the Input

#for ii in [0,1,2]: #range(0,len(Input)):
for ii in range(0,len(Input)):

    if  Input["c_i"][ii] ==1:
        
        try:
            print("############################################################")
            print("############################################################")

            print(ii)
            
            Unit1=str(Input['Unit'][ii]);

            # legend_string="Layer "+str(ii+1)+" - t_i = {:.2f} ".format(Input["t_i"][ii]) # https://mkaz.blog/code/python-string-format-cookbook/
            legend_string=Input['legend'][ii];
            
            print(legend_string);
            
            file_name1=str(Input['file_name'][ii]);

            if test_type=="TXC":
                file_name1=file_name1[0:-5]+"_CAU"+".xlsx"
            
            
            folder_name1=str(Input['folder_name'][ii]);
            sheet_name1=str(Input['sheet_name'][ii]);

            
            #curve_id.append("id-"+str(ii+1).zfill(3)+"_"+Unit1+"_"+file_name1[0:-5]+"_"+sheet_name1);
            time_stamp.append(str(datetime.now()));
            
            curve_id.append("id-"+str(ii+1).zfill(3))
    
            cwd = os.getcwd(); #os.chdir(cwd_plots)
    
    
            full_file_name1 = folder_name1+"\\"+file_name1;
            msg1 = "stress-strain data in Sheet <<"+ sheet_name1 +">> inside <<"+ full_file_name1+">>"; 
            print("Reading "+msg1)
            
            
            full_file_name = folder_name1+"\\"+file_name1;
            df1 = pd.read_excel(full_file_name, sheet_name=sheet_name1,skiprows=rows2skip)[['Shear strain','Stress ratio']].dropna()
            df1.columns=['Shear strain','Stress ratio']
            
            
            y_multiplier = Input["y_multiplier"][ii];
            x_multiplier = Input["x_multiplier"][ii];
            
            
            Tau_accu=(df1['Stress ratio']*y_multiplier).tolist()
            gamma_accu=(df1['Shear strain']*x_multiplier).tolist()
            
            if max(gamma_accu)<15:
                gamma_accu.append(15) 
                Tau_accu.append(max(Tau_accu))
               
            

            #Sigyyinit= 100 # 
            
            material_model=3; # 3 (HS) or 4 (HS with small)

            E50ref  = Input["E_50"][ii]
            EoedRef = Input["E_oed"][ii]
            EurRef  = Input["E_ur"][ii]
            powerm  = Input["m"][ii] 
            cref    = Input["c_i"][ii] 
            phi     = Input["phi_i"][ii]
            K0      = Input["K0"][ii]
            psi     = 0;
           
            gamma07 = 0; #Input["gamma07"][ii]
            G0ref   = 0; #Input["G0"][ii];
            
            #Sigyyinit=100*(Input["Sigma_ref"][ii]/100)**(1/0.9);
            Sigyyinit = Input["Sigyyinit"][ii]
            
            
            print("phi = "+str(phi)+", c = "+str(cref));
            print("E50ref = "+str(E50ref)+", EoedRef = "+str(EoedRef));
            print("Sigyyinit = "+str(Sigyyinit));
            

            
            DrainageCesar = Input["Drainage"][ii];
            #DrainageCesar = 0;
            

            if DrainageCesar== 1:
                DrainageType = 2; #  "Undrained B"
                
            elif DrainageCesar == 2:
                DrainageType = 1 # "Undrained A"
                #DrainageType = 0; 
                
            else:
                DrainageType = 0 # Drained
                
            
            #Drainage= "drained"; #Input["Drainage"][ii];
            

            # sue_suc.append(Input["sue_suc"][ii])
            # suDSS_suc.append(Input["suDSS_suc"][ii])
            # MaximumStrain=Input["max_strain"][ii]
            # G_su=Input['G_su'][ii]
            
            # # Plotting
            
        
            strain, stress, Drainage_String = element_test_GHS(g_t, E50ref, EoedRef, EurRef, G0ref, gamma07, powerm, cref, phi, psi, K0, MaximumStrain,Steps, Sigyyinit, DrainageType,test_type,material_model);  
            strain=np.array(strain)*100;
            
            out1[ii]=[ii+1, Input["t_i"][ii], depth_top[ii],depth_bot[ii],Sigyyinit,Input["Sigma_ref"][ii], stress[-1], phi, cref, Drainage_String,test_type];
            
            df1.loc[ii,0]=ii+1;
            df1.loc[ii,1]=Input["t_i"][ii];
            df1.loc[ii,2]=depth_top[ii];
            df1.loc[ii,3]=depth_bot[ii];
            df1.loc[ii,4]=Sigyyinit;
            df1.loc[ii,5]=Input["Sigma_ref"][ii];
            df1.loc[ii,6]=stress[-1];
            df1.loc[ii,7]=phi
            df1.loc[ii,8]=cref
            df1.loc[ii,9]=Drainage_String
            df1.loc[ii,10]=test_type

            
            fig = figure(1,figsize=(8,5))
            left, bottom, width, height = 0.1, 0.1, 0.8, 0.8
            ax = fig.add_axes([left, bottom, width, height]) 
            plt.grid(True, which="both")
            title_string = curve_id[-1]+" - "+legend_string + " - " + Drainage_String;
            ax.set_title(title_string, fontsize=12)
            

            if test_type=="DSS":
                plt.plot(gamma_accu, Tau_accu,'-',color='red',marker='o',markerfacecolor='red', markersize=5, label="Cyclic Contour DSS - ASR")
                plt.plot(strain, stress,'-',color='blue',marker='o',markerfacecolor='blue', markersize=5, label="Plaxis HS")
                ax.set_xlabel('Shear strain [%]',fontsize=16)
                ax.set_ylabel('Shear stress [KPa]',fontsize=16)
                
            elif test_type=="TXC":
                plt.plot(gamma_accu, Tau_accu,'-',color='red',marker='o',markerfacecolor='red', markersize=5, label="Cyclic Contour TX - ASR")
                plt.plot(strain, stress,'-',color='blue',marker='',markerfacecolor='blue', markersize=5, label="Plaxis HS")
                ax.set_xlabel('Axial strain [%]',fontsize=16)
                ax.set_ylabel('Shear stress [KPa]',fontsize=16)
                
                 
            elif test_type=="Oedometer":
                plt.plot(strain, stress,'-',color='blue',marker='o',markerfacecolor='blue', markersize=5, label="Plaxis HS")
                ax.set_xlabel('Axial strain [%]',fontsize=16)
                ax.set_ylabel('Axial stress [KPa]',fontsize=16)
            
            #plt.ylim(bottom=0,top=100)
            
            plt.legend(loc="lower right")
            
            full_fig_name=cwd+"\\"+test_type+"_"+curve_id[-1]+"_"+Drainage_String+'.png';
            plt.savefig(full_fig_name,dpi=300)
            plt.show()
            
            
            
        except Exception as error_variable:
            
            error_string=str(error_variable);
            print("^^^^ There was an ERROR for : layer "+ str(ii+1) +" ^^^^")
            print(error_string)
            print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")

            pass
        
column_headers = ["Layer", "t_i", "depth_top","depth_bot","Sig_v","Sig_ref", "suD","phi","c","Drainage_String","test_type"];     

df2=pd.DataFrame(out1);
df2=df2.T;
df2.columns  = column_headers;
df2.to_csv('output_muji.csv',mode='a'); 


# df1.columns  = column_headers;
# df1.to_csv('output_shear_strength_profile_for_GHS_model_in_Plaxis.csv',mode='a'); 

        








