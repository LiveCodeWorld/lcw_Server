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
