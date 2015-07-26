# SpigotMC - High Performance Minecraft Server

* * *


## About this image

This Docker image allows you to get a Spigot instance quickly, with minimal fuss.

This image was based on the `dlord/minecraft` Docker Image, with a few changes to
allow compiling Spigot from source.


## Base Docker image

* java:7


## How to use this image

### Starting an instance

    docker run \
        --name minecraft-instance \
        -p 0.0.0.0:25565:25565 \
        -d \
        -e DEFAULT_OP=dinnerbone \
        -e MINECRAFT_EULA=true \
        dlord/spigot

By default, this starts up a Minecraft 1.8.7 server instance. If you wish to
start a different server version, you need to set the `MINECRAFT_VERSION`
variable to the appropriate version. You will need to check Spigot's
documentation to determine the supported Minecraft versions.

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


### Data volumes

There are two data volumes declared for this image:

#### `/opt/minecraft`

All server-related artifacts (jars, configs)' and world templates go
here.

#### `/var/lib/minecraft`

This contains the world data. This is a deliberate decision in order to support
building Docker images with a world template (useful for custom maps).

The recommended approach to handling world data is to use a separate data
volume container. You can create one with the following command:

    docker run --name minecraft-data -v /var/lib/minecraft java:7 true

The startup script updates the permissions of the data volumes before running
Minecraft. You are free to modify the contents of these directories without
worrying about permissions.


### Environment Variables

The image uses environment variables to configure the JVM settings and the
server.properties.

**MINECRAFT_EULA**

`MINECRAFT_EULA` is required when starting creating a new container. You need to
agree to Minecraft's EULA before you can start Spigot.

**DEFAULT_OP**

`DEFAULT_OP` is required when starting creating a new container.

**MINECRAFT_OPTS**

You may adjust the JVM settings via the `MINECRAFT_OPTS` variable.

**server.properties**

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

This image is meant to be extended for packaging custom maps and modpacks as
Docker images.

If you wish to do so, here are some things you will need to know:

### `MINECRAFT_HOME`

This is where all server related artifacts go, and its default location is
`/opt/minecraft`. If you are building a Docker image for a modpack, you will
want to copy the modpack distribution here.

This Docker image supports the use of world templates, which is useful for
custom maps. You will want to copy your world template to `MINECRAFT_HOME/world`.
During startup, it will check if `/var/lib/minecraft` is empty. If so, it will
create a copy of the world template on this folder.

### `MINECRAFT_VERSION`

Modpacks will require a specific Minecraft version in order to work. This can
be done setting the `MINECRAFT_VERSION` in your Dockerfile.

### `MINECRAFT_STARTUP_JAR`

When packaging a modpack, you will need to start the server using a different
jar file. To specify the startup jar, set the `MINECRAFT_STARTUP_JAR` variable
in your Dockerfile.

### `MINECRAFT_OPTS`

Some modpacks have their own recommended JVM settings. You can include them
via the `MINECRAFT_OPTS` variable in your Dockerfile.

### Data Volumes

It is good practice to declare the `MINECRAFT_HOME` folder as a data volume on
your Dockerfile. This makes it easier for server admins to customize the
modpack/custom map.


## Supported Docker versions

This image has been tested on Docker version 1.1.1.


## Feedback

Feel free to open a [Github issue][].

If you wish to contribute, you may open a pull request.

[Github issue]: https://github.com/dlord/minecraft-docker/issues
[Minecraft EULA]: https://account.mojang.com/documents/minecraft_eula
