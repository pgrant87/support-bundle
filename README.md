# Airbyte Support Bundle

### Description

A script that will gather all logging, configuration and anything that could be useful when investigating a customer issue.

The script will create a date and timestamped tarball containing all the items below and print the location and size for the user to easily transfer to Airbyte support.

_generate_support_bundle.sh_ is the main bash script and entry point. To start, we’ll concentrate on Docker installations before adding functionality for Kubernetes.

Working doc for this lives at https://docs.google.com/document/d/1xue_F3tKxAZnFYQhMkNlCN9uVqJhJSslfwUM6XzzMEA/edit?usp=sharing

### Items to gather / To-do list
* All container logs ✅
* docker-compose.yaml ✅
* .env ✅ (docker-compose.yaml currently populated with the values from .env, will need password redaction)
* Sync logs (default is 3 days) ✅
* Host info/specs ✅
* System performance ✅
* docker info ✅
* docker inspect output ✅
* Connector configuration and info ✅
* Current connector versions ✅
* Connector upgrade history ✅
* Connections in use ✅
* Database table info/sizes ✅
* Database Schema ✅
* Network config (host and docker) ✅
* Metrics config ✅

### Usage

Clone this repo inside your airbyte directory and run `./generate_support_bundle.sh` to test the support bundle.

Options: 

`-d` / `--dir` Specify a directory to create the archive in.

`-h` / `--help` Print the help manual page.

`-l` / `--log-age` Specify the number of days worth of sync logs to collect. (default = 3)

`-r` / `--redact` Redact passwords from the docker-compose.yaml file.

`-t` / `--ticket` Add a related ticket number to the archive name.

`-v` / `--verbose` Run in verbose mode, this prints each line of the script before execution.

### What gets bundled and where?

Key directories and files:

* `airbyte-server` This is basically a copy of the `/tmp` folder from the airbyte-server container. This contains all the sync logs. By default we collect 3 days worth but this can be specified using the `--log-age` option

* `connector_info` This contains source, destination and connection info gathered from the [Airbyte API](https://api.airbyte.com/).

* `container_logs` Logs from each of the Airbyte containers.

* `database_info` Database schema, table info and migration data.

* `docker-compose.yaml` The docker compose file filled with values from `.env`

* `system_info.txt` Host, CPU, Memory, Disk and network info all in a single file.

Your decompressed Airbyte Support Bundle will contain the following structure:

```
/tmp/airbyte-support-bundle-<Date and time stamp>
├── airbyte-server
│   └── tmp
│       ├── airbyte_local
│       ├── hsperfdata_root
│       ├── schemas11796079148753136938
│       └── workspace
├── connector_info
│   ├── connections.json
│   ├── connector_version_history.txt
│   ├── destinations.json
│   └── sources.json
├── container_logs
│   ├── airbyte-api-server.log
│   ├── airbyte-connector-builder-server.log
│   ├── airbyte-cron.log
│   ├── airbyte-db.log
│   ├── airbyte-proxy.log
│   ├── airbyte-server.log
│   ├── airbyte-temporal.log
│   ├── airbyte-webapp.log
│   ├── airbyte-worker.log
│   ├── dd-agent.log
│   └── metric-reporter.log
├── database_info
│   ├── airbyte_config_migrations_table.txt
│   ├── airbyte_jobs_migrations_table.txt
│   ├── schema.sql
│   ├── table_columns.txt
│   ├── table_row_counts.txt
│   ├── table_sizes.txt
│   └── tables.txt
├── docker-compose.yaml
├── docker_info
│   ├── docker-compose-images.txt
│   ├── docker-compose-ps.txt
│   ├── docker-compose-top.txt
│   ├── docker-compose-version.txt
│   ├── docker-images.txt
│   ├── docker-info.txt
│   ├── docker-ps.txt
│   ├── docker-system.txt
│   ├── docker-version.txt
│   └── docker_inspect
│       ├── airbyte-api-server-inspect.txt
│       ├── airbyte-connector-builder-server-inspect.txt
│       ├── airbyte-cron-inspect.txt
│       ├── airbyte-db-inspect.txt
│       ├── airbyte-proxy-inspect.txt
│       ├── airbyte-server-inspect.txt
│       ├── airbyte-temporal-inspect.txt
│       ├── airbyte-webapp-inspect.txt
│       ├── airbyte-worker-inspect.txt
│       ├── dd-agent-inspect.txt
│       ├── docker_networks
│       │   ├── airbyte_airbyte_internal-network-inspect.txt
│       │   ├── airbyte_airbyte_public-network-inspect.txt
│       │   ├── airbyte_default-network-inspect.txt
│       │   ├── bridge-network-inspect.txt
│       │   ├── host-network-inspect.txt
│       │   └── none-network-inspect.txt
│       └── metric-reporter-inspect.txt
└── system_info.txt
```

### Development

For any additions, I would ask that the [Shellcheck](https://www.shellcheck.net/) linter is adhered to:
https://github.com/koalaman/shellcheck

The VScode plugin is particularly useful:
https://github.com/vscode-shellcheck/vscode-shellcheck
