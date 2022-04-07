[![Contributors][contributors-shield]][contributors-url]
[![Commits][commits-shield]][commits-url]
[![Last Commit][lastcommit-shield]][lastcommit-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/darkreactions/ESCALATE">
    <img src="../data_model/images/Escalate_B-04.png" alt="Logo" width="250 height="100">
  </a>
  <h1 align="center">ESCALATE v3</h1>
  <p align="center">
   Technical documentation
    <br />
        <a href="https://github.com/darkreactions/ESCALATE/blob/master/escalate/TECHNICAL.md"><strong>ESCALATE Django Technical Docs</strong></a>
    <br />
  </p>
  
</p>

## Software requirements
- Python 3.8+
- Django 3.0.12
- Docker
                                                                                             
                                                                                
## Getting Started


### Initial Instantiation of ESCALATE

This model can be locally instantiated into a Docker container. 

The following instructions will assist in setting up a Docker container and instantiating ESCALATE locally for the first time.

1. Download a copy of ESCALATE code from GitHub to your local machine or git clone the repo
2. Install [Docker](https://docs.docker.com/get-docker/) and open the application
3. Open terminal and run ```pip install -r requirements.txt```
4. Navigate to .../ESCALATE/data_model   
5. Run the following bash commands:
	```
		docker-compose down --rmi all -v
		docker-compose up
	```
6. Open a new terminal and navigate to ../ESCALATE/escalate/
7. Run the following:
	```
	export DJANGO_SETTINGS_MODULE=escalate.settings.local
	bash ./build_django_db.sh reset 
	python manage.py runserver
	```
This should create an instance of ESCALATE under your local server's 8000: port with preloaded mock data. You can then navigate to the local server website at localhost:8000/ and create a new username/password to log in, or use localhost:8000/api to access the restAPI.
If you do not wish to preload data then skip running the build_django_db shell script in step 6 and instead load your own data via a script or through the API.

### Quickest method to fully create database (from backup)

Assumption: you have a database named 'escalate' already created (in either local environment or Docker container).

**restore into a Docker container**
using the latest 'bak' file in the repo's backup folder. This assumes the following: 1) the docker container is named: escalate and 2) the backup sql file has been moved to a folder in the container

```
docker exec escalate psql -d escalate -U escalate -f escalate_dev_create_backup.sql
```

<br/>
                                                                                             
                                                                                             
## Database Setup
 
### Django Server
There are 4 Django settings files available in the ./escalate/settings folder.
- [base.py](escalate/settings/base.py) : Common settings used in the app
- [prod.py](escalate/settings/prod.py) : Config for a production server
- [dev.py](escalate/settings/dev.py) : Config for a development server
- [local.py](escalate/settings/loca.py) : Config for local/live developement and debugging

#### Docker Development Server
If you have Docker installed and ready to use, you can quickly spin up a populated database. Simply run `docker-compose up` in the data_model folder. This will automatically connect to the running Escalate v3 database and apply the required migrations for user and admin tables. 
This will not populate users, materials, experiments, organizations, etc. We recommend utilizing our API to create a script to prepopulate the database models prior to running the application.
Reference [here](../data_model/README.md) for more information on those models.

#### Local Debugging Server
1. Set the evironment variable `DJANGO_SETTINGS_MODULE=escalate.settings.local` 
2. Migrate Django related tables to database `python manage.py migrate`
3. Start the Django server `python manage.py runserver`


<!-- MARKDOWN LINKS & IMAGES -->
[contributors-shield]: https://img.shields.io/github/contributors/darkreactions/ESCALATE
[contributors-url]: https://github.com/darkreactions/ESCALATE/graphs/contributors
[lastcommit-shield]: https://img.shields.io/github/last-commit/darkreactions/ESCALATE
[lastcommit-url]: https://github.com/darkreactions/ESCALATE/graphs/commit-activity
[issues-shield]: https://img.shields.io/github/issues/darkreactions/ESCALATE
[issues-url]: https://github.com/darkreactions/ESCALATE/issues
[license-shield]: https://img.shields.io/github/license/darkreactions/ESCALATE
[license-url]: https://github.com/darkreactions/ESCALATE/blob/master/LICENSE
[commits-shield]: https://img.shields.io/github/commit-activity/m/darkreactions/ESCALATE
[commits-url]: https://github.com/darkreactions/ESCALATE/graphs/commit-activity
[postgresqlinstall-url]: https://www.postgresql.org/download/
[postgresql-logo]: images/postgresql_logo.png
[dockerinstall-url]: https://docs.docker.com/install/
[docker-logo]: images/docker_logo.png						     
