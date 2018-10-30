# escape=`

FROM microsoft/iis:windowsservercore-1803

WORKDIR C:\

COPY SetupSsl.ps1 .\

ENTRYPOINT [ "PowerShell.exe", "-Command", ".\\SetupSsl.ps1; C:\\ServiceMonitor.exe w3svc" ]