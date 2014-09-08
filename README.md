# Galaxy Base Docker file.
Galaxy stable distribution, shipped with apache2 and postgres. On Debian.

Installation instructions taken from [Galaxy wiki: get galaxy](https://wiki.galaxyproject.org/Admin/GetGalaxy) and
[Galaxy wiki: production server](https://wiki.galaxyproject.org/Admin/Config/Performance/ProductionServer).

By default, Galaxy can take several minutes to load.


# Build

```bash
docker build -t yjarosz/galaxy .
```

# Run

## Daemon mode

The following command will start apache2, postgres and start the galaxy service in **daemon mode**.

```bash
docker run -p 8080:8080 -d yjarosz/galaxy
```

And you should be able to access galaxy server at `<docker ip>:8080`.
**Please wait. It could take minutes to load.**


## Interactive mode
You could also launch the container in **interactive mode**:

```bash
docker run -p 8080:8080 -i -t yjarosz/galaxy interactive
```

It will log in supervisorctl. Useful when you want to have detail about launched process.

```bash
supervisor>
```

Type `help` if you want a list of commands available:

    * `avail` Give you the list of configured processes, it should give you apache2, postgres and galaxy.
    * `tail -f galaxy` will redirect galaxy logging file to your terminal.


## Interactive mode (expert)
* You could also **log in the container** and start the service yourself, inspect filesystem, change galaxy configuration, etc:

```bash
docker run -P -i -t --entrypoint /bin/bash yjarosz/galaxy --
```

Then you can start all process by running `supervisord`.

# Extend

Start your dockerfile with `FROM yjarosz/galaxy`.
