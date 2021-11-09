# -*- coding: utf-8 -*-
"""
Created on Mon Jan 11 17:26:42 2021

@author: CGQU
"""

def CID_GT1(test_name):
    
    import pandas as pd
    
    xl = pd.ExcelFile(test_name)
    excel_sheets=(xl.sheet_names)
    df1=pd.read_excel(test_name,excel_sheets[0],skiprows=1)
    df1.drop(df1.index[[0,1]],inplace=True)
    df1 = df1.reset_index(drop=True)
    Initial_cell_pressure=df1['Details6'][16]
    Borehole=df1['Details6'][3]
    Test_number=df1['Details6'][7]
    df=df1[['strain','strain.1','q.4',"p'.4"]]
    df.dropna()
    df.columns=['eps1','epsv','q','p']
    df=df.dropna(how='all')
    df["eps1"] = df.eps1.astype(float)   
    df["epsv"] = df.epsv.astype(float)  
    df["q"] = df.q.astype(float)
    df["p"] = df.p.astype(float)
# =============================================================================
#     
#     df["eps1"]=df["eps1"]/100
#     df["epsv"]=df["epsv"]/100
#     
# =============================================================================
    return Initial_cell_pressure, df, Borehole, Test_number

def CID_GT2(test_name):
    
    import pandas as pd
    
    xl = pd.ExcelFile(test_name)
    excel_sheets=(xl.sheet_names)
    df1=pd.read_excel(test_name,excel_sheets[3],skiprows=6)
    df1.drop(df1.index[[0]],inplace=True)
    df1 = df1.reset_index(drop=True)
    df=df1[['ea','Change','q',"p'"]]
    df=df.dropna()
    
    df.columns=['eps1','epsv','q','p']
    V0=pd.read_excel(test_name,excel_sheets[0],skiprows=38)['Unnamed: 17'][1]
    BH=pd.read_excel(test_name,excel_sheets[0],skiprows=1)['Unnamed: 37'][0]
    Initial_cell_pressure=pd.read_excel(test_name,excel_sheets[2],skiprows=25)['1st  Stage'][3]*47.88
    e0=pd.read_excel(test_name,excel_sheets[2],skiprows=17)['e'][0]
    
    Test_number="Not Defined"
    
    df["eps1"] =df['eps1'].astype(float)
    df["epsv"] =df['epsv'].astype(float)
    df["q"] =df['q'].astype(float)
    df["p"] =df['p'].astype(float)
    
    df["eps1"]=df["eps1"]   #/100
    df['epsv']=df['epsv']*100/V0
    df['q']=df['q']*47.88
    df['p']=df['p']*47.88
        
    return Initial_cell_pressure, df, BH, Test_number,  e0

def TPC(test_name,excel_sheets,i):
    
    import pandas as pd
    
    Initial_cell_pressure=round(float(pd.read_excel(test_name,excel_sheets[0])['Unnamed: '+str(3+i*8)][0][4:])*98.0665)
        
    if i==0:
        df1=pd.read_excel(test_name,excel_sheets[0],skiprows=2)[["axial strain e1%","Volume change cm3","q ,kgf/cm2","p ,kgf/cm2","excess pore pr,kgf/cm2"]]
    if i==1:
        df1=pd.read_excel(test_name,excel_sheets[0],skiprows=2)[["axial strain e1%.1","Volume change cm3.1","q ,kgf/cm2.1","p ,kgf/cm2.1","excess pore pr,kgf/cm2.1"]]
    if i==2:
        df1=pd.read_excel(test_name,excel_sheets[0],skiprows=2)[["axial strain e1%.2","Volume change cm3.2","q ,kgf/cm2.2","p ,kgf/cm2.2","excess pore pr,kgf/cm2.2"]]
        
    df1 = df1.reset_index(drop=True).dropna()    
    #df1.drop(df1.index[[0,1]],inplace=True)
    df1 = df1.reset_index(drop=True)
    
    df1.columns=['eps1','epsv','q','p','Excess_PWP']
    #df=df.dropna(how='all')
    
    df1["eps1"] = df1.eps1.astype(float)   
    df1["epsv"] = df1.epsv.astype(float)  
    df1["q"] = df1.q.astype(float)
    df1["p"] = df1.p.astype(float)
    df1["Excess_PWP"] = df1.Excess_PWP.astype(float)
    
    df1['q']=df1['q']*98.0665
    df1['p']=df1['p']*98.0665
    df1['Excess_PWP']=df1['Excess_PWP']*98.0665
          
    return Initial_cell_pressure, df1

    
    