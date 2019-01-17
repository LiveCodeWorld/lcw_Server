script "lib_DynadotRest"
--> MetaData
-
license: GPLv3
name: lib_DynadotRest
type: library
version: 0.2

/*
-- command dynadot_SetAuthHeaders
put dynadot_GetApiKey() into OceanApiKey

put "Content-Type: application/json" into someHeader
put CR & "Authorization: Bearer" && OceanApiKey after someHeader
set the httpheaders to someHeader
end dynadot_SetAuthHeaders
*/

--> Variables
-
constant DynadotApiStem = "https://api.dynadot.com/api2.html"
constant AdvancedDynadotApiStem = "https://api.dynadot.com/api3.xml"
constant DynadotAdvancedApiHelpUrl = "https://www.dynadot.com/domain/api3.html"
constant DynadotDomainApiHelpUrl = "https://www.dynadot.com/domain/api2.html"
local DynadotApiKey


--> Dynadot | Rest | Authentication
-
function dynadot_GetApiKey   
   put secret_Get ("DynadotApiKey", "apiKey") into oAuthToken
   return oAuthToken 
end dynadot_GetApiKey

command dynadot_SetApiKey oAuthToken
   secret_Set "DynadotApiKey", "apiKey", oAuthToken
   put the result into modelDataFile
   return modelDataFile
end dynadot_SetApiKey


--> Dynadot | REST
-
function dynadot_FetchNameServerXml domainName
   -- https://api.dynadot.com/api2.html?key=8S7I2s6Qd8g&command=get_ns&domain=mydomain.com
   put DynadotApiStem & "?key=" & dynadot_GetApiKey() & "&command=get_ns&domain=" & domainName into someUrl
   put url someUrl into someXML
   return someXML
end dynadot_FetchNameServerXml

function dynadot_FetchSearchXml domainName
   -- put "domain0=mydomain.com&domain1=mydomain.net" into domainList
   put "domain0=" & domainName into domainList
   put DynadotApiStem & "?key=" & dynadot_GetApiKey() & "&command=search&" & domainList into someUrl
   put url someUrl into someResult
   return someResult
end dynadot_FetchSearchXml

function dynadot_GetAdvancedXML someCommand, pKey, pValue
   -- put dynadot_ConstructAdvancedURL (someCommand, pKey, pValue) into someURL
   put AdvancedDynadotApiStem & "?key=" & dynadot_GetApiKey() & "&command=" & someCommand into someUrl
   get the paramcount
   put (it - 1)/2 into maxPairNum
   repeat with pairNum = 1 to maxPairNum
      put (pairNum - 1)*2 + 2 into keyNum
      put param (keyNum) into keyName
      if keyName is empty then exit repeat
      
      put keyNum + 1 into valueNum
      put param (valueNum) into keyValue
      --
      put "&" & keyName & "=" & keyValue after someUrl
   end repeat
   --
   put url someUrl into someXML
   if dynadot_CheckError (someXML) is not empty then
      breakpoint
      return empty
   end if
   return someXML
end dynadot_GetAdvancedXML


--> Dynadot | REST | URLs
-
function dynadot_ConstructSimpleURL someCommand, pKey, pValue
   put DynadotApiStem & "?key=" & dynadot_GetApiKey() & "&command=" & someCommand into someUrl
   if pKey is not empty then
      put "&" & pKey & "=" & pValue after someUrl
   end if
   return someUrl
end dynadot_ConstructSimpleURL

function dynadot_ConstructAdvancedURL someCommand, pKey, pValue
   put AdvancedDynadotApiStem & "?key=" & dynadot_GetApiKey() & "&command=" & someCommand into someUrl
   get the paramcount
   put (it - 1)/2 into maxPairNum
   repeat with pairNum = 1 to maxPairNum
      put (pairNum - 1)*2 + 2 into keyNum
      put param (keyNum) into keyName
      if keyName is empty then exit repeat
      
      put keyNum + 1 into valueNum
      put param (valueNum) into keyValue
      --
      put "&" & keyName & "=" & keyValue after someUrl
   end repeat
   return someUrl
end dynadot_ConstructAdvancedURL


--> Private
-
private command dynadot_XmlResponseErrorExit responseArray
   if dynadot_GetTestResponse (responseArray) is false  then
      put someUrl & CR & CR & someXML
      answer "Error fetching XML!"
      exit to top 
   end if
end dynadot_XmlResponseErrorExit

private function dynadot_GetTestResponse responseArray
   -- this is for the advanced api
   -- https://www.dynadot.com/domain/api3.html
   put responseArray ["ListDomainInfoHeader"] ["ResponseCode"] is 0 into someBoolean
   return someBoolean
end dynadot_GetTestResponse

function dynadot_CheckError someXML
   switch line 1 of someXML
      case "error,unknown command"
         return someXML
      case "error,invalid key"
         return someXML
      default
         -- case "ok"
         /*
         ok,
         
         success,ns1.digitalocean.com,ns2.digitalocean.com,ns3.digitalocean.com,,,,,,,,,,,Name Servers
         */
         return empty
   end switch
end dynadot_CheckError
