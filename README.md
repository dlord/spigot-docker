# SpigotMC - High Performance Minecraft Server

* * *


## About this image

This Docker image allows you to get a Spigot instance quickly, with minimal fuss.

This image was based on the `dlord/minecraft` Docker Image, with a few changes
and enhancements.


## Base Docker image

* java:7


## How to use this image

### Starting an instance

    docker run \
        --name spigot-instance \
        -p 0.0.0.0:25565:25565 \
        -d \
        -it \
        -e DEFAULT_OP=dinnerbone \
        -e MINECRAFT_EULA=true \
        dlord/spigot

By default, this starts up a Spigot 1.8.8 server instance. If you wish to
start a different server version, you need to set the `MINECRAFT_VERSION`
variable to the appropriate version. You will need to check Spigot's
documentation to determine the supported Spigot versions.

You must set the `DEFAULT_OP` variable on startup. This should be your
Minecraft username. The container will fail to run if this is not set.

When starting a Spigot instance, you must agree to the terms stated in
Minecraft's EULA. This can be done by setting the `MINECRAFT_EULA` variable
to `true`. Without this, the server will not run.

This image exposes the standard minecraft port (25565).

When starting a container for the first time, it will check for the existence of
the Spigot jar file. If this does not exist, it will download BuildTools and
compile Spigot from source. As much as I want to provide the precompiled
binaries, I am avoiding any legal complications.

It is highly preferred to start the container with `-it`. This is needed in
order to allow executing console commands via `docker exec`. This also allows
Spigot to safely shutdown when stopping the container via `docker stop`. See
the `Scripting` section for more details.

#### Commands

The image uses an entrypoint script called `spigot`, which allows you to
execute preset commands. Should you attempt to execute an unrecognized command,
it will treat it as a regular shell command.

The commands are as follows:

* `run` - This runs the Spigot server, and is the default command used by the
  container. This command can accept additional parameters. Useful when
  creating a new container via `docker create` or `docker run`
* `permissions` - This updates the permissions of all related files and
  folders. Useful when manually editing a file.
* `console` - This executes a console command. This allows system administrators
  to perform complex tasks via scripts. This feature is off by default. See the
  `Scripting` section for more details and examples.

Here are some examples on how to use these commands:

**run - specify a different Spigot configuration file inside /opt/minecraft**

    docker run \
        --name spigot-instance \
        -p 0.0.0.0:25565:25565 \
        -d \
        -it \
        -e DEFAULT_OP=dinnerbone \
        -e MINECRAFT_EULA=true \
        dlord/spigot
        run --spigot-settings spigot-test.yml

**permissions - update file and folder permissions while a container is running**

    docker exec spigot-instance spigot permissions

#### Scripting

Unlike other Spigot Docker Images, this image provides a way to execute console
commands without attaching to the docker container. It lets system
administrators perform much more complex tasks, such as managing the docker
container from another docker container (docker-in-docker).

For those who are used to running `docker attach` inside a `screen` or `tmux`
session for scripting, this is going to be heaven.

This feature can be enabled by pasing the `-it` parameter to `docker create` or
`docker run`, which enables STDIN and TTY. This runs the Spigot server inside a
`tmux` session. This also enables safe shutdown mode when the container is
stopped.

Once enabled, you may now execute console commands like so:

    docker exec spigot-instance spigot console say hello everybody!

Some warnings when using this feature:

* **DO NOT USE `-it` ON `docker exec`!** For some reason, it crashes
  the `tmux` session that drives this feature.
* **Be careful when attaching to the console via `docker attach`**. You are
  attaching to a `tmux` session running on the foreground with the footer
  disabled. Do not try to detach from the `tmux` session using `CTRL-b d`,
  otherwise this will stop the container. To detach from the container, use
  `CTRL-p CTRL-q`, which is the standard escape sequence for `docker attach`.

Here are is an example on how to notify players that the server will be shutdown
after 60 seconds:

    #!/bin/bash
    docker exec spigot-instance spigot console say We will be shutting down the server in 60s!
    docker exec spigot-instance spigot console say Stop whatever you are doing!
    sleep 60
    docker exec spigot-instance spigot console say We will be back in 1 hour!
    sleep 5
    
    # The container will send the stop console command to the server for you, to
    # ensure that the server is shutdown safely.
    #
    # Of course you can run this manually like so:
    #
    #     docker exec spigot-instance spigot console stop
    #
    # But this will restart the container if the restart policy is set to always.
    docker stop -t 60 spigot-instance


#### Spigot BuildTools Caveat

One major problem with Spigot's BuildTools is that it doesn't entirely respect
the server version you want to compile. If the specified `MINECRAFT_VERSION`
does not exist, it will always compile the latest version. And if the compiled
jar version does not match the `MINECRAFT_VERSION`, this will cause the
container to stop.

Given my limited knowledge of dealing with bash scripts, I currently have no
way of detecting what version was compiled.

Should this happen, you may opt to copy the compiled jars to a data volume
mapped to `MINECRAFT_HOME` (default is `/opt/minecraft`), and use that to start
a new container with the appropriate `MINECRAFT_VERSION`.


### Data volumes

There are two data volumes declared for this image:

#### /opt/minecraft

All server-related artifacts (jars, configs)' and world templates go
here.

#### /var/lib/minecraft

This contains the world data. This is a deliberate decision in order to support
building Docker images with a world template (useful for custom maps).

The recommended approach to handling world data is to use a separate data
volume container. You can create one with the following command:

    docker run --name minecraft-data -v /var/lib/minecraft java:7 true

The startup script updates the permissions of the data volumes before running
Spigot. You are free to modify the contents of these directories without
worrying about permissions.

For some Spigot plugins, this location would cause unnecessary confusion due to
how Minecraft handles world paths. Should you wish to use the default location
(under `/opt/minecraft`), you may need to provide your own `server.properties`.


### Environment Variables

The image uses environment variables to configure the JVM settings and the
server.properties.

#### MINECRAFT_EULA

`MINECRAFT_EULA` is required when starting creating a new container. You need to
agree to Minecraft's EULA before you can start Spigot.

#### DEFAULT_OP

`DEFAULT_OP` is required when starting creating a new container.

#### MINECRAFT_OPTS

You may adjust the JVM settings via the `MINECRAFT_OPTS` variable.

#### Environment variables for server.properties

Each entry in the `server.properties` file can be changed by passing the
appropriate variable. To make it easier to remember and configure, the variable
representation of each entry is in uppercase, and uses underscore instead
of dash.

The server port cannot be changed. This has to be remapped when starting an
instance.

For reference, here is the list of environment variables for `server.properties`
that you can set:

* GENERATOR_SETTINGS
* OP_PERMISSION_LEVEL
* ALLOW_NETHER
* LEVEL_NAME
* ENABLE_QUERY
* ALLOW_FLIGHT
* ANNOUNCE_PLAYER_ACHIEVEMENTS
* LEVEL_TYPE
* ENABLE_RCON
* FORCE_GAMEMODE
* LEVEL_SEED
* SERVER_IP
* MAX_BUILD_HEIGHT
* SPAWN_NPCS
* WHITE_LIST
* SPAWN_ANIMALS
* SNOOPER_ENABLED
* ONLINE_MODE
* RESOURCE_PACK
* PVP
* DIFFICULTY
* ENABLE_COMMAND_BLOCK
* PLAYER_IDLE_TIMEOUT
* GAMEMODE
* MAX_PLAYERS
* SPAWN_MONSTERS
* VIEW_DISTANCE
* GENERATE_STRUCTURES
* MOTD


## Extending this image

This image is meant to be extended for packaging custom maps, plugins, and
configurations as Docker images. For server owners, this is the best way to
roll out configuration changes and updates to your servers.

If you wish to do so, here are some of the things you will need to know:

### ONBUILD Trigger

This Docker image contains one `ONBUILD` trigger, which copies any local files
to `/usr/src/minecraft`.

When a container is started for the first time, the contents of this folder is
copied to `MINECRAFT_HOME` via `rsync`. It will also ensure that the
`MINECRAFT_HOME/plugins` folder exists, and it will clean out any plugin jar
files to make way for new ones. This is the simplest way to roll out updates
without going inside the data volume.

### Home Folder

This is where all server related artifacts go, and its default location is
`/opt/minecraft`. This can be customized via the `MINECRAFT_HOME` environment
variable.

This Docker image supports the use of world templates, which is useful for
custom maps. You will want to copy your world template to `MINECRAFT_HOME/world`.
During startup, it will check if `/var/lib/minecraft` is empty. If so, it will
create a copy of the world template on this folder.

### JVM Arguments

You can include them via the `MINECRAFT_OPTS` variable in your Dockerfile.


## Supported Docker versions

This image has been tested on Docker version 1.9


## Feedback and Contributions

Feel free to open a [Github issue][].

If you wish to contribute, you may open a pull request. I am very strict with
commit standards, and pull requests with no descriptions will be closed
immediately.

For commit standards, I follow a similar style to the Linux Kernel. See section
1.2 of the [How to Get Your Change Into the Linux Kernel][]. For examples and
tips, check out [this guide by Chris Beams][].

[Github issue]: https://github.com/dlord/minecraft-docker/issues
[Minecraft EULA]: https://account.mojang.com/documents/minecraft_eula
[How to Get Your Change Into the Linux Kernel]: https://www.kernel.org/doc/Documentation/SubmittingPatches
[this guide by Chris Beams]: http://chris.beams.io/posts/git-commit/
