# [WIP] TTT2 Container Image

This image may be used in the future for testing or even deployment.

Tested and build with `buildah` & `podman`, should also work with `docker`.

## TODOs

- [ ] tidy up environment variables

- [ ] trap SIGTERM and shutdown server gracefully (most likely only possible with `tmux`, pipes and redirections don't seem to work)

- [ ] add possibility to programmatically interact with the serverconsole (again `tmux`)

- [ ] extend the script to allow more than one github repository (or none)

- [X] add mount.cfg to mount css

## Example commands

### Build from Containerfile with buildah

```bash
buildah bud -f Containerfile -t <imagename>
```

### Create container with podman

`srcds_run` seems to need a terminal, so we need to use `--tty` to create a pseudo tty. (No clue how docker handles this)

After the imagename you can specify any commandline arguments you would use for `srcds_run`. `-console -game garrysmod +gamemode terrortown` will always be used and if no arguments are given it will additionally run with `+maxplayers 16 +map gm_flatgrass`.

Rootless Podman's default porthandler wasn't working for me, but since Podman v2.1.0 you can change it with the `--net slirp4netns:port_handler` option.

```bash
podman create -p 27015:27015 -p 27015:27015/udp -v <volume or bindmount>:/home/steam/css_ds -v <volume or bindmount>:/home/steam/gmod_ds --net slirp4netns:port_handler=slirp4netns --tty --name=<containername> <imagename>
```

### Start container with podman

```bash
podman start <containername>
```

### (optional) Attach to the container

```bash
podman attach <containername>
```

`Ctrl + p` & `Ctrl + q` to quit out without killing the server.

### (optional) Follow logfile

```bash
podman logs -f <containername>
```

`Ctrl + c` to quit following the logs.

### Stopping the container cleanly

Attaching to the container (see above) will connect you directly to the gmod serverconsole. Therefore typing `quit` and then pressing enter will cleanly shutdown the server and then the container itself.
