# SQL Server 2019 images
SQL server 2019 Developer Edition image. It downloads the required files from Microsoft and install it. Based on Microsoft's [original image](https://github.com/Microsoft/mssql-docker).
It's intened to be used with windows containers. For linux containers, preferably use [Microsoft's official image](https://hub.docker.com/_/microsoft-mssql-server)

## Build and run
We need to run
```
docker build -f Dockerfile -t sqlserver-2019-windows .
```
to build the base image, downloading the SQL Server 2019 resources.

Afterwards, we can create a container running
```
docker run -d -p 1433:1433 --name sqlserver-2019-win -e sa_password="any password here" sqlserver-2019-windows
```

This should expose the SQL server 2019 instance on port 1433 of the host machine.


## License
MIT