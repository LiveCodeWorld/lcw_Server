script "lib_Zeroconf"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_Zeroconf
type: library
version: 0.1

/*
This library is for interfacig with zeroconf (bonjour) services.

We wrap the Livecode "mergBonjour" code, and explore related crossplatform solutions.
At the moment it only works on Macos (mobile and desktop).
*/


--> Working on
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

function zero_IsRunning
   return  true
end zero_IsRunning

command zero_StartServer sName
   put the hostname into sDomain
   --
   mergBonjourRegisterService "_http._tcp.", 12345, sDoman, sName
   put the result into LocalArray ["bPointer"]
   --
   httpdStart "ZeroRequest", 12345, "My Server"
   --
   put it into LocalArray ["sPort"]
   put the result into sError
   --
   put "http://localhost:" & LocalArray ["sPort"] into localURL
   launch url localURL
end zero_StartServer

command zero_StopServer
   httpdStop
   --
   put LocalArray ["bPointer"] into bPointer
   if bPointer is not empty then
      mergBonjourStopService bPointer
   end if
end zero_StopServer

on ZeroRequest pSocketID, pRequest
   put "OK" && the ticks && the params && the keys of pRequest ["parameters"] into postResult
   httpdResponse pSocketID, 200, postResult
end ZeroRequest


--> Variables
-
local LocalArray


--> Zeroconf
-
function zeroconf_GetArray
   put LocalArray ["zeroconf"] into zArray
   return zArray
end zeroconf_GetArray

command zeroconf_SetArray zArray
   put zArray into LocalArray ["zeroconf"]
end zeroconf_SetArray

function zeroconf_IsSearching
   put LocalArray ["sPointer"] into sPointer
   return sPointer is not empty
end zeroconf_IsSearching

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
   --
   put "http://vaudeville.local:12345" into someUrl
   -- post the params to url someUrl
   put it
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
