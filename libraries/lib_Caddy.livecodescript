script "lib_Caddy"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Caddy
type: library
version: 0.1

/*
{
"apps": {
"http": {
"servers": {
"example": {
"listen": [
":2015"
],
"routes": [
{
"handle": [
{
"handler": "static_response",
"body": "Hello, world!"
*/


--> Working on
-


--> Display
-
command display_CaddyAdmin
   display_Browser "http://localhost:2019/config/"
end display_CaddyAdmin

command display_CaddyTools
   -- put caddy_ConstructArray() into cArray
   put caddy_FetchConfig() into cArray
   display_Tool cArray, "Admin", "Caddy", "lib_Caddy"
   put the result into dView
   return dView
end display_CaddyTools


--> Working on
-
command caddy_ToggleProxy
   if caddy_IsRunning() then
      caddy_Stop
      put the result into pIDs
      --
      lcw_Notify ("Stopped Caddy servers." && pIDs)
      return empty
   else
      caddy_Start
      put the result into pID
      --
      lcw_Notify ("Started Caddy server on process" && pID)
      return pID
   end if
end caddy_ToggleProxy


--> Caddy | Rest
-
command caddy_Post
   -- curl localhost:2019/load -H "Content-Type: application/json" -d @caddy.json
   put caddy_ConstructJson() into sJSON
   --
   put "localhost:2019/load" into restUrl
   put caddy_RestUrl ("load") into restUrl
   --
   put jsonrpc_POST (sJSON, restUrl) into sResult
   --
   put url "localhost:2015" into sTest
   display_CaddyAdmin
   return sTest
end caddy_Post


--> CaddyRouteArray
-
function caddyRouteArray_Construct wikiDomain, toDomainPort
   put "subroute" into routeArray ["handle"][1]["handler"]
   --
   put "reverse_proxy" into routeArray ["handle"][1]["routes"][1]["handle"][1]["handler"]
   
   put toDomainPort into routeArray ["handle"][1]["routes"][1]["handle"][1]["upstreams"][1]["dial"]
   --
   put true into routeArray ["terminal"]
   --
   put ("*." & wikiDomain) into routeArray ["match"][1]["host"][1]
   put wikiDomain into routeArray ["match"][1]["host"][2]
   --
   return routeArray
end caddyRouteArray_Construct

function caddyRouteArray_Hosts routeArray
   put routeArray ["match"][1][host] into hostArray
   combine hostArray by row
   --
   repeat for each line sLine in hostArray
      if char 1 to 2 of sLine = "*." then next repeat
      --
      put sLine & CR after sDomains
   end repeat
   delete char -1 of sDomains
   return sDomains
end caddyRouteArray_Hosts


--> Caddy
-
function caddy_FetchConfig
   put caddy_FetchConfigJson() into cJSON
   put json_ToArray (cJSON) into configArray
   return configArray
end caddy_FetchConfig

function caddy_FetchConfigJson
   put caddy_RestUrl ("config") into restUrl
   put url restUrl into cJSON
   return cJSON
end caddy_FetchConfigJson

command caddy_TestSetBody sBody
   -- caddy_TestSetBody "Work smarter, not harder."
   put caddy_ConstructCurl (sBody) into sShell
   put shell (sShell) into sResult
   
   /*
   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
   Dload  Upload   Total   Spent    Left  Speed
   
   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
   100   106  100    79  100    27   5240   1790 --:--:-- --:--:-- --:--:--  7066
   {"error":"invalid traversal path at: config/apps/http/servers/example/routes"}
   */
   put line 1 to 3 of sResult into sHeader
   delete line 1 to 3 of sResult
   return sResult
end caddy_TestSetBody

function caddy_ConstructCurl sBody
   put "curl" && "localhost:2019/config/apps/http/servers/srv0/routes/0/handle/0/body" into sShell
   -- put "curl" && "localhost:2019/config/apps/http/servers/example/routes/0/handle/body" into sShell
   
   put space & "-H 'Content-Type: application/json'" after sShell
   put space & "-d '" & kwote (sBody) & "'" after sShell
   --
   return sShell
end caddy_ConstructCurl

function caddy_ConfigUrl
   -- "http://localhost:2019/config/"
   return caddy_RestUrl ("config")
end caddy_ConfigUrl

function caddy_RestUrl pPath
   put "http://" into pBit
   put pBit & "localhost:2019" into restUrl
   if pPath is not empty then
      put slash & pPath & slash after restUrl
   end if
   return restUrl
end caddy_RestUrl

function caddy_ConstructJson
   put caddy_ConstructArray() into cArray
   -- put JsonExport (cArray) into cJSON -- problem with numbers
   put json_FromArray (cArray, false, true) into cJSON
   return cJSON
end caddy_ConstructJson

function caddy_ConstructArray
   get {"apps": {"http": {"servers": {"example": {"listen": [":2015"],"routes": [{"handle": {"handler": "static_response","body": "Hello, world!"}}]}}}}}
   -- display_Data it, "Test Array"
   return it
end caddy_ConstructArray


--> Caddy
-
function caddy_Version
   return caddy_DoShell ("caddy version")
end caddy_Version

command caddy_Adapt
   put caddy_DoShell ("caddy adapt") into sResult
   return sResult
end caddy_Adapt

function caddy_IsRunning
   put caddy_ListProcessIds() into pIDs
   return pIDs is not empty
end caddy_IsRunning

function caddy_ListProcessIds
   put ps_Grep ("caddy") into pids
   return pids
end caddy_ListProcessIds

command caddy_Run
   put caddy_DoShell ("caddy run") into sResult
   return sResult
end caddy_Run

command caddy_Start pLog
   if caddy_IsRunning() is true then
      put "Error, Caaddy is already runing!" into sWarning
      lcw_Notify sWarning
      return sWarning
   end if
   
   put "caddy start" into someShell
   --
   shell_WrapNohup someShell, pLog
   shell_AddSource someShell
   
   # Start in wiki assets folder to use local Caddyfile
   put caddy_DoShell (someShell) into sResult
   put word 2 of sResult into pID
   --
   lcw_Notify "Started Caddy reverse-proxy using local wiki Caddyfile!"
   return pID
end caddy_Start

command caddy_Stop
   caddy_CloseServerProcesses
   return empty
   
   put caddy_ListProcessIds() into pIDs
   switch the number of items of pIDs
      case 0
         return empty
      case 1
         put caddy_DoShell ("caddy stop") into sResult -- hangs sometimes
         if sResult is not empty then
            breakpoint
         end if
         break
      default
         caddy_CloseServerProcesses pIDs
   end switch
   return pIDs
end caddy_Stop

command caddy_CloseServerProcesses pIDs
   if pIDs is not a number then
      put caddy_ListProcessIds() into pIDs
   end if
   --
   repeat for each item pID in pIDs
      kill process pID -- bug: does not kill?
   end repeat
   
   # Notify
   put "Closed caddy server!" && pIDs into sComment
   --
   lcw_Notify sComment, "Caddy Server"
end caddy_CloseServerProcesses

function caddy_DoShell someShell
   put caddyAsset_Folder() into cAssetFolder
   put the defaultFolder into oFolder
   set the defaultFolder to cAssetFolder
   --
   put shell (someShell) into sResult
   --
   set the defaultFolder to oFolder
   return sResult
end caddy_DoShell

function caddyAsset_Get pShortFile
   put caddyAsset_ConstructFile (pShortFile) into caddyAssetFile
   put text_Get (caddyAssetFile) into sText
   return sText
end caddyAsset_Get

command caddyAsset_Set pShortFile, sText
   put caddyAsset_ConstructFile (pShortFile) into caddyAssetFile
   text_Set caddyAssetFile, sText
   return caddyAssetFile
end caddyAsset_Set

function caddyAsset_ConstructFile pShortFile
   if pShortFile is empty then put "CaddyFile" into pShortFile
   put caddyAsset_Folder() & pShortFile into caddyAssetFile
   return caddyAssetFile
end caddyAsset_ConstructFile

function caddyAsset_Folder
   put wikiFolder_ConstructAssets ("server.livecode.world") into assetsFolder
   put assetsFolder & "caddy/" into caddyAssetsFolder
   return caddyAssetsFolder
end caddyAsset_Folder
