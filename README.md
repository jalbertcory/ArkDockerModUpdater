# ArkDockerModUpdater
Watches the mod folder of Ark docker servers and restart the containers when mods update.

It does this by finding all of the .mod files in the folder and checking their modified time against [this steam api](https://steamapi.xpaw.me/#ISteamRemoteStorage/GetPublishedFileDetails).

If a mod has a newer version externally, the designated Ark servers will be warned that updated mods are going to trigger a restart.  The primary server on the cluster will be used to update the mods, and then the other servers will be started again once the first is working.

This has been built for personal use on a cluster for friends.  No promises of support if things do not work, but feel free to make PRs or use anything you find here for yourself.

# Configuration

### Auto Managed Mods
This container assumes that the first server in the list for RCON ports as well as image names is setup with -automanagedmods.

If you are using the [ich777/steamcmd](https://hub.docker.com/r/ich777/steamcmd) server container on Unraid, adding these volume mapping should fix up the automodmanager:
* /serverdata/serverfiles/Engine/Binaries/ThirdParty/SteamCMD/Linux <> /mnt/user/appdata/steamcmd
* /serverdata/Steam/steamapps <> /mnt/cache/appdata/steamcmd/steamapps
* /serverdata/serverfiles/Engine/Binaries/ThirdParty/SteamCMD/Linux/steamapps <> /mnt/cache/appdata/steamcmd/steamapps

Also make sure to add `-automanagedmods` to the ExtraParameters

### RCON
Additionally, any RCON must be setup correctly which means you need these parameters in your startup command line: `?RCONPort=<SomePort>?RCONEnabled=True?ServerAdminPassword=<YourServerAdminPassword>`.  The server password must be here and not just in your GameUserSettings.ini for RCON to work.

### Volumes
This container needs the following container mounts:
* /Mods <> /pathtomodfolder
  * For example, the Unraid Ark container above would default to /mnt/user/appdata/ark-se/ShooterGame/Content/Mods
  * This is where the docker will check if these mod files are updated
* /var/run/docker.sock <> /var/run/docker.sock
   * This provides the docker socket api to start/stop/get containers

### Variables
The following environment variables are also needed:
* MCRCON_HOST=\<ServerHostIP> or list of hosts
   * This can either be a single host (likely your server IP), or a list of csv of hosts that match with the RCON ports and container names
* MCRCON_PASS=\<YourServerAdminPassword>
* RCON_PORTS= csv list of ports for all servers in the cluster (or single server)
   * for example my cluster of all 9 maps this is `27075,27076,27077,27078,27079,27080,27081,27082,27083`
   * This is the list of ports to notify that the server is shutting down when a mod update is detected
* CONTAINER_NAMES= csv list of all docker containers names for the servers
   * for example my cluster of all 9 maps this is `ARKcluster1Island,ARKcluster1Rag,ARKcluster1Center,ARKcluster1Scorch,ARKcluster1Aberration,ARKcluster1Extinction,ARKcluster1Genesis,ARKcluster1Valguero,ARKcluster1Crystal`
   * The first server in this list will be restarted (so mods can be updated), and all other servers will be stopped and then started once the first is back online (checked via RCON command)

> **It is important that RCON_PORTS, MCRCON_HOST, and CONTAINER_NAMES have the same number of servers and are in the same order.  eg the first host, port, and container name line up, and the second of each line up, etc.**

# Container
The container image is available on dockerhub as: `growlithe/ark-server-mod-restart`

# Unraid
[Here is an Unraid template XML for an example docker cluster set to be updated](ArkUpdaterCluster.xml)