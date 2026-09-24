# dokku clickhouse [![Build Status](https://img.shields.io/github/actions/workflow/status/dokku/dokku-clickhouse/ci.yml?branch=master&style=flat-square "Build Status")](https://github.com/dokku/dokku-clickhouse/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official clickhouse plugin for dokku. Currently defaults to installing [clickhouse/clickhouse-server 26.8.9.10](https://hub.docker.com/r/clickhouse/clickhouse-server/).

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
clickhouse:info [<service>] [--info-flags...]      # print the service information
clickhouse:link <service> [<app>] [--link-flags...] # link the Clickhouse service to the app
clickhouse:linked <service> [<app>]                # check if the Clickhouse service is linked to an app
clickhouse:links <service>                         # list all apps linked to the Clickhouse service
clickhouse:list                                    # list all Clickhouse services
clickhouse:logs <service> [-t|--tail [<tail-num>]] # print the most recent log(s) for this service
clickhouse:mount [--replace] <service> <source:container-dir[:options]>... # mount a host path or docker volume into the service container
clickhouse:pause <service>                         # pause a running Clickhouse service
clickhouse:promote <service> [<app>]               # promote service <service> as CLICKHOUSE_URL in <app>
clickhouse:restart <service>                       # graceful shutdown and restart of the Clickhouse service container
clickhouse:set <service> <key> <value>             # set or clear a property for a service
clickhouse:start <service>                         # start a previously stopped Clickhouse service
clickhouse:stop <service>                          # stop a running Clickhouse service
clickhouse:unexpose <service>                      # unexpose a previously exposed Clickhouse service
clickhouse:unlink <service> [<app>] [-n|--no-restart] # unlink the Clickhouse service from the app
clickhouse:unmount [--all] <service> [<source:container-dir>...] # remove one or all mounts from the service container
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

- `-c|--config-options <string>`: extra arguments for the process the service container runs, not docker flags; use mount for mounts
- `-C|--custom-env <string>`: semi-colon delimited environment variables to start the service with
- `-i|--image <string>`: the image name to start the service with
- `-I|--image-version <string>`: the image version to start the service with
- `-N|--initial-network <string>`: the initial network to attach the service to
- `--log-driver <string>`: the docker logging driver to run the service container with (default: the daemon's own)
- `--log-opt <strings>`: a comma-separated list of key=value docker log options for the service container
- `-m|--memory <int>`: container memory limit in megabytes (default: unlimited)
- `-p|--password <string>`: override the user-level service password
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `--restart <string>`: the docker restart policy to run the service container with (default: always)
- `-r|--root-password <string>`: override the root-level service password
- `-s|--shm-size <string>`: override shared memory size for the service docker container
- `--volume <stringArray>`: a host path or docker volume to mount into the service container, as <source>:<container-dir>[:<options>], repeatable

Create a clickhouse service named lollipop:

```shell
dokku clickhouse:create lollipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the clickhouse/clickhouse-server image.

```shell
export CLICKHOUSE_IMAGE="clickhouse/clickhouse-server"
export CLICKHOUSE_IMAGE_VERSION="26.8.9.10"
dokku clickhouse:create lollipop
```

An image other than clickhouse/clickhouse-server has no version to fall back on, because the version this plugin pins belongs to clickhouse/clickhouse-server, so name one alongside it.

```shell
dokku clickhouse:create lollipop --image <image> --image-version <version>
```

You can also specify custom environment variables to start the clickhouse service in semicolon-separated form.

```shell
export CLICKHOUSE_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku clickhouse:create lollipop
```

The container log is bounded by whatever `dokku logs:set --global max-size` says, and by dokku's own default where it says nothing, which a service may override for itself.

```shell
dokku clickhouse:create lollipop --log-opt max-size=20m,max-file=3
```

The container is restarted by docker whenever it stops, which a service may change for itself.

```shell
dokku clickhouse:create lollipop --restart unless-stopped
```

The config options are handed to the process the container runs, not to docker, so a host path or docker volume is mounted with --volume, which may be repeated.

```shell
dokku clickhouse:create lollipop --volume /var/lib/dokku/data/storage/lollipop:/opt/extra:ro
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

A service that is still linked to an app is not destroyed, and the apps it is linked to are named. Unlink them first.

### print the service information

```shell
# usage
dokku clickhouse:info [<service>] [--info-flags...]
```

flags:

- `--backend`: show the execution backend the service was created with
- `--backup-authenticated`: show whether backup credentials are stored for the service
- `--backup-bucket`: show the bucket scheduled backups are shipped to
- `--backup-encrypted`: show whether scheduled backups are encrypted with a passphrase
- `--backup-keyserver`: show the keyserver backup public keys are fetched from
- `--backup-public-key-id`: show the gpg public key id backups are encrypted with
- `--backup-schedule`: show the cron schedule backups run on
- `--backup-use-iam`: show whether scheduled backups authenticate with an instance role
- `--config-dir`: show the service configuration directory
- `--config-options`: show the config options the service container is run with
- `--custom-env`: show the custom environment the service container is run with
- `--data-dir`: show the service data directory
- `--database-name`: show the name of the database inside the service
- `--definition`: show the definition the service was created with
- `--dsn`: show the service DSN
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--image`: show the image the service runs
- `--image-version`: show the image version the service was created with
- `--initial-network`: show the initial network being connected to
- `--internal-ip`: show the service internal ip
- `--links`: show the service app links
- `--log-driver`: show the docker logging driver the service container is run with
- `--log-opt`: show the docker log options the service container is run with
- `--memory`: show the memory limit the service container is run with
- `--mounts`: show the host paths and docker volumes mounted into the service container
- `--post-create-network`: show the networks to attach to after service container creation
- `--post-start-network`: show the networks to attach to after service container start
- `--restart-policy`: show the restart policy the service container is run with
- `--service`: show the name of the service
- `--service-root`: show the service root directory
- `--shm-size`: show the shared memory size the service container is run with
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku clickhouse:info lollipop
```

Alongside the connection information this reports the properties set on the service, the state it was created with, and its backup settings. A property that was never set, or that was unset, reports as empty. Omit the service to report on every clickhouse service:

```shell
dokku clickhouse:info
```

The information can be read by machine, one json object per service:

```shell
dokku clickhouse:info lollipop --format json
```

You can also retrieve a specific piece of service info via a flag, which prints it on its own:

```shell
dokku clickhouse:info lollipop --dsn
dokku clickhouse:info lollipop --status
dokku clickhouse:info lollipop --initial-network
```

> NOTE: a flag cannot be combined with --format, and only one may be given

The properties clickhouse:set writes are reported under the names it takes, so a value read here can be written back:

```shell
dokku clickhouse:set lollipop initial-network my-network
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

It is possible to change the protocol for `CLICKHOUSE_URL` by setting the environment variable `CLICKHOUSE_DATABASE_SCHEME` on the app. Doing so after linking means unlink no longer finds the variable it set, and leaves it in place, so we advise you to unlink before proceeding.

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

An app is still linked after its `CLICKHOUSE_URL` is changed to point elsewhere, and is unlinked the same way. The variable it now holds is not the service's, so it is left alone, nothing is unset, the app is not restarted, and a warning says so.

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

Cap the container log at a size of your own rather than the one it inherits:

```shell
dokku clickhouse:set lollipop log-opt max-size=20m,max-file=3
```

Keep the log unbounded, which is what a service had before there was anything to say here:

```shell
dokku clickhouse:set lollipop log-opt max-size=unlimited
```

Send the container log somewhere other than the daemon's own driver:

```shell
dokku clickhouse:set lollipop log-driver journald
```

Restart the container unless it was stopped on purpose, including across a docker restart:

```shell
dokku clickhouse:set lollipop restart-policy unless-stopped
```

Go back to always restarting the container:

```shell
dokku clickhouse:set lollipop restart-policy
```

> NOTE: a log setting or a restart policy reaches the container the next time one is built. clickhouse:restart keeps the container it has, so use clickhouse:stop and then clickhouse:start on a service that is already running.

### mount a host path or docker volume into the service container

```shell
# usage
dokku clickhouse:mount [--replace] <service> <source:container-dir[:options]>...
```

flags:

- `--replace`: replace the service's entire set of mounts with the ones given
- `--volume-chown <string>`: a chown option, recorded but not applied; not valid with --replace
- `--volume-options <string>`: comma-separated docker mount options, such as z or nocopy; not valid with --replace
- `--volume-readonly`: mount the volume read only; not valid with --replace
- `--volume-subpath <string>`: a subpath within the source, recorded but not applied; not valid with --replace

Mount a host directory into the service container:

```shell
dokku clickhouse:mount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra
```

The source is an absolute host path, which must already exist, or the name of a docker volume. Options follow a second colon: ro or rw, docker's own mount options, and volume-subpath=<path> and volume-chown=<option>, which are recorded but not applied:

```shell
dokku clickhouse:mount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra:ro,z
```

The same can be said with flags instead:

```shell
dokku clickhouse:mount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra --volume-readonly --volume-options z
```

Mounting the same source at the same directory again rewrites its options:

```shell
dokku clickhouse:mount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra
```

Replace every mount the service has with the ones given:

```shell
dokku clickhouse:mount --replace lollipop /srv/a:/opt/a:ro /srv/b:/opt/b
```

> NOTE: a mount reaches the container the next time one is built. clickhouse:restart keeps the container it has, so use clickhouse:stop and then clickhouse:start on a service that is already running.

### remove one or all mounts from the service container

```shell
# usage
dokku clickhouse:unmount [--all] <service> [<source:container-dir>...]
```

flags:

- `--all`: remove every mount the service has

Remove a mount, naming it the way it was mounted:

```shell
dokku clickhouse:unmount lollipop /var/lib/dokku/data/storage/lollipop:/opt/extra
```

Remove every mount the service has:

```shell
dokku clickhouse:unmount --all lollipop
```

> NOTE: the mount is removed from the container the next time one is built. clickhouse:restart keeps the container it has, so use clickhouse:stop and then clickhouse:start on a service that is already running.

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

A service comes back on the version it was created with, or was last upgraded to, whatever version the plugin ships now. The image is fetched if the host no longer has it. A service that has never recorded a version and has no container left to read one from cannot be placed, and is reported rather than started on a guess. Use clickhouse:upgrade to say which version it should run.

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

- `-c|--config-options <string>`: extra arguments for the process the service container runs, not docker flags; use mount for mounts
- `-C|--custom-env <string>`: semi-colon delimited environment variables to start the service with
- `-i|--image <string>`: the image to upgrade the service to
- `-I|--image-version <string>`: the image version to upgrade the service to
- `-N|--initial-network <string>`: the initial network to attach the service to
- `--log-driver <string>`: the docker logging driver to run the service container with (default: the daemon's own)
- `--log-opt <strings>`: a comma-separated list of key=value docker log options for the service container
- `-P|--post-create-network <strings>`: a comma-separated list of networks to attach the service container to after service creation
- `-S|--post-start-network <strings>`: a comma-separated list of networks to attach the service container to after service start
- `--restart <string>`: the docker restart policy to run the service container with (default: always)
- `-R|--restart-apps`: whether to stop and start the linked apps around the upgrade
- `-s|--shm-size <string>`: override shared memory size for the service docker container
- `--volume <stringArray>`: a host path or docker volume to mount into the service container, as <source>:<container-dir>[:<options>], repeatable

You can upgrade an existing service to a new image or image-version:

```shell
dokku clickhouse:upgrade lollipop
```

This is the only command that changes the version a service runs. With no version named it moves to the newest the service's own major version ships, which leaves the data where it is.

```shell
dokku clickhouse:upgrade lollipop --image-version 1.2.3
```

Moving across a major version has to be asked for by name, because it is not a tag change: the data is mounted somewhere different under the new one, and pointing the version back does not undo it. A service keeps the mounts it has unless --volume is passed, which replaces them, and each one is checked against the new container before the old one is taken away.

```shell
dokku clickhouse:upgrade lollipop --volume /var/lib/dokku/data/storage/lollipop:/opt/extra:ro
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

Renaming an app moves its link onto the new name, and cloning an app links the clone as well as the original.

### Disabling `docker image pull` calls

If you wish to disable the `docker image pull` calls that the plugin triggers, you may set the `CLICKHOUSE_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker image pull` is disabled.
