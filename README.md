# Run PostGIS in Docker Container

You need to install:

* [Docker Desktop](https://www.docker.com/products/docker-desktop) if is on Mac / Windows desktop environment.
* [PowerShell Core v7+](https://github.com/PowerShell/PowerShell)

This docker-compose project consist of a [PostGIS](https://postgis.net/) development DB instance and an admin web portal "[pgAdmin](https://www.pgadmin.org/)".

And those configurable port & account/password values are stored in **dev.env** file.

## Start/Stop service

### Start PostGIS & pgAdmin

Execute `dev_start.ps1` in PowerShell Core.

To customize additional parameters like *docker-compose project name*, *PostGis DB name* & *DB binding port*, *pgAdmin4 binding port*, look up help by invoking `Get-Help .\dev_start.ps1 -Full`, for example:

```powershell
dev_start.ps1 -compose_proj local-test -gis_db local_dev -gis_port 5433 -admin_port 8089
```

If you need to reset those parameters, just remove the `.env` environment variables file in base folder.

### Start only PostGIS

Set environment variable `COMPOSE_PROFILES` to **dev** before executing `dev_start.ps1`:  

```powershell
$env:COMPOSE_PROFILES='dev'; dev_start.ps1
```

### Stop PostGIS & pgAdmin

Execute `dev_stop.ps1` in PowerShell Core.

## Remove service

### Remove container but keep data

Execute `dev_remove.ps1` in PowerShell Core.

### Remove container and data

Execute `dev_remove.ps1 --volumes` in PowerShell Core.

## Additional Notes

Customized docker-compose project environment variables are stored in `.env` file inside top folder, to reset customized setting, just run `dev_remove.ps1` and also remove that `.env` file.
