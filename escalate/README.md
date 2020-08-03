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

## Requirements
- Running ESCALATE v3 Postgres database
- Python 3.6+
- Django 2.2.x (Upgrade to 3.0 in progress)


## Getting started

### Database setup

If you have docker and docker-compose installed and ready to use, you can quickly spin up a populated database using `docker-compose up` in the data_model folder. 

There are multiple ways of setting up the v3 database. Detailed instructions on how to set up the database is [here](../data_model/README.md)


### Django Server
There are 4 Django settings files available in the ./escalate/settings folder.
- [base.py](escalate/settings/base.py) : Common settings used in the app
- [prod.py](escalate/settings/prod.py) : Config for a production server
- [dev.py](escalate/settings/dev.py) : Config for a development server
- [local.py](escalate/settings/loca.py) : Config for local/live developement and debugging

#### Docker development server
To spin up a dev docker container simply run `docker-compose up` within the current folder. This will automatically connect to the running Escalate v3 Postgres database and apply the required migrations for user and admin tables

#### Local debugging server
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