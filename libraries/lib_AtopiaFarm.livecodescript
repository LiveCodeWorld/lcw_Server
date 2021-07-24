script "lib_AtopiaFarm"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_AtopiaFarm
type: library
version: 0.1

/*Some help*/


--> Working on
-


--> Atopia | Farm
-
function atopia_FetchFarmStatus domainName
   put atopia_FetchNameServerType (domainName) into nameServerType
   switch nameServerType
      case "dynadot"
         -- while the api is down
         put dynadot_FetchFarmStatus (domainName) into farmStatus
         return farmStatus
      case "digitalocean"
      default
         put digitalocean_FetchFarmStatus (domainName) into farmStatus
         return farmStatus
   end switch
end atopia_FetchFarmStatus

function atopia_FetchNameServerType domainName
   put dig_GetNS (domainName) into nameServers
   set the itemdelimiter to "."
   return item -2 of nameServers
end atopia_FetchNameServerType

command atopia_BurnFarmDomains wikiDomain
   put atopia_FetchSubDomainFolders (wikiDomain) into subDomainFolders
   put digitalOcean_FindDropletIP ("fedwiki.org") into someIP
   --
   put digitalocean_FetchArecordNames (wikiDomain) into oldNames
   repeat for each line oldName in oldNames
      set the cursor to busy
      digitalocean_DeleteArecord wikiDomain, oldName
   end repeat
   --
   put "@" into aNames
   digitalocean_CreateARecord wikiDomain, "@", someIP
   --
   set the itemdelimiter to "."
   repeat for each line subDomainFolder in subDomainFolders
      set the cursor to busy
      put item 1 to -3 of subDomainFolder into aName
      digitalocean_CreateARecord wikiDomain, aName, someIP
      put CR & aName after aNames
   end repeat
   return aNames
end atopia_BurnFarmDomains

command atopia_CreateFarm wikiDomain
   put digitalocean_FetchArecordNames (wikiDomain) into aRecordNames
   --
   put the number of lines of aRecordNames into maxNum
   repeat with lineNum = maxNum down to 1
      set the cursor to busy
      put line lineNum of aRecordNames into aName
      switch aName
         case "*" -- should not be
         case "@" -- should not be
            next repeat
         case wikiDomain
         default
            digitalocean_DeleteArecord wikiDomain, aName
            delete line lineNum of aRecordNames
      end switch 
   end repeat
   
   set the wholematches to true
   if aRecordNames contains "@" is false then
      digitalocean_CreateARecord wikiDomain, "@"
      put "@" & CR before aRecordNames
   end if
   if aRecordNames contains "*" is false then
      digitalocean_CreateARecord wikiDomain, "*"
      put "*" & CR before aRecordNames
   end if
   --
   return line 1 to -1 of aRecordNames
end atopia_CreateFarm

function atopia_FetchSubDomainFolders wikiDomain
   put atopia_FetchFolders() into subDomainNames
   put "*." & wikiDomain into someFilter
   filter subDomainNames with someFilter
   url_SortDomainIndex subDomainNames
   return subDomainNames
end atopia_FetchSubDomainFolders

function atopia_FetchOceanFarms
   -- put atopia_FetchFolders() into atopiaFolders
   put atopia_ListTopFolders() into atopiaFolders
   --
   repeat for each line domainName in atopiaFolders
      set the cursor to busy
      put digitalocean_FetchFarmStatus (domainName) into farmStatus
      if farmStatus is true then
         put domainName & CR after farmNames
      end if
   end repeat
   delete char -1 of farmNames
   return farmNames
end atopia_FetchOceanFarms


--> DigitalOcean | Farm
-
function digitalocean_FetchFarmStatus domainName
   put digitalocean_GetDomainArray (domainName) into domainArray
   put domainArray ["domain_records"] into recordArray
   repeat for each key indexNum in recordArray
      if recordArray [indexNum]["type"] = "A" and recordArray [indexNum]["name"] begins with "*." then
         return true
      end if
   end repeat
   return false
end digitalocean_FetchFarmStatus

function digitalOcean_FindServerFarms pDomainInfoArray
   local allDomainNames, serverFarms, notServerFarms
   digitalocean_SplitIntoFarms allDomainNames, serverFarms, notServerFarms, pDomainInfoArray
   return serverFarms
end digitalOcean_FindServerFarms

function digitalOcean_FindNotServerFarms pDomainInfoArray
   local allDomainNames, serverFarms, notServerFarms
   digitalocean_SplitIntoFarms allDomainNames, serverFarms, notServerFarms, pDomainInfoArray
   return notServerFarms
end digitalOcean_FindNotServerFarms

command digitalocean_SplitIntoFarms @allDomainNames, @serverFarms, @notServerFarms, pDomainInfoArray
   put digitalOcean_ListAllDomainNames (pDomainInfoArray) into allDomainNames
   set the itemdelimiter to "."
   repeat for each line someLine in allDomainNames
      if item 1 of someLine is "*" then
         put item 2 to -1 of someLine & CR after serverFarms
      else
         put someLine & CR after notServerFarms
      end if
   end repeat
   delete char -1 of serverFarms
   delete char -1 of notServerFarms
   
   set the wholematches to true
   put 1 into lineNum
   repeat for each line testNot in notServerFarms
      if testNot is among the lines of serverFarms then
         delete line lineNum of notServerFarms
      else
         add 1 to lineNum
      end if
   end repeat
end digitalocean_SplitIntoFarms
