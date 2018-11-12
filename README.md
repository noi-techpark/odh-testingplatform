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
  
  2. create the database tables under the public schema with the following command (add to psql the 
     required parameters to connect to the database like host, user, database):
  
    `psql < ddl.sql`
  
  3. configure the script variables. Edit the **scriptconfig.txt** file. Assign to variable the right value
     * **APIURL**: the url of github graphql api usually https://api.github.com/graphql
     * **TESTRUNNER_DIR**: where soap ui bin directory is, i.e. /..../SmartBear/SoapUI-5.4.0/bin/
     * **AUTHORIZATIONBEARER**: the auth code for the graphql service. You can got one following
       this official documentation: https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/
     * **USERLOGIN**: the organization which repository are tested, i.e. idm-suedtirol
     * **REPOSITORYSIZE**: the maximum number of repository to download/test
     * **PGHOST,PGDBNAME,PGUSER,PGPASSWORD**: postgres enviroment variables to connect to the database
     
     **WARNING: don't commit this data to a public repository**
     
  4. the main file is the **script.sh**. You can run it
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
     
  1. copy the `src/webapp/WEB-INF/config.properties.example` file to `src/webapp/WEB-INF/config.properties` and change the jdbc_url context param to point to the right database
     
  2. with maven create the war with the standard target: package
  
  3. copy/deploy the war to the tomcat webapps
  
  4. open the url http://servername:8080/testingplatform
  
## Docker environment

For the project a Docker environment is already prepared and ready to use with all necessary prerequisites.

These Docker containers are the same as used by the continuous integration servers.

### Installation

Install [Docker](https://docs.docker.com/install/) (with Docker Compose) locally on your machine.

### Start and stop the containers

Before start working you have to start the Docker containers:

```
docker-compose up --build --detach
```

After finished working you can stop the Docker containers:

```
docker-compose stop
```

### Running commands inside the container

When the containers are running, you can execute any command inside the environment. Just replace the dots `...` in the following example with the command you wish to execute:

```bash
docker-compose exec java /bin/bash -c "..."
```

Some examples are:

```bash
docker-compose exec java /bin/bash -c "mvn clean install"

# or

docker-compose exec java /bin/bash -c "mvn clean test"
```

To apply the database schema to the database run:

```bash
docker-compose exec script /bin/bash -c "PGPASSWORD=postgres psql --host=postgres --username=postgres < ddl.sql"
```

To execute the script run:

```bash
docker-compose exec script /bin/bash -c "./script.sh scriptconfig.txt"
```

To build the web app that is accessible under the url http://localhost:8080/testingplatform run:

```bash
docker-compose exec java /bin/bash -c "mvn clean package"

docker-compose exec tomcat /bin/bash -c "cp /code/target/testingplatform.war /usr/local/tomcat/webapps/testingplatform.war"
```
