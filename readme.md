# Getting Certificates into Containers

Containers are a great deployment mechanism for micro-services, but if you want to secure your services you will end up needing to deploy certificates. You could simply bake the certificate into the container image, but there are many reasons why this not the best idea.

This example focuses on how to get a certificate stored in [Azure KeyVault][kv] into a container running on [Service Fabric][sf]. The example uses a Windows container running IIS, but the process would be the same for a Linus container, the scripts would be slightly different.

Service Fabric itself doe provide a mechanism for deploying a certificat into a container when the service starts up, see 

[Import a certificate file into a container running on Service Fabric][sfcert]

However this mechanism requires the certificate to be installed on each node in the cluster beforehand. The certificates also need to be installed with an exportable private key. If you use the standard mechanism for deploying certificates to Virtual Machine Scale-sets, the certificates will be installed with rights only to the System account and not exportable. It's also not ideal having to install all the certificate you need onto the cluster nodes.

This example uses Azure Managed Service Identities (MSI) to authenticate to KeyVault to get the certificate. Currently MSIs are a VM level feature. The ability to assign an MSI to a Service Fabric service is on the road-map, by not ready yet. I'll update this when it is.

There are two parts to this solution. First a script that is run as a SetupEntryPoint in the service fabric service. This script makes a call to the MSI endpoint to get an OAuth token for the KeyVault. I did try using this set to install the certificate on the host and using the mechanism in the [article][sfcert], but it seems the `<CertificateRef` is validated before the setup entry point is run. Instead, the script saves the authentication token in a file in the service working directory. Service Fabric mounts this directory when the container starts so the file is then accessible inside the container. The location of the working folder is stored in the environment variable `Fabric_Folder_App_Work`.

The second part is a script ([SetupSsl.ps1][setupssl]) that runs when the container starts up. I've baked this in to the Docker image, but it could also be deployed as part of the service code package as this is also available though a mounted folder. This script reads the OAuth token from the file in the work folder and gets the certificate from KeyVault. It then installs the cert and configures the HTTPS binding in IIS. The script is run by overriding the `ENTRYPOINT` in the [Dockerfile][dockerfile].

This solution is still not perfect as the MSI is still machine based rather than service. But, even though the MSI auth token is written to file, it will be deleted when the service is deleted, leaving nothing on the nodes.

[sf]: https://azure.microsoft.com/en-gb/services/service-fabric/ "Azure Service Fabric"
[kv]: https://azure.microsoft.com/en-gb/services/key-vault/ "Azure KeyVault"
[sfcert]: https://docs.microsoft.com/en-us/azure/service-fabric/service-fabric-securing-containers
[setupssl]: https://github.com/askew/container-certs-service-fabric/blob/master/SetupSsl.ps1
[dockerfile]: https://github.com/askew/container-certs-service-fabric/blob/master/Dockerfile