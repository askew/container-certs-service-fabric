@echo off

PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {%~dp0GetKeyVaultAuthToken.ps1 -keyVaultName '%1' -certName '%2'}"
