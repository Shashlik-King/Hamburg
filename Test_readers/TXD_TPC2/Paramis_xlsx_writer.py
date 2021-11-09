# -*- coding: utf-8 -*-
"""
Created on Wed Jan 13 16:08:26 2021

@author: CGQU
"""

def write_postprocessing(data,test_name):
    
    import xlsxwriter
    import numpy as np

    
    i=0
    
    for tests in data:
        
        
        workbook1 = xlsxwriter.Workbook(test_name[i]+".xlsx")
        bold = workbook1.add_format({'bold': True})
        
        worksheet1=workbook1.add_worksheet("Test_data")
        worksheet2=workbook1.add_worksheet("Relevant_info")
        
        worksheet1.set_column('A:G', 20)
    
        worksheet1.write(0, 0, 'Axial_Strain [%]', bold)
        worksheet1.write(0, 1, 'dev_stress [kPa]', bold)
        worksheet1.write(0, 2, 'p [kPa]', bold)
        worksheet1.write(0, 3, 'epsv [%]', bold)
        worksheet1.write(0, 4, 'Excess_PWP [kPa]', bold)
        worksheet1.write(0, 5, 'Sigma_1 [kPa]', bold)
        worksheet1.write(0, 6, 'Sigma_3 [kPa]', bold)
        
        worksheet1.write_column(1, 0, data[tests].eps1)
        worksheet1.write_column(1, 1, data[tests].q)
        worksheet1.write_column(1, 2, data[tests].p)
        worksheet1.write_column(1, 3, data[tests].epsV)
        worksheet1.write_column(1, 4, data[tests].pwp)
        worksheet1.write_column(1, 5, data[tests].S1)
        worksheet1.write_column(1, 6, data[tests].S3)
        #worksheet1.All_tests_data[tests].eps1
     
        worksheet2.set_column('A:B', 30)
        
        worksheet2.write(0, 0, 'Info', bold)
        #worksheet2.write(1, 0, 'Borehole', bold)
        worksheet2.write(1, 0, 'e0', bold)
        worksheet2.write(3, 0, 'Dr', bold)
        worksheet2.write(2, 0, 'Initial_conf_pressure[kPa]', bold) 
        #worksheet2.write(5, 0, 'c', bold)
        #worksheet2.write(6, 0, 'phi', bold)
        #worksheet2.write(7, 0, 'm', bold)
        #worksheet2.write(8, 0, 'E50', bold)
        #worksheet2.write(9, 0, 'E50_ref', bold)
        #worksheet2.write(10, 0, 'Dr_related param', bold)
        #worksheet2.write(11, 0, 'X0 (E50_ref = Dr*X0)', bold)
        #worksheet2.write(12, 0, 'X1 (m = X1-Dr*X2)', bold)
        #worksheet2.write(13, 0, 'X2 (m = X1-Dr*X2)', bold)     
        #worksheet2.write(14, 0, 'Phi_cr (Phi = Phi_cr+Dr*X3)', bold)
        #worksheet2.write(15, 0, 'X3 (Phi = Phi_c+Dr*X3)', bold)
        
        worksheet2.write(0, 1, 'values', bold)
        #worksheet2.write(1, 1, data[tests].BH)
        worksheet2.write(1, 1, data[tests].Eini)
        #worksheet2.write(3, 1, Dr[i])
        worksheet2.write(2, 1, data[tests].conf_pressure)
        #worksheet2.write(5, 1, c[i])
        #worksheet2.write(6, 1, phi[i])
        #worksheet2.write(7, 1, m[i])
        #worksheet2.write(8, 1, E50[i])
        #worksheet2.write(9, 1, E50_ref[i]) 
        #worksheet2.write(10, 1, Dr_calibration)

        
        i=i+1
        
        workbook1.close()
    
    
 

































    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    