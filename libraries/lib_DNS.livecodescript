script "lib_DNS"
--> MetaData
-
license: GPLv3
name: lib_DNS
type: library
version: 0.8


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


--> DNS
-
function dns_ConstructZoneFileArray zoneText
   local zoneFileArray, dnsDictionary
   dns_ConstructZoneInfoArray zoneText, zoneFileArray, dnsDictionary
   return zoneFileArray
end dns_ConstructZoneFileArray

command dns_ConstructZoneInfoArray zoneText, @zoneFileArray, @dnsDictionary
   put word -1 of (char 1 to -2 of line 1 of zoneText) into originDomain
   -- put originDomain into zoneFileArray["name"]
   -- put word -1 of line 2 of zoneText into zoneFileArray["ttl"]
   
   delete line 1 to 3 of zoneText  -- no idea what line 3 is for
   put 1 into recordNum
   set the itemdelimiter to "."
   repeat for each line someLine in zoneText
      put word 4 of someLine into someType
      put word -1 of someLine into someData
      if char -1 of someData = "." then delete char -1 of someData
      
      put char 1 to -2 of word 1 of someLine into subDomain
      if subDomain = originDomain then
         put "@" into domainStem
      else
         put item 1 to -2 of subDomain into domainStem
      end if
      
      switch someType
         case "NS"
            break
         case "A"
            put someData into dnsDictionary [subDomain]
            break
         default
      end switch
      
      put domainStem into zoneFileArray [recordNum]["name"]
      put someData into zoneFileArray [recordNum]["data"]
      put someType into zoneFileArray [recordNum]["type"]
      
      add 1 to recordNum
   end repeat
   set the itemdelimiter to empty
end dns_ConstructZoneInfoArray

function dns_HostNameServers whichList
   switch whichList
      case "Godaddy"
         return "NS67.DOMAINCONTROL.COM,NS68.DOMAINCONTROL.COM"
      case "Digital Ocean"
         return "ns1.digitalocean.com,ns2.digitalocean.com,ns3.digitalocean.com"
      case "Dream Host"
         return "ns1.dreamhost.com,ns2.dreamhost.com,ns3.dreamhost.com"
      default -- "Digital Ocean"
         return "ns1.digitalocean.com,ns2.digitalocean.com,ns3.digitalocean.com"
   end switch
end dns_HostNameServers
