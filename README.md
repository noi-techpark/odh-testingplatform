# odh-testingplatform

OpenDataHub testing platform git repository

## Installing


The code is splitted into two parts. One part is a script that executes the tests and collects result
into a postgres database. The second part is a j2ee application that show result on a webpage


## Installing the script

### Prerequisites

  1. linux machine
  2. postgres database somewhere and psql installed on the local machine
  3. SoapUI Open Source (https://www.soapui.org)
  
### Procedure
     
  1. clone or unzip the repository where you like.
  2. configure the script variables. Edit the **scriptconfig.txt** file. Assign to variable the right value
     * **APIURL**: the url of github graphql api usually https://api.github.com/graphql
     * **TESTRUNNER_DIR**: where soap ui bin directory is, i.e. /..../SmartBear/SoapUI-5.4.0/bin/
     * **AUTHORIZATIONBEARER**: the auth code for the graphql service. You can got one following
       this official documentation: https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/
     * **USERLOGIN**: the organization which repository are tested, i.e. idm-suedtirol
     * **REPOSITORYSIZE**: the maximum number of repository to download/test
     * **PGHOST,PGDBNAME,PGUSER,PGPASSWORD**: postgres enviroment variables to connect to the database
     
     **WARNING: don't commit this data to a public repository**
     
  3. the main file is the **script.sh**. You can run it
     manually when you want or you can add it to crontab. The script requires a parameter: the
     config file. For example you can run the follow line from the shell:
     
     ```
     /..../script.sh ./scriptconfig.txt
     ```

## Installing the web app

### Prerequisites

  1. postgres database somewhere
  2. java / tomcat
  3. maven
  
### Procedure
     
  1. create the database tables under the public schema with the following command (add to psql the 
     required parameters to connect to the database like host, user, database):
  
    `psql < ddl.sql`
  
  2. edit the web.xml file and change the jdbc_url context param to point to the right database. You can
     add server/user/password as well
     
  3. with maven create the war with the standard target: package
  
  4. copy/deploy the war to the tomcat webapps
  
  5. open the url http://servername:8080/web
  
  