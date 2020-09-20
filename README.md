# [WIP] TTT2 Container Image

This image may be used in the future for testing or even deployment.

Tested and build with `buildah` & `podman`, should also work with `docker`.

## TODOs

- [ ] tidy up environment variables

- [ ] trap SIGTERM and shutdown server gracefully (most likely only possible with `tmux`, pipes and redirections don't seem to work)

- [ ] add possibility to programmatically interact with the serverconsole (again `tmux`)

- [ ] extend the script to allow more than one github repository (or none)

- [ ] add mount.cfg to mount css

## Example commands

### Build from Containerfile with buildah

```bash
buildah bud -f Containerfile -t <imagename>
```

### Create container with podman

`srcds_run` seems to need a terminal, so we need to use `--tty` to create a pseudo tty. (No clue how docker handles this)

After the imagename you can specify any commandline arguments you would use for `srcds_run`. `-console -game garrysmod +gamemode terrortown` will always be used and if no arguments are given it will additionally run with `+maxplayers 16 +map gm_flatgrass`.

```bash
podman create -p 27015:27015 -p 27015:27015/udp -v css_vol:/home/steam/css_ds -v gmod_vol:/home/steam/gmod_ds --tty <imagename>
```

### Start container with podman

```bash
podman start -l
```

### (optional) Attach to the container

```bash
podman attach -l
```

`Ctrl + p` & `Ctrl + q` to quit out without killing the server.

### (optional) Follow logfile

```bash
podman logs -l -f
```

`Ctrl + c` to quit following the logs.

### Stopping the container

```bash
podman stop -l
```

This will 'hang' until it reaches the timeout (default 10s) and then proceed to kill the container. As the entrypoint script does not trap the `SIGTERM` sent by `podman stop` (for now).
