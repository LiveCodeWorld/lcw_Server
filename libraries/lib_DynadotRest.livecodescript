script "lib_DynadotRest"
--> MetaData
-
license: GPLv3
name: lib_DynadotRest
type: library
version: 0.2

/*
*/

--> Variables
-
constant DynadotApiStem = "https://api.dynadot.com/api2.html"
constant AdvancedDynadotApiStem = "https://api.dynadot.com/api3.xml"
constant AdvancedDynadotApiJsonStem = "https://api.dynadot.com/api3.json"
constant DynadotAdvancedApiHelpUrl = "https://www.dynadot.com/domain/api3.html"
constant DynadotDomainApiHelpUrl = "https://www.dynadot.com/domain/api2.html"
local DynadotApiKey


--> Working on
-
function dynadot_ConstructRestUrl someCommand, paramArray
   put AdvancedDynadotApiJsonStem & "?key=" & dynadot_GetApiKey() & "&command=" & someCommand into restURL
   
   # Add params
   if paramArray is an array then
      repeat for each key keyName in paramArray
         put paramArray [keyName] into keyValue
         --
         put "&" & keyName & "=" & keyValue after restURL
      end repeat
   else
      get the paramcount
      put (it - 1)/2 into maxPairNum
      repeat with pairNum = 1 to maxPairNum
         put (pairNum - 1)*2 + 2 into keyNum
         put param (keyNum) into keyName
         if keyName is empty then exit repeat
         
         put keyNum + 1 into valueNum
         put param (valueNum) into keyValue
         --
         put "&" & keyName & "=" & keyValue after restURL
      end repeat
   end if
   --
   return restURL
end dynadot_ConstructRestUrl


--> Dynadot
-
function dynadot_FetchArrayFromXml
   -- v3
   -- https://api.dynadot.com/api3.xml?key=mykey&command=list_domain
   put dynadot_GetAdvancedXML ("list_domain") into someXML
   if dynadot_CheckError (someXML) is not empty then
      breakpoint
   end if
   --
   put xml_ToArray (someXML) into responseArray
   _CheckApiError responseArray, errorText
   --
   if the result is false then
      lcw_AnswerWarning "There was an api error fetching Dynadot IndexDomainArray..."
   end if
   return responseArray
end dynadot_FetchArrayFromXml

function dynadot_FetchArray someCommand, pKey, pValue
   put AdvancedDynadotApiJsonStem & "?key=" & dynadot_GetApiKey() & "&command=" & someCommand into restURL
   
   # Add params
   get the paramcount
   put (it - 1)/2 into maxPairNum
   repeat with pairNum = 1 to maxPairNum
      put (pairNum - 1)*2 + 2 into keyNum
      put param (keyNum) into keyName
      if keyName is empty then exit repeat
      
      put keyNum + 1 into valueNum
      put param (valueNum) into keyValue
      --
      put "&" & keyName & "=" & keyValue after restURL
   end repeat
   
   # Json RPC GET
   put dynadot_GetApiKey() into authToken
   put jsonrpc_GetArray (restURL, authToken) into rData
   return rData
end dynadot_FetchArray

function dynadot_GetAdvancedJson someCommand, pKey, pValue
   -- https://api.dynadot.com/api3.json?key=mykey&command=list_domain
   put AdvancedDynadotApiJsonStem & "?key=" & dynadot_GetApiKey() & "&command=" & someCommand into restURL
   -- put AdvancedDynadotApiJsonStem & "?command=" & someCommand into restURL
   
   # Add params
   get the paramcount
   put (it - 1)/2 into maxPairNum
   repeat with pairNum = 1 to maxPairNum
      put (pairNum - 1)*2 + 2 into keyNum
      put param (keyNum) into keyName
      if keyName is empty then exit repeat
      
      put keyNum + 1 into valueNum
      put param (valueNum) into keyValue
      --
      put "&" & keyName & "=" & keyValue after restURL
   end repeat
   
   put dynadot_GetApiKey() into authToken
   -- put jsonrpc_GetArray (restURL, authToken)
   put jsonrpc_GET (restURL, authToken) into rJSON
   return rJSON
end dynadot_GetAdvancedJson

function dynadot_GetAdvancedXML someCommand, pKey, pValue
   put AdvancedDynadotApiStem & "?key=" & dynadot_GetApiKey() & "&command=" & someCommand into someUrl
   
   # Add params
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
   --
   if dynadot_CheckError (someXML) is not empty then
      breakpoint
      return empty
   end if
   return someXML
end dynadot_GetAdvancedXML

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


--> Dynadot | Rest | Authentication
-
function dynadot_GetApiKey   
   put secret_Get ("DynadotApiKey", "apiKey") into oAuthToken
   return oAuthToken 
end dynadot_GetApiKey

command dynadot_SetApiKey oAuthToken
   secret_Set "DynadotApiKey", oAuthToken, "apiKey"
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


--> Deps
-
-- function secret_Get secretName
   -- for server use only
   if the environment is not "server" then pass "secret_Get"
   --
   put rigFetchConfigItem (secretName) into someSecret
   return someSecret
end secret_Get


--> Private
-
private command _CheckApiError @responseArray, @errorText
   if responseArray is not an array then
      breakpoint
      return false
   end if
   --
   put responseArray ["Response"]["ResponseHeader"]["error"] into errorText
   if errorText is empty then
      return true
   else
      put empty into responseArray
      return false
   end if
end _CheckApiError

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
