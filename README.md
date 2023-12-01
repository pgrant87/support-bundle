### Airbyte Support Bundle

### Description

A script that will gather all logging, configuration and anything that could be useful when investigating a customer issue.

The script will create a date and timestamped tarball containing all the items below and print the location and size for the user to easily transfer to Airbyte support.

_generate_support_bundle.sh_ is the main bash script and entry point. To start, we’ll concentrate on Docker installations before adding functionality for Kubernetes.

Working doc for this lives at https://docs.google.com/document/d/1xue_F3tKxAZnFYQhMkNlCN9uVqJhJSslfwUM6XzzMEA/edit?usp=sharing

### Items to gather / To-do list
* All container logs ✅
* docker-compose.yaml ✅
* .env ✅ (docker-compose.yaml currently populated with the values from .env, will need password redaction)
* Sync logs (A few days worth to start?)
* Host info/specs ✅
* System performance/timeline
* docker info ✅
* docker inspect output ✅
* Connector configuration and info ✅
* Current connector versions
* Connector upgrade history
* Connections in use ✅
* Database table info/sizes ✅
* Database Schema ✅
* Network config and connection details
* Metrics details

### Usage

Clone this repo inside your airbyte directory and run `generate_support_bundle.sh` to test the support bundle.

### Development

For any additions, I would ask that the [Shellcheck](https://www.shellcheck.net/) linter is adhered to:
https://github.com/koalaman/shellcheck

The VScode plugin is particularly useful:
https://github.com/vscode-shellcheck/vscode-shellcheck