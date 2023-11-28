script "lib_Ngrok"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Ngrok
type: library
version: 0.1

/*Some help*/

--> Variables
-

--> Working on
-
command nohup_DoShell someShell, pLog
   put nohup_Add (someShell) into noHupShell
   --
   put shell (noHupShell) into shellResult
   -- [1]+  3122 Running                 /usr/bin/nohup /Users/david/.nvm/versions/node/v21.0.0/bin/wiki --security_legacy > /dev/null 2>&1 &
   put word 2 of shellResult into pID
   return pID
end nohup_DoShell

function nohup_Add someShell
   put "nohup" && someShell into noHupShell
   
   # Add redirect output bit (log if needed)
   put space & bash_RedirectBit (pLog) after noHupShell
   put space & "jobs -l" after noHupShell
   --
   return noHupShell
end nohup_Add

function bash_RedirectBit pLog
   -- put "> /dev/null 2>&1 < /dev/null" into reDirectOutput
   if pLog is true then
      put "> nohup.out 2> error.log &" after reDirectOutput
   else
      put "> /dev/null 2>&1 &" after reDirectOutput
   end if
   return reDirectOutput
end bash_RedirectBit


--> Ngrok
-
command ngrok_Redirect sDomain, pLocalHostPort, pAddCors, pLog
   -- defaults suitable for local wiki
   if pLocalHostPort is empty then put 80 into pLocalHostPort
   put "ngrok http" && pLocalHostPort into someShell
   if pAddCors is not false then
      put space & "--response-header-add 'Access-Control-Allow-Origin: *'" after someShell
   end if
   put space & "--domain=" & sDomain after someShell
   
   # Nohup
   nohup_DoShell someShell, pLog
   put the result into pID
   return pID
end ngrok_Redirect

command ngrok_Kill pIDs
   if pIDs is emptyr then
      put ngrok_ListProcessIds() into pIDs
   end if
   --
   repeat for each item pID in pIDs
      kill process pID
   end repeat
end ngrok_Kill

function ngrok_ListProcessIds
   return shell_ListProcessIds ("ngrok http")
end ngrok_ListProcessIds

command ngrok_CreateDomain sDomain, pRegion, pDecription, pCertificateID
   /*
   -H "Authorization: Bearer {API_KEY}"
   -H "Content-Type: application/json"
   -H "Ngrok-Version: 2"
   -d '{"domain":"myapp.mydomain.com","region":"us","certificate_id":"cert_2XB9tGTNIQbWhsqoFzoSmvkq2DD"}'
   https://api.ngrok.com/reserved_domains
   */
   
   put "https://api.ngrok.com/reserved_domains" into restUrl
   
   if pRegion is empty then put "eu" into pRegion
   put sDomain into postData ["domain"]
   --
   if pRegion is not empty then put pRegion into postData ["region"] -- Optional, null by default. (au, eu, ap, us, jp, in, sa)
   if pDecription is not empty then put pDecription into postData ["description"]
   if pCertificateID is not empty then put pCertificateID into postData ["certificate_id"]
   --
   put ngrok_GetBearerToken() into bearerToken
   put jsonrpc_PostArray (postData, restUrl, bearerToken, "Ngrok-Version: 2") into rData
   --
   display_Data rData
   return rData
end ngrok_CreateDomain


--> Ngrok
-
function ngrok_GetBearerToken
   put secret_Get ("ngrokBearerToken") into ngrokBearerToken
   return ngrokBearerToken
end ngrok_GetBearerToken

command ngrok_SetBearerToken ngrokBearerToken
   secret_Set "ngrokBearerToken", ngrokBearerToken
   put the result into secretFile
   return secretFile
end ngrok_SetBearerToken
