# SQLconnect

Python module that uses an object-oriented approach to communicate with an SQL database. The module work for CoPilod and OneSource.

[Documentation](http://git.cowiportal.com/webapp/Tool-Wind/SQLconnect/)

![](image.png)

## Usage example

//A few motivating and useful examples of how your product can be used. Spice this up with code blocks and potentially more screenshots.

_For more examples and usage, please refer to the [Wiki][wiki]._

## Development setup

//Describe how to install all development dependencies and how to run an automated test-suite of some kind. Potentially do this for multiple platforms.

### Prerequisites

The following modules should be install in the Python environment

- pandas  
- mysql  
- psycopg2  
      
`pip install pandas`  
`pip install mysql-connector-python`  
`pip install psycopg2`


### Installing

Start by downloading the latest release or clone the master branch

If the file is downloaded it should first be unpacked

Using the command prompt or anaconda prompt (if you are using anaconda is distributor), navigate to the folder that is one level up from the cloned repos or downloaded file. 

If using command prompt type:  
    `pip3 install -e sql_connect/`

if using anaconda prompt type:  
    `pip install -e sql_connect`

the modules can then be imported with:  
    `import sql_connect`  

### Running the tests

//Explain how to run the automated tests for this system

#### Break down into end to end tests

//Explain what these tests test and why

//Give an example

#### Documentation style

All classes and method should be documentated using the [Google Style](https://www.sphinx-doc.org/en/1.7/ext/example_google.html)  

The documentation is created automaticcally by [sphinx](https://www.sphinx-doc.org/en/master/index.html) 

## Release History

* 1.0.0
    * First stable version. Connection to CoPilod
* 1.0.1
    * FIX: Referances to modules fixed for the code to run
* 1.1.0
    * CHANGE: renaming of method to PEP8 standard
    * ADD: setup.py, docstrings
* 2.0.0
    * The first proper release
    * CHANGE: renaming of module to sql_connect
    * ADD: functionality to postgresSSQL(OneSource)

## Contributing

1. Create your feature branch (`git checkout -b feature/fooBar`)
2. Commit your changes (`git commit -am 'Add some fooBar'`)
3. Push to the branch (`git push origin feature/fooBar`)
4. Create a new Pull Request
