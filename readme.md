# Dalion Development Certificates

## Prerequisites

1. Download and install OpenSSL.
2. Add "C:\Program Files\OpenSSL-Win64\bin" to your PATH environment variable.
3. Verify that "openssl" works from the command line.

## Passwords and sensitive data

1. When creating a Certificate Signing Request, always use password "CertP@ss123".

## Adding a new machine (alias) to a certificate

1. Delete [Domain].crt, [Domain].csr, [Domain].key and [Domain].pfx (these will be generated again).
2. Open [Domain].cnf in Notepad, scroll to the end. If you want to add a new alias, like "my-new-alias", add a line beneath the last DNS.* = ..., incrementing the previous number.
3. Do the same in [Domain].extensions.cnf. (Unfortunate, I know). The whole dalion_subject_alt_names section should be identical to the one in [Domain].cnf.
4. Run '2a. Generate [Domain] certificate signing request.cmd', '3a. Sign [Domain] certificate signing request.cmd' and '4a. Create importable PFX file (cert + key in 1 file).cmd'. If you have to fill in a password, use "CertP@ss123".

Do not run script '1. Generate certificate authority.cmd'. It was used only once to generate the certificate authority, and should it should not be regenerated.

## Installing the certificates
1. Ensure that the "dalion-certificate-authority.crt" file is installed as a Trusted Root Certificate Authority on the machine. Just copy the crt file to the machine, double click it there and follow the wizard. Install for "Local Machine" in location "Trusted Root Certification Authorities". You only ever need to do this once per machine. (Or via group policy).
2. Install the [Domain].pfx on the machine. Just copy the pfx file to the machine, double click it there and follow the wizard. Install for "Local Machine" in location "Personal".

## Using the certificate in IIS (optional)
1. Open "inetmgr" (IIS Manager), select the Default Web Site and choose "Bindings". Add a new binding for HTTPS, leave every field as its default value, and in the Certificate Dropdown choose *.[Domain].

## Using the certificate in weblistener (http.sys) applications (optional)
1. Collect the certificate thumbprint by calling in powershell:
```powershell
dir Cert:\LocalMachine\my | Where-Object { $_.Subject -like "*.[Domain]*" }
```
2. Determine the port number at which you wish to register the certificate (the port at which your application is exposed).
3. Run script '5. Register certificate for http.sys.ps1' with elevated permissions, and enter the collected values when asked.

## Testing
1. When using with IIS: Visit https://localhost(:[port]) and verify that HTTPS is working.
2. When using with http.sys: Visit https://localhost:[port] and verify that HTTPS is working.
3. If you added a new alias: Visit https://my-new-alias(:[port]) and https://my-new-alias.[Domain](:[port]) and verify HTTPS is working. These should also work from other PCs, provided they also have the root certificate authority installed. (as described in chapter "Install the certificate").
