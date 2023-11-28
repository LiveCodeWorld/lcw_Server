script "lib_Zeroconf"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Zeroconf
type: library
version: 0.1

/*
This library is for interfacing with zeroconf (bonjour) services.

We wrap the Livecode "mergBonjour" code, and explore related crossplatform solutions.
At the moment it only works on Macos (mobile and desktop).
*/


--> Variables
-
local LocalArray

constant ServerIP = 12345
constant ServerName = "Zerconf Server"


--> Working on
-
function zero_IsRunning
   get LocalArray ["bPointer"]
   return it is not empty
end zero_IsRunning

function zeroconf_IsSearching
   put LocalArray ["sPointer"] into sPointer
   return sPointer is not empty
end zeroconf_IsSearching


--> Zeroconf | Events
-
on mergBonjourServiceFound pType, pDomain, pName, pHostName, pIPs, pPort
   beep
   --
   zeroconf_Log pType, pDomain, pName, pHostName, pIPs, pPort
   put the result into zArray
   put zArray ["_http._tcp."] into zWebArray
   --
   display_Zeroconf
end mergBonjourServiceFound

on mergBonjourServiceRemoved pType, pDomain, pName, pHostName
   -- bug: pHostName is empty?
   beep
   --
   zeroconf_RemoveLog pType, pDomain, pName, pHostName
   put the result into zArray
   put zArray ["_http._tcp."] into zWebArray
   --
   display_Zeroconf
   --
   put the params
end mergBonjourServiceRemoved


--> Display
-
command display_Zeroconf
   put zeroconf_GetArray() into zArray
   put zArray ["_http._tcp."] into zWebArray
   --
   display_Data zWebArray, "Vaudeville", "Zeroconf"
   put the result into displayView
   set the title_Menu of displayView to "Global | Zeroconf | Menu"
   --
   return displayView
end display_Zeroconf


--> Zeroconf | Server
-
command zeroconf_StartServer pDescriptiveName
   put the hostname into sDomain
   put "local." into sDoman
   --
   mergBonjourRegisterService "_http._tcp.", ServerIP, sDoman, pDescriptiveName
   put the result into LocalArray ["bPointer"]
   --
   httpdStart "ZeroRequest", ServerIP, ServerName
   put it into LocalArray ["sPort"]
   put the result into sError
   --
   put "http://localhost:" & LocalArray ["sPort"] into localURL
   launch url localURL
end zeroconf_StartServer

command zeroconf_StopServer
   httpdStop
   --
   put LocalArray ["bPointer"] into bPointer
   if bPointer is not empty then
      mergBonjourStopService bPointer
   end if
end zeroconf_StopServer

on ZeroRequest pSocketID, pRequest
   put "OK" && the ticks && the params && the keys of pRequest ["parameters"] into postResult
   httpdResponse pSocketID, 200, postResult
end ZeroRequest


--> Zeroconf | Search
-
command zeroconf_StartSearch
   put LocalArray ["sPointer"] into sPointer
   if sPointer is empty then
      put mergBonjourSearch ("_http._tcp.") into sPointer
      put sPointer into LocalArray ["sPointer"]
   end if
end zeroconf_StartSearch

command zeroconf_StopSearch
   put LocalArray ["sPointer"] into sPointer
   if sPointer is not empty then
      mergBonjourStopSearch sPointer
      --
      put empty into LocalArray ["sPointer"]
      delete variable LocalArray ["zeroconf"]
      --
      display_Zeroconf
   end if
end zeroconf_StopSearch


--> Zeroconf | Model
-
function zeroconf_GetArray
   put LocalArray ["zeroconf"] into zArray
   return zArray
end zeroconf_GetArray

command zeroconf_SetArray zArray
   put zArray into LocalArray ["zeroconf"]
end zeroconf_SetArray


--> Zeroconf | Log
-
command zeroconf_Log pType, pDomain, pName, pHostName, pIPs, pPort
   put zeroconf_GetArray() into zArray
   --
   put pIPs into zArray [pType][pHostName][pName]["ip"]
   put pPort into zArray [pType][pHostName][pName]["port"]
   put pDomain into zArray [pType][pHostName][pName]["domain"]
   --
   zeroconf_SetArray zArray
   --
   return zArray
end zeroconf_Log

command zeroconf_RemoveLog pType, pDomain, pName, pHostName
   put zeroconf_GetArray() into zArray
   --
   delete variable zArray [pType][pHostName][pName]["ip"]
   delete variable zArray [pType][pHostName][pName]["port"]
   --
   zeroconf_SetArray zArray
   --
   return zArray
end zeroconf_RemoveLog


--> Bonjour
-
command bonjour_CreateAlias someName
   -- not easy to script (needs some magic)
   -- probably better to script a nameserver?
   -- put shell ("dns-sd -P Livewiki _http._tcp local 8081 livewiki.local david.local path=/ &")
   return empty
   
   if pPath is empty then put "/" into pPath
   put tolower (someName) into someName
   put someName & ".local" into newLocalDomain
   put someName into BonjourName
   put toUpper (char 1 of BonjourName) into BonjourName
   put "dns-sd -P [[BonjourName]] _http._tcp local 3000 [[newLocalDomain]] david.local path=[[pPath]]" into someShell
end bonjour_CreateAlias

command bonjour_RegisterPortMapper pMapperPort
   put merge ("dns-sd -R 'LiveCode Port Mapper' _livecode._udp. . [[pMapperPort]] pdl=application/livecode") into someShell
   shell_ExecuteInBackground someShell
   put the result into shellResult
   return shellResult
end bonjour_RegisterPortMapper


--> Deps
-
function getLANIP
   -- not used but possibly useful ideas
   local retVal,tCard,ifConfigs,winExists,sys32Exists,temp
   set the itemDel to "."
   switch (the platform)
      case "MacOS"
         if item 1 of the systemVersion <10 then
            return ""
         else
            -- OS X
            repeat with X=1 to 10
               put "en"&X into tCard
               put shell("ifconfig "&tCard) into ifConfigs
               if char 1 to 9 of ifConfigs = "ifconfigs:" then
                  exit repeat
               else if char 1 to 4 of ifConfigs = "zsh:" then
                  return ""
               else
                  get matchText(ifconfigs,"(?s)inet (.*?) ",retVal) -- These are spaces on either side of (.*?)
                  if it is false then
                     return ""
                  else
                     exit repeat
                  end if
               end if
            end repeat
         end if
         break
      case "Win32"
         -- All Windows
         put (there is a file (specialFolderPath("system") & "/IPCONFIG.EXE")) into winExists
         put (there is a file (specialFolderPath("system") & "/SYSTEM32/IPCONFIG.EXE")) into sys32Exists
         if winExists or sys32Exists then
            set the hideConsoleWindows to true
            put shell("ipconfig /all") into temp
            if word 2 of systemVersion() < 6 then
               get matchText(temp,"IP Address[\. ]*: ([A-Z0-9-.]*)",retVal)
            else
               get matchText(temp,"IPv4 Address[\. ]*: ([A-Z0-9-.]*)",retVal)
            end if
         else
            return ""
         end if
         break
   end switch
   return retVal
end getLANIP
