# dokku clickhouse [![Build Status](https://img.shields.io/circleci/project/github/dokku/dokku-clickhouse.svg?branch=master&style=flat-square "Build Status")](https://circleci.com/gh/dokku/dokku-clickhouse/tree/master) [![IRC Network](https://img.shields.io/badge/irc-freenode-blue.svg?style=flat-square "IRC Freenode")](https://webchat.freenode.net/?channels=dokku)

Official clickhouse plugin for dokku. Currently defaults to installing [yandex/clickhouse-server 20.9.2.20](https://hub.docker.com/r/yandex/clickhouse-server/).

## Sponsors

The clickhouse plugin was generously sponsored by the following:

- [coding-socks](https://github.com/coding-socks)

## Requirements

- dokku 0.19.x+
- docker 1.8.x

## Installation

```shell
# on 0.19.x+
sudo dokku plugin:install https://github.com/dokku/dokku-clickhouse.git clickhouse
```

## Commands

```
clickhouse:app-links <app>                        # list all clickhouse service links for a given app
clickhouse:connect <service>                      # connect to the service via the clickhouse connection tool
clickhouse:create <service> [--create-flags...]   # create a clickhouse service
clickhouse:destroy <service> [-f|--force]         # delete the clickhouse service/data/container if there are no links left
clickhouse:enter <service>                        # enter or run a command in a running clickhouse service container
clickhouse:exists <service>                       # check if the clickhouse service exists
clickhouse:expose <service> <ports...>            # expose a clickhouse service on custom port if provided (random port otherwise)
clickhouse:info <service> [--single-info-flag]    # print the service information
clickhouse:link <service> <app> [--link-flags...] # link the clickhouse service to the app
clickhouse:linked <service> <app>                 # check if the clickhouse service is linked to an app
clickhouse:links <service>                        # list all apps linked to the clickhouse service
clickhouse:list                                   # list all clickhouse services
clickhouse:logs <service> [-t|--tail]             # print the most recent log(s) for this service
clickhouse:promote <service> <app>                # promote service <service> as CLICKHOUSE_URL in <app>
clickhouse:restart <service>                      # graceful shutdown and restart of the clickhouse service container
clickhouse:start <service>                        # start a previously stopped clickhouse service
clickhouse:stop <service>                         # stop a running clickhouse service
clickhouse:unexpose <service>                     # unexpose a previously exposed clickhouse service
clickhouse:unlink <service> <app>                 # unlink the clickhouse service from the app
clickhouse:upgrade <service> [--upgrade-flags...] # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to clickhouse:help. Please consult the `clickhouse:help` command for any undocumented commands.

### Basic Usage

### create a clickhouse service

```shell
# usage
dokku clickhouse:create <service> [--create-flags...]
```

flags:

- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-p|--password PASSWORD`: override the user-level service password
- `-r|--root-password PASSWORD`: override the root-level service password

Create a clickhouse service named lolipop:

```shell
dokku clickhouse:create lolipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the yandex/clickhouse-server image. 

```shell
export CLICKHOUSE_IMAGE="yandex/clickhouse-server"
export CLICKHOUSE_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku clickhouse:create lolipop
```

You can also specify custom environment variables to start the clickhouse service in semi-colon separated form. 

```shell
export CLICKHOUSE_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku clickhouse:create lolipop
```

### print the service information

```shell
# usage
dokku clickhouse:info <service> [--single-info-flag]
```

flags:

- `--config-dir`: show the service configuration directory
- `--data-dir`: show the service data directory
- `--dsn`: show the service DSN
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--internal-ip`: show the service internal ip
- `--links`: show the service app links
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku clickhouse:info lolipop
```

You can also retrieve a specific piece of service info via flags:

```shell
dokku clickhouse:info lolipop --config-dir
dokku clickhouse:info lolipop --data-dir
dokku clickhouse:info lolipop --dsn
dokku clickhouse:info lolipop --exposed-ports
dokku clickhouse:info lolipop --id
dokku clickhouse:info lolipop --internal-ip
dokku clickhouse:info lolipop --links
dokku clickhouse:info lolipop --service-root
dokku clickhouse:info lolipop --status
dokku clickhouse:info lolipop --version
```

### list all clickhouse services

```shell
# usage
dokku clickhouse:list 
```

List all services:

```shell
dokku clickhouse:list
```

### print the most recent log(s) for this service

```shell
# usage
dokku clickhouse:logs <service> [-t|--tail]
```

flags:

- `-t|--tail`: do not stop when end of the logs are reached and wait for additional output

You can tail logs for a particular service:

```shell
dokku clickhouse:logs lolipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku clickhouse:logs lolipop --tail
```

### link the clickhouse service to the app

```shell
# usage
dokku clickhouse:link <service> <app> [--link-flags...]
```

flags:

- `-a|--alias "BLUE_DATABASE"`: an alternative alias to use for linking to an app via environment variable
- `-q|--querystring "pool=5"`: ampersand delimited querystring arguments to append to the service link

A clickhouse service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our 'playground' app. 

> NOTE: this will restart your app

```shell
dokku clickhouse:link lolipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_CLICKHOUSE_LOLIPOP_NAME=/lolipop/DATABASE
DOKKU_CLICKHOUSE_LOLIPOP_PORT=tcp://172.17.0.1:9000
DOKKU_CLICKHOUSE_LOLIPOP_PORT_9000_TCP=tcp://172.17.0.1:9000
DOKKU_CLICKHOUSE_LOLIPOP_PORT_9000_TCP_PROTO=tcp
DOKKU_CLICKHOUSE_LOLIPOP_PORT_9000_TCP_PORT=9000
DOKKU_CLICKHOUSE_LOLIPOP_PORT_9000_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
CLICKHOUSE_URL=clickhouse://lolipop:SOME_PASSWORD@dokku-clickhouse-lolipop:9000/lolipop
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the 'expose' subcommand. Another service can be linked to your app:

```shell
dokku clickhouse:link other_service playground
```

It is possible to change the protocol for `CLICKHOUSE_URL` by setting the environment variable `CLICKHOUSE_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding. 

```shell
dokku config:set playground CLICKHOUSE_DATABASE_SCHEME=clickhouse2
dokku clickhouse:link lolipop playground
```

This will cause `CLICKHOUSE_URL` to be set as:

```
clickhouse2://lolipop:SOME_PASSWORD@dokku-clickhouse-lolipop:9000/lolipop
```

### unlink the clickhouse service from the app

```shell
# usage
dokku clickhouse:unlink <service> <app>
```

You can unlink a clickhouse service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku clickhouse:unlink lolipop playground
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### connect to the service via the clickhouse connection tool

```shell
# usage
dokku clickhouse:connect <service>
```

Connect to the service via the clickhouse connection tool:

```shell
dokku clickhouse:connect lolipop
```

### enter or run a command in a running clickhouse service container

```shell
# usage
dokku clickhouse:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk. 

```shell
dokku clickhouse:enter lolipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk. 

```shell
dokku clickhouse:enter lolipop touch /tmp/test
```

### expose a clickhouse service on custom port if provided (random port otherwise)

```shell
# usage
dokku clickhouse:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku clickhouse:expose lolipop 9000 8123
```

### unexpose a previously exposed clickhouse service

```shell
# usage
dokku clickhouse:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku clickhouse:unexpose lolipop
```

### promote service <service> as CLICKHOUSE_URL in <app>

```shell
# usage
dokku clickhouse:promote <service> <app>
```

If you have a clickhouse service linked to an app and try to link another clickhouse service another link environment variable will be generated automatically:

```
DOKKU_CLICKHOUSE_BLUE_URL=clickhouse://other_service:ANOTHER_PASSWORD@dokku-clickhouse-other-service:9000/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku clickhouse:promote other_service playground
```

This will replace `CLICKHOUSE_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
CLICKHOUSE_URL=clickhouse://other_service:ANOTHER_PASSWORD@dokku-clickhouse-other-service:9000/other_service
DOKKU_CLICKHOUSE_BLUE_URL=clickhouse://other_service:ANOTHER_PASSWORD@dokku-clickhouse-other-service:9000/other_service
DOKKU_CLICKHOUSE_SILVER_URL=clickhouse://lolipop:SOME_PASSWORD@dokku-clickhouse-lolipop:9000/lolipop
```

### start a previously stopped clickhouse service

```shell
# usage
dokku clickhouse:start <service>
```

Start the service:

```shell
dokku clickhouse:start lolipop
```

### stop a running clickhouse service

```shell
# usage
dokku clickhouse:stop <service>
```

Stop the service and the running container:

```shell
dokku clickhouse:stop lolipop
```

### graceful shutdown and restart of the clickhouse service container

```shell
# usage
dokku clickhouse:restart <service>
```

Restart the service:

```shell
dokku clickhouse:restart lolipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku clickhouse:upgrade <service> [--upgrade-flags...]
```

flags:

- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-R|--restart-apps "true"`: whether to force an app restart

You can upgrade an existing service to a new image or image-version:

```shell
dokku clickhouse:upgrade lolipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all clickhouse service links for a given app

```shell
# usage
dokku clickhouse:app-links <app>
```

List all clickhouse services that are linked to the 'playground' app. 

```shell
dokku clickhouse:app-links playground
```

### check if the clickhouse service exists

```shell
# usage
dokku clickhouse:exists <service>
```

Here we check if the lolipop clickhouse service exists. 

```shell
dokku clickhouse:exists lolipop
```

### check if the clickhouse service is linked to an app

```shell
# usage
dokku clickhouse:linked <service> <app>
```

Here we check if the lolipop clickhouse service is linked to the 'playground' app. 

```shell
dokku clickhouse:linked lolipop playground
```

### list all apps linked to the clickhouse service

```shell
# usage
dokku clickhouse:links <service>
```

List all apps linked to the 'lolipop' clickhouse service. 

```shell
dokku clickhouse:links lolipop
```

### Disabling `docker pull` calls

If you wish to disable the `docker pull` calls that the plugin triggers, you may set the `CLICKHOUSE_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker pull` is disabled.