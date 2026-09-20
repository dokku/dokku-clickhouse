# dokku clickhouse [![Build Status](https://img.shields.io/github/actions/workflow/status/dokku/dokku-clickhouse/ci.yml?branch=master&style=flat-square "Build Status")](https://github.com/dokku/dokku-clickhouse/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official clickhouse plugin for dokku. Currently defaults to installing [clickhouse/clickhouse-server 26.8.5.13](https://hub.docker.com/r/clickhouse/clickhouse-server/).

## Sponsors

The clickhouse plugin was generously sponsored by the following:

- [coding-socks](https://github.com/coding-socks)

## Requirements

- dokku 0.35.x+
- docker 1.8.x

## Installation

```shell
# on 0.35.x+
sudo dokku plugin:install https://github.com/dokku/dokku-clickhouse.git --name clickhouse
```

## Commands

```
clickhouse:app-links [<app>]                       # list all Clickhouse service links for a given app
clickhouse:connect <service>                       # connect to the service via the clickhouse connection tool
clickhouse:create <service> [--create-flags...]    # create a Clickhouse service
clickhouse:destroy <service> [-f|--force]          # delete the Clickhouse service/data/container if there are no links left
clickhouse:enter <service>                         # enter or run a command in a running Clickhouse service container
clickhouse:exists <service>                        # check if the Clickhouse service exists
clickhouse:expose <service> <ports...>             # expose a Clickhouse service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)
clickhouse:info <service> [--info-flags...]        # print the service information
clickhouse:link <service> [<app>] [--link-flags...] # link the Clickhouse service to the app
clickhouse:linked <service> [<app>]                # check if the Clickhouse service is linked to an app
clickhouse:links <service>                         # list all apps linked to the Clickhouse service
clickhouse:list                                    # list all Clickhouse services
clickhouse:logs <service> [-t|--tail [<tail-num>]] # print the most recent log(s) for this service
clickhouse:pause <service>                         # pause a running Clickhouse service
clickhouse:promote <service> [<app>]               # promote service <service> as CLICKHOUSE_URL in <app>
clickhouse:restart <service>                       # graceful shutdown and restart of the Clickhouse service container
clickhouse:set <service> <key> <value>             # set or clear a property for a service
clickhouse:start <service>                         # start a previously stopped Clickhouse service
clickhouse:stop <service>                          # stop a running Clickhouse service
clickhouse:unexpose <service>                      # unexpose a previously exposed Clickhouse service
clickhouse:unlink <service> [<app>] [-n|--no-restart] # unlink the Clickhouse service from the app
clickhouse:upgrade <service> [--upgrade-flags...]  # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to clickhouse:help. Plugin help output in conjunction with any files in the `docs/` folder is used to generate the plugin documentation. Please consult the `clickhouse:help` command for any undocumented commands.

### Basic Usage

### create a Clickhouse service

```shell
# usage
dokku clickhouse:create <service> [--create-flags...]
```

flags:

- `-c|--config-options <string>`: extra arguments to pass to the container create command
- `-C|--custom-env <string>`: semi-colon delimited environment variables to start the service with
- `-i|--image <string>`: the image name to start the service with
- `-I|--image-version <string>`: the image version to start the service with
- `-N|--initial-network <string>`: the initial network to attach the service to
- `-m|--memory <int>`: container memory limit in megabytes (default: unlimited)
- `-p|--password <string>`: override the user-level service password
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `-r|--root-password <string>`: override the root-level service password
- `-s|--shm-size <string>`: override shared memory size for the service docker container

Create a clickhouse service named lollipop:

```shell
dokku clickhouse:create lollipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the clickhouse/clickhouse-server image.

```shell
export CLICKHOUSE_IMAGE="clickhouse/clickhouse-server"
export CLICKHOUSE_IMAGE_VERSION="26.8.5.13"
dokku clickhouse:create lollipop
```

You can also specify custom environment variables to start the clickhouse service in semicolon-separated form.

```shell
export CLICKHOUSE_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku clickhouse:create lollipop
```

### delete the Clickhouse service/data/container if there are no links left

```shell
# usage
dokku clickhouse:destroy <service> [-f|--force]
```

flags:

- `-f|--force`: force the destruction of the service

Destroy the service, it's data, and the running container:

```shell
dokku clickhouse:destroy lollipop
```

### print the service information

```shell
# usage
dokku clickhouse:info <service> [--info-flags...]
```

flags:

- `--config-dir`: show the service configuration directory
- `--data-dir`: show the service data directory
- `--dsn`: show the service DSN
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--initial-network`: show the initial network being connected to
- `--internal-ip`: show the service internal ip
- `--links`: show the service app links
- `--post-create-network`: show the networks to attach to after service container creation
- `--post-start-network`: show the networks to attach to after service container start
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku clickhouse:info lollipop
```

You can also retrieve a specific piece of service info via flags:

```shell
dokku clickhouse:info lollipop --config-dir
dokku clickhouse:info lollipop --data-dir
dokku clickhouse:info lollipop --dsn
dokku clickhouse:info lollipop --exposed-ports
dokku clickhouse:info lollipop --id
dokku clickhouse:info lollipop --internal-ip
dokku clickhouse:info lollipop --initial-network
dokku clickhouse:info lollipop --links
dokku clickhouse:info lollipop --post-create-network
dokku clickhouse:info lollipop --post-start-network
dokku clickhouse:info lollipop --service-root
dokku clickhouse:info lollipop --status
dokku clickhouse:info lollipop --version
```

### list all Clickhouse services

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
dokku clickhouse:logs <service> [-t|--tail [<tail-num>]]
```

flags:

- `-t|--tail <int>`: tail the logs, optionally showing this many lines

You can tail logs for a particular service:

```shell
dokku clickhouse:logs lollipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku clickhouse:logs lollipop --tail
```

By default the last 100 lines are shown, but a different count can be specified:

```shell
dokku clickhouse:logs lollipop --tail=5
```

### link the Clickhouse service to the app

```shell
# usage
dokku clickhouse:link <service> [<app>] [--link-flags...]
```

flags:

- `-a|--alias <string>`: an alternative alias to use for the config url exported to the app
- `-n|--no-restart`: whether to skip restarting the app
- `-q|--querystring <string>`: ampersand delimited querystring arguments to append to the service url

A clickhouse service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our `playground` app.

> NOTE: this will restart your app

```shell
dokku clickhouse:link lollipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_CLICKHOUSE_LOLLIPOP_NAME=/lollipop/DATABASE
DOKKU_CLICKHOUSE_LOLLIPOP_PORT=tcp://172.17.0.1:9000
DOKKU_CLICKHOUSE_LOLLIPOP_PORT_9000_TCP=tcp://172.17.0.1:9000
DOKKU_CLICKHOUSE_LOLLIPOP_PORT_9000_TCP_PROTO=tcp
DOKKU_CLICKHOUSE_LOLLIPOP_PORT_9000_TCP_PORT=9000
DOKKU_CLICKHOUSE_LOLLIPOP_PORT_9000_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
CLICKHOUSE_URL=clickhouse://:SOME_PASSWORD@dokku-clickhouse-lollipop:9000
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the `expose` subcommand. Another service can be linked to your app:

```shell
dokku clickhouse:link other_service playground
```

It is possible to change the protocol for `CLICKHOUSE_URL` by setting the environment variable `CLICKHOUSE_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding.

```shell
dokku config:set playground CLICKHOUSE_DATABASE_SCHEME=clickhouse2
dokku clickhouse:link lollipop playground
```

This will cause `CLICKHOUSE_URL` to be set as:

```
clickhouse2://:SOME_PASSWORD@dokku-clickhouse-lollipop:9000
```

### unlink the Clickhouse service from the app

```shell
# usage
dokku clickhouse:unlink <service> [<app>] [-n|--no-restart]
```

flags:

- `-n|--no-restart`: whether to skip restarting the app

You can unlink a clickhouse service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku clickhouse:unlink lollipop playground
```

### set or clear a property for a service

```shell
# usage
dokku clickhouse:set <service> <key> <value>
```

Set the network to attach after the service container is started:

```shell
dokku clickhouse:set lollipop post-create-network custom-network
```

Set multiple networks:

```shell
dokku clickhouse:set lollipop post-create-network custom-network,other-network
```

Unset the post-create-network value:

```shell
dokku clickhouse:set lollipop post-create-network
```

Set the keyserver a public key for backup encryption is fetched from:

```shell
dokku clickhouse:set lollipop backup-keyserver hkp://keys.example.com
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### connect to the service via the clickhouse connection tool

```shell
# usage
dokku clickhouse:connect <service>
```

Connect to the service via the clickhouse connection tool:

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku clickhouse:connect lollipop
```

### enter or run a command in a running Clickhouse service container

```shell
# usage
dokku clickhouse:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk.

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku clickhouse:enter lollipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku clickhouse:enter lollipop touch /tmp/test
```

### expose a Clickhouse service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)

```shell
# usage
dokku clickhouse:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku clickhouse:expose lollipop 9000 8123
```

Expose the service on the service's normal ports, with the first on a specified ip address (127.0.0.1):

```shell
dokku clickhouse:expose lollipop 127.0.0.1:9000 8123
```

### unexpose a previously exposed Clickhouse service

```shell
# usage
dokku clickhouse:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku clickhouse:unexpose lollipop
```

### promote service <service> as CLICKHOUSE_URL in <app>

```shell
# usage
dokku clickhouse:promote <service> [<app>]
```

If you have a clickhouse service linked to an app and try to link another clickhouse service another link environment variable will be generated automatically:

```
DOKKU_CLICKHOUSE_BLUE_URL=clickhouse://:ANOTHER_PASSWORD@dokku-clickhouse-other-service:9000/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku clickhouse:promote other_service playground
```

This will replace `CLICKHOUSE_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
CLICKHOUSE_URL=clickhouse://:ANOTHER_PASSWORD@dokku-clickhouse-other-service:9000/other_service
DOKKU_CLICKHOUSE_BLUE_URL=clickhouse://:ANOTHER_PASSWORD@dokku-clickhouse-other-service:9000/other_service
DOKKU_CLICKHOUSE_SILVER_URL=clickhouse://:SOME_PASSWORD@dokku-clickhouse-lollipop:9000/lollipop
```

### start a previously stopped Clickhouse service

```shell
# usage
dokku clickhouse:start <service>
```

Start the service:

```shell
dokku clickhouse:start lollipop
```

### stop a running Clickhouse service

```shell
# usage
dokku clickhouse:stop <service>
```

Stop the service and removes the running container:

```shell
dokku clickhouse:stop lollipop
```

### pause a running Clickhouse service

```shell
# usage
dokku clickhouse:pause <service>
```

Pause the running container for the service:

```shell
dokku clickhouse:pause lollipop
```

### graceful shutdown and restart of the Clickhouse service container

```shell
# usage
dokku clickhouse:restart <service>
```

Restart the service:

```shell
dokku clickhouse:restart lollipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku clickhouse:upgrade <service> [--upgrade-flags...]
```

flags:

- `-c|--config-options <string>`: extra arguments to pass to the container create command
- `-C|--custom-env <string>`: semi-colon delimited environment variables to start the service with
- `-i|--image <string>`: the image to upgrade the service to
- `-I|--image-version <string>`: the image version to upgrade the service to
- `-N|--initial-network <string>`: the initial network to attach the service to
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `-R|--restart-apps`: whether to stop and start the linked apps around the upgrade
- `-s|--shm-size <string>`: override shared memory size for the service docker container

You can upgrade an existing service to a new image or image-version:

```shell
dokku clickhouse:upgrade lollipop
```

### Service Automation

Service scripting can be executed using the following commands:

### list all Clickhouse service links for a given app

```shell
# usage
dokku clickhouse:app-links [<app>]
```

List all clickhouse services that are linked to the `playground` app.

```shell
dokku clickhouse:app-links playground
```

### check if the Clickhouse service exists

```shell
# usage
dokku clickhouse:exists <service>
```

Here we check if the lollipop clickhouse service exists.

```shell
dokku clickhouse:exists lollipop
```

### check if the Clickhouse service is linked to an app

```shell
# usage
dokku clickhouse:linked <service> [<app>]
```

Here we check if the lollipop clickhouse service is linked to the `playground` app.

```shell
dokku clickhouse:linked lollipop playground
```

### list all apps linked to the Clickhouse service

```shell
# usage
dokku clickhouse:links <service>
```

List all apps linked to the `lollipop` clickhouse service.

```shell
dokku clickhouse:links lollipop
```

### Disabling `docker image pull` calls

If you wish to disable the `docker image pull` calls that the plugin triggers, you may set the `CLICKHOUSE_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker image pull` is disabled.
