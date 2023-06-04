FROM mcr.microsoft.com/windows/servercore:ltsc2022

ENV SQLSERVER_2019_BOX_URL "https://download.microsoft.com/download/8/4/c/84c6c430-e0f5-476d-bf43-eaaa222a72e0/SQLServer2019-DEV-x64-ENU.box"
ENV SQLSERVER_2019_EXE_URL "https://download.microsoft.com/download/8/4/c/84c6c430-e0f5-476d-bf43-eaaa222a72e0/SQLServer2019-DEV-x64-ENU.exe"
ENV sa_password="_" \
    ACCEPT_EULA="y"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
COPY entrypoint.ps1 /
WORKDIR /

# Using 'ADD' instead of 'Invoke-WebRequest' because it seems to be a problem when downloading those files using powershell
ADD ${SQLSERVER_2019_BOX_URL} SQL.box
ADD ${SQLSERVER_2019_EXE_URL} SQL.exe

RUN Start-Process -Wait -FilePath .\SQL.exe -ArgumentList /qs, /x:setup ; \
    .\setup\setup.exe /q /ACTION=Install /INSTANCENAME=MSSQLSERVER /FEATURES=SQLEngine /UPDATEENABLED=0 /SQLSVCACCOUNT='NT AUTHORITY\NETWORK SERVICE' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS ; \
    Remove-Item -Recurse -Force SQL.exe, SQL.box, setup


RUN stop-service MSSQLSERVER ; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql15.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpdynamicports -value '' ; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql15.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpport -value 1433 ; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql15.MSSQLSERVER\mssqlserver\' -name LoginMode -value 2 ;

HEALTHCHECK CMD [ "sqlcmd", "-Q", "select 1" ]

CMD .\entrypoint -sa_password $env:sa_password -ACCEPT_EULA $env:ACCEPT_EULA -Verbose