# -*- coding: utf-8 -*-
"""
Created on Thu Oct 15 13:27:49 2020

@author: ENRN
"""
import os
import mysql.connector
import pandas
import sql_connect

class Copilod(sql_connect.SQLconnect):
    __version__ = '2.0.1'

    def __init__(self, database):
        super().__init__(database)
        self.__Schema = self.Database
    
    def get_login(self):
        """Methods the retrieves login dictionaries for databases in login file
        
        Parameters:
            
        Return:
        logins : dict(dict(str))
            dictionary of dictionaries with login information
        """
        # user folder
        relPath = os.path.expanduser('~')
        # login file with 
        file = os.path.join(relPath, r'.my.cnf')       
        with open(file) as f:
            content = f.read().splitlines()
        
        # create dictionary of logins
        logins = {}
        logins = sql_connect.SQLconnect.to_login(logins, content)
    
        return logins

    
    def connect(self):
        """Establises the connection to the database
        
        Parameters:
        
        Return:
            
        """
        try:
            connection = mysql.connector.connect(
                host = self.Logindata['host'],
                user = self.Logindata['user'],
                password = self.Logindata['password'],
                database = self.Database
                )
            if connection.is_connected():
                self.SQL = connection
                self.Tables = self.tables()
                # print message
                print('You have successfully connected to..' 
                      '\t{:s}'.format(self.Database))
        except:
            print("Error while connection to MySQL")

    

        
        

        


