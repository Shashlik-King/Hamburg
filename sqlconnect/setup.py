"""
Author: Esben Rasmussen <enrn@cowi.com>
        

This package is distributed under COWI license
"""




from setuptools import setup, find_packages
import os
import sys

CLASSIFIERS ="""\


"""

LONG_DESCRIPTION = """
The sql connect modules is a Python package that enables the contact between 
Python and the mySQL database for CoPilod ans OneSource. The package uses the 
.my.cnf and .onesource.cnf files to login to the database. The files 
should be placed in the user directory. 
The format is this file should be:    
    [batabase_name]
    host = adress
    user = user_id
    password = password
"""

try: 
    import pandas
except ImportError:
    print('Pandas import failed: please install pandas module')

try:
    import mysql
except ImportError:
    print('MySQL import failed: please install mysql module.')

try: 
    import psycopg2
except ImportError:
    print('Psycopg2 import failed: please install mpsycopg2 module.')

setup(
      name = 'sql_connect',
      version = '2.0.0',
      description = LONG_DESCRIPTION,
      author = 'Esben Rasmussen',
      author_email = 'enrn@cowi.com',
      license = 'COWI',
      packages = find_packages(),
      install_requires=[
              'mysql',
              'numpy',
              'psycopg2'],
      python_requires = '>=3.7.3',
      url = 'http://git.cowiportal.com/Tool-Wind/CoPilodConnect')