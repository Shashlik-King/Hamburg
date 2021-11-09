# -*- coding: utf-8 -*-
"""
Created on Tue Jan 12 14:28:21 2021

@author: ENRN
"""

# -*- coding: utf-8 -*-
"""
Created on Thu Oct 15 13:27:49 2020

@author: ENRN
"""
import os
import psycopg2
import psycopg2.extras
import pandas
import sql_connect

class OneSource(sql_connect.SQLconnect):
    __version__ = '2.0.1'
    
    def __init__(self, database):
        super().__init__(database)
        self.__Schema = 'public'
    
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
        file = os.path.join(relPath, r'.onesource.cnf')       
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
            connection = psycopg2.connect(
                host = self.Logindata['host'],
                user = self.Logindata['user'],
                password = self.Logindata['password'],
                database = self.Database
                )
            if connection.closed == 0:
                self.SQL = connection
                self.Tables = self.tables()
                # print message
                print('You have successfully connected to..' 
                      '\t{:s}'.format(self.Database))
        except:
            print("Error while connection to postgres SQL")
        
    def __insert(self, sql, values, table):
        cursor = self.SQL.cursor()
        psycopg2.extras.execute_batch(cursor, sql, values)
        print("\t\t{:d} rows was inserted into {:s}".format(cursor.rowcount, 
              table))       
        #Commit to server and close cursor
        self.SQL.commit()
        cursor.close()
    
    def is_connected(self):
        if not self.SQL.closed == 0:
            raise Exception('Error: Database not connected')
        return True
    
    def insert_statement(self, *args):
        sql = "INSERT INTO {:s} ({:s}) VALUES ({:s})".format(args[1:])
        return sql

    

        
        

        


