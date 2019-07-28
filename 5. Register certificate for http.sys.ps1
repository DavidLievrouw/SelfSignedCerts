$certHash = ""
$ok = $true
do {
  $certHash = Read-Host "Please enter the certificate thumbprint: "    
}
until ($certHash -ne "")

$httpsPort = -1
$ok = $true
do {
  $input = Read-Host "Please enter a valid HTTPS port number (1025 - 65535): "
  $intValue = $input -as [Int32]
  $ok = $intValue -ne $NULL
  if ($ok -eq $true) {
    if ($intValue -gt 1024 -and $intValue -lt 65536) {
      $httpsPort = $intValue
    }
  }      
}
until ($httpsPort -gt 0)

$guid = [guid]::NewGuid()
$ip = "0.0.0.0"
$httpsPortString = $httpsPort.ToString()

Write-Host "Deleting existing cert for port $httpsPortString..."
"http delete sslcert ipport=$($ip):$httpsPortString" | netsh | Out-Null

Write-Host "Adding cert for port $httpsPortString..."
$addCertResult = "http add sslcert ipport=$($ip):$httpsPortString certhash=$certHash appid={$guid}" | netsh 
$addCertResult = $addCertResult[1..($addCertResult.length-2)]
Write-Host $addCertResult -ForegroundColor Yellow

Write-Host "Deleting existing permissions for port $httpsPortString..."
"http delete urlacl url=https://*:$httpsPortString/" | netsh | Out-Null

Write-Host "Granting HTTPS permissions for port $httpsPortString..."
$grantHttpsResult = "http add urlacl url=https://*:$httpsPortString/ user=everyone" | netsh
$grantHttpsResult = $grantHttpsResult[1..($grantHttpsResult.length-2)]
Write-Host $grantHttpsResult -ForegroundColor Yellow
