# -*- coding: utf-8 -*-
"""
Created on Tue Jan 12 13:35:42 2021

@author: ENRN
"""

# -*- coding: utf-8 -*-
"""
Created on Thu Oct 15 13:27:49 2020

@author: ENRN
"""
import os
import mysql.connector
import psycopg2
import pandas

class SQLconnect:
    """
    A class that allow the user to communicate with a CoPilod SQL data base
    with more python like command

    Attributes
    ----------
    Database  : str
        name of the database
    LoginData : dict(dict(str))
        dictionary of login data dictionaries
    SQL       : SQL connector
        connection to database
    Table     : tuple(str)
        names of the tables in the database
    Schema    : str
        name of schema for tables


    Methods
    -------        
    clear_table()
    
    close()
    
    connect() 
    
    get_table()
    
    insert()
    
    show_grants()
    
    tables()
    
    table_columns()
    
    Static Methods
    --------------
    
    """
    __version__ = '2.0.1'
    __auther__ = 'Esben Rasmussen, ENRN@COWI.COM'

    
    def __init__(self, database):
        """Initializes a copilod instance to connect with copilod database
        
        Parameters:
        database : str
            name of the database to connect to
            
        Return:
        self    : copilod
            connection to copilod
                
        """
        # get dictionary with dictionaries for all databases
        self.__Logins = self.get_login()           
        # check on database
        if not isinstance(database, str):
            raise TypeError('database must be a string')
        if not database in self.__Logins.keys():
            raise Exception('login credentials not found\n valid databases are:'
                            '{:s}'.format(str(tuple(self.__Logins.keys()))))
        # set attributes
        self.Database = database       
        self.Logindata = self.__Logins[database]    # login dict for database
        self.SQL = None                             # database connection
        self.Tables = None                          # tables in database
        self.__Schema = None                        # set to None
    
    @property
    def Schema(self):
        clss = self.__class__.__name__
        return getattr(self, '_'+clss+'__Schema')
    
    @Schema.setter
    def Schema(self, Schema):
        clss = self.__class__.__name__
        if Schema is None:
            setattr(self, '_'+clss+'__Schema', None)
            return None
        if not isinstance(Schema, str):
            raise TypeError('Wrong type: Schema must be string')
        if self.is_connected():
            # get cursor
            cursor = self.SQL.cursor()
            # create SQL command
            sql = ('SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA')
            # execute SQL command
            cursor.execute(sql)
            # fetch result
            schemas = cursor.fetchall()
            schemas = tuple([schema for sch in schemas for schema in sch])
            # check schema input
            if not Schema in schemas:
                raise Exception('{:s} is not a valid schema.\nValid schemas are: '
                                '{:s}'.format(Schema, str(schemas)))
            setattr(self, '_'+clss+'__Schema', Schema)
        else:
            raise Exception('Error: Database not connected')
        
    
    def get_login(self):
        raise NotImplementedError('Connection not implemented on base class'
                                  '- used child class')

    
    def connect(self):
        raise NotImplementedError('Connection not implemented on base class'
                                  '- used child class')
    
    def tables(self):
        """Gets the name of the tables in the database
        
        Parameters:
        
        Return:
        tables : tuple(str)
            tuple of name of tables in database
        
        """

        if not self.is_connected():
            raise Exception('Error: Database not connected')
        # create SQL command
        sql = ('SELECT table_name FROM information_schema.tables')
        # execute SQL command
        cursor = self.SQL.cursor()
        cursor.execute(sql)
        # fetch result
        tables = cursor.fetchall()
        cursor.close()
        # flatten tuple
        tables = tuple([table for tupl in tables for table in tupl])
        
        return tables
        
        
    def get_table(self, table, **kwargs):
        """function that returns a table from a copilod database. Filters can 
        given as keyword arguments
        
        Parameters
        table : str
            name of the table to retrive data from
        kwargs
            keyword argumens. Keyword must be a column in the table. 
            
        Return
        table : dataframe
            a pandas dataframe containing the table data. 
        
        """
        # test connection
        if not self.is_connected():
            raise Exception('Error: Database not connected')
        # test table name
        if not isinstance(table, str):
            raise TypeError('table must be a string')
        SQLconnect.table_check(self, table)
        
        # get table  columns
        cols = self.table_columns(table)
        
        # check validity of keyword
        sql_filter = ''
        if kwargs:
            not_kwargs = list(set(kwargs.keys()) - set(cols))
            if len(not_kwargs) > 0:
                raise Exception('Error: unrecognized table columns: '
                            '{:s}'.format(str(not_kwargs)))
            sql_filter = ' WHERE ' + SQLconnect.sql_filter(list(kwargs.keys()),
                                            list(kwargs.values()))
        # get the cursor        
        cursor = self.SQL.cursor()
        
        # create SQL command
        sql = "select * from " + table + sql_filter
        print('SQL command: {:s}'.format(sql))
        
        # execute command and retrive rows
        cursor.execute(sql)
        data = cursor.fetchall()
        print("\t\t{:d} rows was selected from {:s}".format(cursor.rowcount, 
              table))
        cursor.close()
        
        return pandas.DataFrame(data = data, columns = cols)
    
    
    def get_unique_values(self, table, column):
        """function that returns the unique values for a column in a table
        
        Parameters
        table : str
            name of the table to retrive data from
        column: str
            name of the column
            
        Return
        values : tuple
            unique values in column
        """
        # test connection
        if not self.is_connected():
            raise Exception('Error: Database not connected')
            
        # test table name
        SQLconnect.table_check(self, table)
        # get table  columns
        cols = self.table_columns(table)
        if not isinstance(column, str):
            raise Exception('Error: columns must be given as string')
        if column not in cols:
            raise Exception('Error: column name not recognized. '
                            'Valid columns are: {:s}'.format(str(cols)))
        
        # get the cursor        
        cursor = self.SQL.cursor()
        # create SQL command
        sql = 'SELECT DISTINCT {:s} from {:s}'.format(column, table)
        print('SQL command: {:s}'.format(sql))
        
        # execute command and retrive rows
        cursor.execute(sql)
        data = cursor.fetchall()
        print("\t\t{:d} values was selected from {:s}".format(cursor.rowcount, 
              table))
        cursor.close()
        
        data = tuple([val for v in data for val in v])
        return data
        
    
    def table_columns(self, table):
        """Get the columns of a table in the database
        
        Parameters:
        table : str
            name of the tabele
        
        Return
        cols : tuple (str)
            tuple with names of the columns
        """
        # test connection
        if not self.is_connected():
            raise Exception('Error: Database not connected')
        # test table name
        SQLconnect.table_check(self, table)
        
        # get curser
        cursor = self.SQL.cursor()
        # SQL command
        sql = ('SELECT COLUMN_NAME FROM information_schema.columns WHERE '
               'TABLE_NAME = \'{:s}\' AND table_schema = \'{:s}\''.format(table,
                               self.Schema))
        # execute command
        cursor.execute(sql)
        # fetch result
        cols = cursor.fetchall()
        # results is a tuple with one string for each table. This is translated
        # into one single tuple
        cols = tuple([col for tupl in cols for col in tupl])
        return cols
    
    def clear_table(self, table, **kwargs):
        """Clears all values in a table. Filters can be given by keyword 
        arguments
        
        Parameters
        table : str
            name of the table to retrive data from
        kwargs
            keyword argumens. Keyword must be a column in the table. 
            
        Return
        table : dataframe
            a pandas dataframe containing the table data. 
        
        """
        # test connection
        if not self.is_connected():
            raise Exception('Error: Database not connected')
        
        # test table name
        SQLconnect.table_check(self, table)
        
        # get table  columns
        cols = self.table_columns(table)
        
        # check validity of keyword
        sql_filter = ''
        if kwargs:
            not_kwargs = list(set(kwargs.keys()) - set(cols))
            if len(not_kwargs) > 0:
                raise Exception('Error: unrecognized table columns: '
                            '{:s}'.format(str(not_kwargs)))
            sql_filter = ' WHERE ' + SQLconnect.sql_filter(list(kwargs.keys()),
                                            list(kwargs.values()))
        # get the cursor
        cursor = self.SQL.cursor()        
        #Create SQL command
        sql = "Delete from " + table + sql_filter
        print("SQL command: \t{:s}".format(sql))
        
        #Execure command
        cursor.execute(sql)
        print("\t\t{:d} rows was deleted from {:s}".format(cursor.rowcount, 
              table))
        
        #Commit results to server
        self.SQL.commit()
        cursor.close()
    
    def close(self):
        """Closes the connection to the database
        
        Parameters:
            
        Return:
        
        """
        # close database
        self.SQL.close()
        print("Database: \t{:s} was closed".format(self.Database))
    
    def show_grants(self):
        """Prints the grant of the current user
        
        Parameters:
            
        Return:
            
        """
        # get the curor
        cursor = self.SQL.cursor()
        # execure command
        cursor.execute("SHOW GRANTS")
        # print results
        print(cursor.fetchall()[1][0])
        cursor.close()
    
    def insert(self, table, columns ,values):
        """ Inserts a number of rows into to a table.
        
        Parameters:
        table   : str
            name of the table
        columns : tuple(str)
            name of the columns
        values  : tuple(tuple(str))
            the values to be inserted into the table
        
        Return:
            
        """
        
        # test connection
        if not self.is_connected():
            raise Exception('Error: Database not connected')
        # test table name
        SQLconnect.table_check(self, table)    
        # test columns
        SQLconnect.column_check(self, table, columns)        
        # test values
        SQLconnect.values_check(columns, values)
        
        #Create SQL command
        sql_cols = SQLconnect.sql_columns(columns)
        val_symbols = '%s, ' * (len(columns)-1) + '%s'
        sql = "INSERT INTO {:s}.{:s} ({:s}) VALUES ({:s})".format(self.Schema, 
                           table, sql_cols, val_symbols)
        print("SQL command: {:s}".format(sql))
        
        #Execute command
        self.__insert(sql, values, '{:s}.{:s}'.format(self.Schema, table))

    
    def is_connected(self):
        if not self.SQL.is_connected():
            return False
        return True
    
    def __insert(self, sql, values, table):
        cursor = self.SQL.cursor()
        cursor.executemany(sql, values)
        print("\t\t{:d} rows was inserted into {:s}".format(cursor.rowcount, 
              table))       
        #Commit to server and close cursor
        self.SQL.commit()
        cursor.close()
        
    
    @staticmethod
    def table_check(self, table):
        if not isinstance(table, str):
            raise TypeError('table must be a string')
        if not table in self.Tables:
            raise Exception('Error: {:s} not found'.format(table))
        return True
    @staticmethod
    def column_check(self, table, columns):
        if not isinstance(columns, (tuple, list)):
            raise Exception('column names must be given is tuple or list')
        if not all(isinstance(x, str) for x in columns):
            raise Exception('columns names must be string')
        # get column names in sql database for table
        cols_in_table = self.table_columns(table)
        not_cols = list(set(columns) - set(cols_in_table))
        if len(not_cols) > 0:
            for x in not_cols:
                print('{:s} is not a recognised column name'.format(x))
            raise Exception('column name(s) not in table {:s}'.format(table))
    @staticmethod
    def values_check(columns, values):
        if not isinstance(values, (tuple, list)):
            raise Exception('values must be given as tuple or list')
        if not all(isinstance(values, (tuple, list)) for value in values):
            raise Exception('all values must be given in tuple or list')
        if not all(len(value) == len(columns) for value in values):
            raise Exception('all values lists must have length equal to '
                            'the number of columns')
    
    @staticmethod
    def sql_filter(keys, vals):
        key = keys[0]
        val = vals[0]
        if isinstance(val, (tuple, list)):
            rtn = "{:s} in {:s}".format(key, str(tuple(val)))
        elif isinstance(val, (int, float)):
            rtn = "{:s} = {:s}".format(key, str(val))
        elif isinstance(val, str):
            rtn = "{:s} = \'{:s}\'".format(key, val)
        else:
            raise Exception('Error: type {:s} not recognised or '
                            'implemented'.format(type(val)))
        if len(keys) == 1:
            return rtn
        else:
            return rtn +' and ' + SQLconnect.sql_filter(keys[1:], vals[1:])
    
    @staticmethod
    def sql_columns(columns):
        if len(columns) == 1:
            return columns[0]
        else:
            return columns[0] + ", " + SQLconnect.sql_columns(columns[1:])
    
    @staticmethod
    def to_login(d, f):
        if len(f) == 0:                         # no more entries in file
            return d
        elif len(f[0]) == 0:                    # blank line
            return SQLconnect.to_login(d, f[1:])
        else:
            data = {}
            # database name without brackets                                   
            data['database'] = f[0][1:-1]
            # take data: host, user and password, order not important    
            for line in f[1:4]:
                cont = line.split('=')
                data[cont[0].lower()] = cont[1]            
            
            d[data['database']] = data                   
            return SQLconnect.to_login(d, f[4:])   # return remaining lines
    

        
        

        


