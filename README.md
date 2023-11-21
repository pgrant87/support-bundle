### Airbyte Support Bundle

### Description

A script that will gather all logging, configuration and anything that could be useful when investigating a customer issue.

The script will create a date and timestamped tarball containing the items below and print the location and size for the user to easily transfer to Airbyte support.

### Items to gather / To-do list
* All container logs
* docker-compose.yaml
* .env
* All sync logs
* docker info output
* docker inspect output

### Nice to haves:
* Option to pull a certain number of days logs
* Option to encrypt with a key
* Option to redact sensitive customer information
