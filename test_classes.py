# -*- coding: utf-8 -*-
"""
Created on Wed Dec 16 15:21:32 2020

@author: CGQU
"""
import numpy as np

class real_test():  
    
    def __init__(self,X,Y):
        self.X=np.array(X)
        self.Y=np.array(Y)
        
class simulated_test():
    
    def __init__(self,var,X_hat,Y_hat):
        self.parm_var=var
        self.X_hat=np.array(X_hat)
        self.Y_hat=np.array(Y_hat)