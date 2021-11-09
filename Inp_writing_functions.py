# -*- coding: utf-8 -*-
"""
Created on Mon Dec 14 11:00:59 2020

@author: CGQU
"""
################################## Writing test.inp #################################

def write_DSS_inp(test_name,df,item):
    f= open("test.inp","w+")
    f.write("outputFile.out\n")
    f.write("*LinearLoad\n")
    f.write(str(df['N_iter'][item])+" "+str(df['N_inter'][item])+" 1.0 "+str(df['N_data_written'][item])+" // ninc, maxiter, deltaTime\n")
    f.write("*Cartesian\n")
    f.write("1 0 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 11\n")
    f.write("1 0.0 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 22\n")
    f.write("1 0.0 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 33\n")
    f.write("1 "+str(df['Shear_Strain'][item])+ " // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 12\n")
    f.write("0 0.0 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 13\n")
    f.write("0 0.0 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 23\n")
    f.close()

def write_TX_inp(test_name,df,item):    
    f= open("test.inp","w+")
    f.write("outputFile.out\n")
    f.write("*LinearLoad\n")
    f.write(str(df['N_iter'][item])+" "+str(df['N_inter'][item])+" 0.05 "+str(df['N_data_written'][item])+" // ninc, maxiter, deltaTime\n")
    f.write("*Cartesian\n")
    if df['Comp/Ext'][item]==0:
        f.write("0 "+str(df['Applied_change'][item])+ " // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 11\n")
        f.write("1 0.0 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 22\n")
        f.write("1 0.0 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 33\n")
        f.write("0 0.0 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 12\n")
        f.write("0 0.0 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 13\n")
        f.write("0 0.0 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 23\n")
    else:
        f.write("1  0 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 11\n")
        f.write("0 "+str(df['Applied_change'][item])+ " // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 22\n")
        f.write("0 "+str(df['Applied_change'][item])+ " // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 33\n")
        f.write("0 0.0 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 12\n")
        f.write("0 0.0 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 13\n")
        f.write("0 0.0 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 23\n")               
    f.close()
    
def write_CyclicTX_inp(test_name,df,item):                  
    f= open("test.inp","w+")
    f.write("outputFile.out\n")
    f.write("*Repetition\n")
    f.write("1 "+str(df['Ncycles'][item])+" // nsteps, nRepetitions\n")
    f.write("*CirculatingLoad\n")
    f.write(str(df['N_iter'][item])+" "+str(df['N_iter_iter'][item])+" 1.0 "+str(df['Nstep'][item])+" // ninc, maxiter, deltaTime\n")
    f.write("*Cartesian\n")
    f.write("1 "+str(df['Applied_change'][item])+ " 0.0 0.000 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 11\n")
    f.write("1 0.0 0.0 0.000 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 22\n")
    f.write("1 0.0 0 0.00 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 33\n")
    f.write("0 0.0 0 0.00 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 12\n")
    f.write("0 0.0 0 0.00 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 13\n")
    f.write("0 0.0 0 0.00 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 23\n")
    f.close()

def write_Oed_inp(test_name,df,item):    
    f= open("test.inp","w+")
    f.write("outputFile.out\n")
    f.write("*LinearLoad\n")
    f.write(str(df['N_iter'][item])+" "+str(df['N_inter'][item])+" 1.0 "+str(df['N_data_written'][item])+" // ninc, maxiter, deltaTime\n")
    f.write("*Cartesian\n")
    f.write("1 "+str(df['Applied_change'][0])+" 0.0 0.000 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 11\n")
    f.write("0 0.0 0.0 0.000 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 22\n")
    f.write("0 0.0 0 0.00 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 33\n")
    f.write("0 0.0 0 0.00 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 12\n")
    f.write("0 0.0 0 0.00 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 13\n")
    f.write("0 0.0 0 0.00 // 1-stress/0-strain controlled, amplitude, phase, linear load ->comp. 23\n")
    f.close()
    

################################## Writing initial conditions.inp #################################
    
def write_initial_cond(test_name,df,item,sigma,Nstate_var):

    f= open("initialconditions.inp","w+")
    f.write("6 // ntens\n")
    f.write(str(sigma[0])+" //   stress(1)\n")
    f.write(str(sigma[1])+" //   stress(2)\n")
    f.write(str(sigma[2])+" //   stress(3)\n")
    f.write("0.00000 //   stress(4)\n")
    f.write("0.00000 //   stress(5)\n")
    f.write("0.00000 //   stress(6)\n")
    f.write(str(Nstate_var)+ " // nstatv\n")
    f.write(str(df['e0'][item])+"000 //   stress(1)\n")
    for i in range(int(Nstate_var)-1):
        f.write("0.00000 //   stress("+str(i+2)+")\n")
    f.close()

def sigma_test(test_type,df,i):
    sigma=[]
    if test_type=='DSS':
        sigma.append(df['eff_v_stress'][i])
        sigma.append(0)
        sigma.append(0)
    elif test_type=='TXD':
        sigma.append(df['sigma1_init'][i])
        sigma.append(df['sigma3_init'][i])
        sigma.append(df['sigma3_init'][i])
    elif test_type=='CyclicTX':
        sigma.append(df['sigma1_init'][i])
        sigma.append(df['sigma3_init'][i])
        sigma.append(df['sigma3_init'][i])        
    elif test_type=='Oed':
        sigma.append(df['sigma1_init'][i])
        sigma.append(0)
        sigma.append(0)

    return sigma

################################## Writing parameters.inp ########################################

def write_params(all_var_names,const_names,const_values,var_names,var_values,constitutive_model):
    
# =============================================================================
#     if constitutive_model=="HS_small":
#         
#         transl_matrix=["Weight","E50","Eoed","Eur","m","phi","psi","c","poison_ratio","pref","Rf","Tension_cut_off","OCR","POP","K0_nc","nu_und","e0","max","flow_rule","G0,gamma_07","0_always","model_number"]
#     
# =============================================================================
    
    #Translator matrix 
    ##towritematrix() is the result of the assembeling of cons and var 
    
    
    f= open("parameters.inp","w+")
    f.write("HardeningSoil64.dll // cmname (This is an end-of-line comment)\n")
    if all_var_names[0] in const_names:
        f.write(str(const_values[0])+" // nprops\n")
    else:
        f.write(str(var_values[0])+" // nprops\n")
    for y in range(len(all_var_names)-2):
        if all_var_names[y+1] in var_names:
            ind=var_names.index(all_var_names[y+1])
            f.write(str(var_values[ind])+ "//   Props("+str(y+1)+")\n")            
        else:
            ind=const_names.index(all_var_names[y+1])
            f.write(str(const_values[ind])+ "//   Props("+str(y+1)+")\n")
    if all_var_names[-1] in const_names:               
        f.write(str(const_values[-1])+ "       //  model number: 1\n")
    else:
        f.write(str(var_values[-1])+ "       //  model number: 1\n")
    f.close()
    
    
    
    
    
    
    
    
    
    