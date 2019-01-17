script "model_DigitalOcean"
--> MetaData
-
license: GPLv3
name: model_DigitalOcean
type: model
version: 0.2

/*
This library fetches and caches arrays associated with Digital Ocean Droplets and associated domains.

function digitalOcean_GetIndexedActionArray
   -- put the digitalOcean_IndexedActionArray of me into indexedActionArray
   put the model_Array ["ocean_IndexedActionArray.array"] of me into indexedActionArray
   return indexedActionArray
end digitalOcean_GetIndexedActionArray

command digitalOcean_SetIndexedActionArray indexedActionArray
   set the model_Array ["ocean_IndexedActionArray.array"] of me to indexedActionArray
end digitalOcean_SetIndexedActionArray
*/


--> DigitalOcean | Model | Update
-
command digitalocean_UpdateDropletInfoArray
   put digitalocean_FetchDropletInfoArray() into dropletInfoArray
   if dropletInfoArray is false then return empty 
   if dropletInfoArray ["id"] = "unauthorized" then return empty -- error checking
   
   digitalOcean_SetDropletInfoArray dropletInfoArray
   return dropletInfoArray
end digitalocean_UpdateDropletInfoArray

command digitalocean_UpdateDomainInfoArray
   put digitalocean_FetchDomainInfoArray() into domainInfoArray
   if domainInfoArray is false then return empty 
   digitalocean_SetDomainInfoArray domainInfoArray
   return domainInfoArray
end digitalocean_UpdateDomainInfoArray


--> DigitalOcean | Model
-
function digitalOcean_GetDropletInfoArray
   put the model_Array ["ocean_DropletInfo.array"] of me into dropletInfoArray
   return dropletInfoArray
end digitalOcean_GetDropletInfoArray

command digitalOcean_SetDropletInfoArray dropletInfoArray
   set the model_Array ["ocean_DropletInfo.array"] of me to dropletInfoArray
end digitalOcean_SetDropletInfoArray

function digitalocean_GetDomainInfoArray
   put the model_Array ["ocean_DomainInfo.array"] of me into domainInfoArray
   return domainInfoArray
end digitalocean_GetDomainInfoArray

command digitalocean_SetDomainInfoArray domainInfoArray
   set the model_Array ["ocean_DomainInfo.array"] of me to domainInfoArray
end digitalocean_SetDomainInfoArray


--> DigitalOcean | Model | Droplet | IP
-
function digitalOcean_GetDropletIP dropletName, pIndexedDropletArray
   if pIndexedDropletArray is not an array then
      put digitalOcean_GetDropletInfoArray() into pIndexedDropletArray
   end if
   put pIndexedDropletArray ["droplets"] into indexedArray
   repeat for each key dropletNum in indexedArray
      put indexedArray [dropletNum]["name"] into testDropletName
      if testDropletName = dropletName then
         -- what would you do if there was more than one entry ???
         put indexedArray [dropletNum]["networks"]["v4"][1]["ip_address"] into ipAddress
         return ipAddress
      end if
   end repeat
   return empty
end digitalOcean_GetDropletIP

function digitalocean_ExtractIpAddessFrom domainArray
   put domainArray ["domain_records"] into domainRecordsArray
   repeat for each key recordNum in domainRecordsArray
      put domainRecordsArray [recordNum]["type"] into recordType
      put domainRecordsArray [recordNum]["name"] into recordName
      if recordType = "A" and recordName = "@" then
         put domainRecordsArray [recordNum]["data"] into someIP
         return someIP
      end if
   end repeat
   return empty
end digitalocean_ExtractIpAddessFrom

function digitalocean_TranslateIP someIP, pDropletInfoArray
   put digitalocean_ConstructDropletDictionary (pDropletInfoArray) into dropletDictionary
   digitalocean_DeconstructDropletDictionary dropletDictionary, nameDictionary, ipDictionary
   put ipDictionary [someIP] into dropletName
   return dropletName
end digitalocean_TranslateIP


--> DigitalOcean | Model | Droplet
-
function digitalOcean_GetDropletNames pDropletInfoArray
   if pDropletInfoArray is not an array then
      put digitalOcean_GetDropletInfoArray () into pDropletInfoArray
   end if
   put digitalocean_ConstructDropletDictionary (pDropletInfoArray) into dropletDictionary
   
   digitalocean_DeconstructDropletDictionary dropletDictionary, nameDictionary, ipDictionary
   put keys (nameDictionary) into dropletNames
   sort dropletNames
   return dropletNames
end digitalOcean_GetDropletNames

command digitalocean_DeconstructDropletDictionary dropletDictionary, @nameDictionary, @ipDictionary
   put dropletDictionary ["name"] into nameDictionary
   put dropletDictionary ["ip_address"] into ipDictionary
end digitalocean_DeconstructDropletDictionary

function digitalocean_ConstructDropletDictionary pIndexedDropletArray
   if pIndexedDropletArray is not an array then
      put digitalOcean_GetDropletInfoArray() into pIndexedDropletArray
   end if
   put pIndexedDropletArray ["droplets"] into indexedArray
   repeat for each key dropletNum in indexedArray
      put indexedArray [dropletNum]["name"] into dropletName
      -- what if it's more than 1 network???
      put indexedArray [dropletNum]["networks"]["v4"][1]["ip_address"] into ipAddress
      put ipAddress into nameDictionary [dropletName]
      put dropletName into ipDictionary [ipAddress]
   end repeat
   put nameDictionary into dropletDictionary ["name"]
   put ipDictionary into dropletDictionary ["ip_address"]
   return dropletDictionary
end digitalocean_ConstructDropletDictionary


--> DigitalOcean | Model | Wrappers
-
function digitalocean_GetIndexedDomainArray 
   put digitalocean_GetDomainInfoArray() into domainInfoArray
   put domainInfoArray ["domains"] into indexedDomainArray
   return indexedDomainArray
end digitalocean_GetIndexedDomainArray

function digitalocean_GetDomainArray oceanDomainName, pDomainInfoArray
   put digitalocean_GetDomainNameArray (pDomainInfoArray) into oceanDomainNameArray
   put oceanDomainNameArray [oceanDomainName] into domainArray
   return domainArray
end digitalocean_GetDomainArray

function digitalocean_GetDomainNames
   put digitalocean_GetDomainNameArray() into oceanDomainNameArray
   put keys (oceanDomainnameArray) into oceanDomainNames
   url_SortDomainIndex oceanDomainNames   
   return oceanDomainNames
end digitalocean_GetDomainNames

function digitalOcean_FindDropletIP oceanDomainName, pDomainInfoArray
   -- could be smart with "*"
   -- for now it is just a match
   local domainNameArray, dnsDictionary
   
   if pDomainInfoArray is not an array then
      put digitalocean_GetDomainInfoArray() into pDomainInfoArray
   end if
   digitalocean_ConstructNameArrays pDomainInfoArray, domainNameArray, dnsDictionary
   put dnsDictionary [oceanDomainName] into someIP
   return someIP
end digitalOcean_FindDropletIP

function digitalOcean_GetDnsDictionary pDomainInfoArray
   local domainNameArray, dnsDictionary
   if pDomainInfoArray is not an array then put digitalocean_GetDomainInfoArray() into pDomainInfoArray
   digitalocean_ConstructNameArrays pDomainInfoArray, domainNameArray, dnsDictionary
   return dnsDictionary
end digitalOcean_GetDnsDictionary

function digitalOcean_ListTopLevelDomains pDomainInfoArray
   put digitalOcean_GetDnsDictionary (pDomainInfoArray) into dnsDictionary
   put keys (dnsDictionary) into allDomainNames
   set the itemdelimiter to "."
   repeat for each key domainName in dnsDictionary
      if the number of items of domainName = 2 then
         put dnsDictionary [domainName] into topDomainDictionary [domainName]
      end if
   end repeat
   put keys (topDomainDictionary) into topDomains
   url_SortDomainIndex topDomains   
   return topDomains
end digitalOcean_ListTopLevelDomains

function digitalOcean_ListAllDomainNames pDomainInfoArray
   put digitalOcean_GetDnsDictionary (pDomainInfoArray) into dnsDictionary
   put keys (dnsDictionary) into allDomainNames
   url_SortDomainIndex allDomainNames
   return allDomainNames
end digitalOcean_ListAllDomainNames

function digitalocean_GetDomainNameArray pDomainInfoArray
   if pDomainInfoArray is not an array then
      put digitalocean_GetDomainInfoArray() into pDomainInfoArray
   end if
   put digitalocean_ConstructDomainNameArray (pDomainInfoArray) into oceanDomainNameArray
   return oceanDomainNameArray
end digitalocean_GetDomainNameArray

function digitalocean_ConstructDomainNameArray domainInfoArray
   local domainNameArray, dnsDictionary
   digitalocean_ConstructNameArrays domainInfoArray, domainNameArray, dnsDictionary
   return domainNameArray
end digitalocean_ConstructDomainNameArray

command digitalocean_ConstructNameArrays domainInfoArray, @domainNameArray, @dnsDictionary
   local zoneFileArray
   
   put domainInfoArray ["domains"] into domainArray
   repeat for each key domainNum in domainArray
      put domainArray [domainNum]["name"] into domainName
      put domainName into domainNameArray [domainName]["name"]
      put domainArray [domainNum]["ttl"] into domainNameArray [domainName]["ttl"]
      put word 1 to -1 of domainArray [domainNum]["zone_file"] into zoneText
      put zoneText into domainNameArray [domainName]["zone_file"]
      
      -- put dns_ConstructZoneFileArray (zoneText) into zoneFileArray
      dns_ConstructZoneInfoArray zoneText, zoneFileArray, dnsDictionary
      put zoneFileArray into domainNameArray [domainName]["domain_records"]
      put empty into zoneFileArray
   end repeat
end digitalocean_ConstructNameArrays

function digitalOcean_GetDropletArray dropletName
   put digitalOcean_GetDropletInfoArray() into dropletInfoArray
   put dropletInfoArray ["droplets"] into indexedDropletArray
   repeat for each key dropletNum in indexedDropletArray
      put indexedDropletArray [dropletNum] into dropletArray
      put dropletArray ["name"] into testDropletName
      if testDropletName = dropletName then
         return dropletArray
      end if
   end repeat
   return empty
end digitalOcean_GetDropletArray
