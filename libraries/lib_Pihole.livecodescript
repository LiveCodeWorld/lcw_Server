script "lib_Pihole"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Pihole
type: library
version: 0.1

/*
This library if for interfacing with the Pihole api.

-- from https://www.postman.com/irsheep/public/documentation/y1245ch/pi-hole
*/

--> Variables
-
constant RestRoot = "http://pi.hole/admin/api.php?"
local API_TOKEN = "f3c7b8b0048521c6ca982e3bcdceb475b5375b55f0492313bb1628328a652832"


--> Working on
-

--> Pihole
-
function pihole_Version
   put pihole_RestUrl("version") into restURL
   put url restURL into jsonResult -- {"version":3}
   --
   put _LazyArray(jsonResult) into resultArray
   put resultArray ["version"] into versionNum
   --
   return versionNum
end pihole_Version

function pihole_DomainToPiName domainName
   -- by convention we add localHostNames to pihole
   
   # First see if domainName is mapped tld domain
   put pihole_TldArray() into tldArray
   put tldArray [domainName] into localHostName
   if localHostName is not empty then return localHostName
   
   # Otherwise check subdomains
   put pihole_SubdomainToLocal (domainName) into localHostName
   return localHostName
end pihole_DomainToPiName

function pihole_SubdomainToLocal domainName
   -- could be another tldDomain
   -- but by convention we add localHostNames such as pi5.local
   put pihole_CNAMEArray() into rArray
   put rArray ["data"] into indexArray
   get indexArray_FindArray (indexArray, 1, domainName)
   put it [2] into mappedDomain
   return mappedDomain
end pihole_SubdomainToLocal

function pihole_AddressToName ipAddress
   put pihole_AddressToLocalName (ipAddress) into localName
   --
   set the itemdelimiter to "."
   return item 1 of localName
end pihole_AddressToName

function pihole_AddressToLocalName ipAddress
   put pihole_AddressArray() into piAddressArray
   put piAddressArray [ipAddress] into localHostName
   return localHostName
end pihole_AddressToLocalName

function pihole_CustomDomainIpAddress domainName
   put pihole_CustomDnsArray() into rArray
   put rArray ["data"] into indexArray
   get indexArray_FindArray (indexArray, 1, domainName)
   put it [2] into ipAddress
   return ipAddress
end pihole_CustomDomainIpAddress


--> Pihole | List
-
function pihole_ListNames
   put pihole_ListLocalNames() into piNames
   replace ".local" with empty in piNames
   return piNames -- "pi4,pi5"
end pihole_ListNames

function pihole_ListLocalNames
   put pihole_LocalHostArray() into nameArray
   put keys (nameArray) into localHostNames
   sort localHostNames
   return localHostNames
end pihole_ListLocalNames

function pihole_ListLocalHostNames
   put pihole_LocalData() into piholeLocalData
end pihole_ListLocalHostNames

function pihole_ListCNAMEs
   get pihole_CNAMEArray()
   put it ["data"] into indexArray
   put indexArray_List(indexArray, 1) into cnames
   return cnames
end pihole_ListCNAMEs

function pihole_ListForwardDestinations
   put pihole_RestUrl ("getForwardDestinations=10", true) into restURL
   put url restURL into jsonResult
   return jsonResult
end pihole_ListForwardDestinations

function pihole_ListCustomDomains
   put pihole_CustomDnsArray() into rArray
   put rArray ["data"] into indexArray
   put indexArray_List(indexArray, 1) into domainNames
   return domainNames
end pihole_ListCustomDomains


--> Pihole | Data
-
function pihole_TldArray
   put pihole_LocalData() into piLocalData
   put piLocalData ["domainArray"] into tldArray
   return tldArray
end pihole_TldArray

function pihole_LocalHostArray
   put pihole_LocalData() into piLocalData
   put piLocalData ["nameArray"] into domainNameArray
   return domainNameArray
end pihole_LocalHostArray

function pihole_AddressArray
   put pihole_LocalData() into piLocalData
   put piLocalData ["ipArray"] into piAddressArray
   return piAddressArray
end pihole_AddressArray

function pihole_LocalData
   put pihole_FetchData() into pData
   set the itemdelimiter to "."
   repeat for each key indexNum in pData
      put pData [indexNum][1] into sDomain
      put pData [indexNum][2] into sIP
      --
      if item -1 of sDomain = "local" then
         put sIP into piNameArray [sDomain]
         put sDomain into piAddressArray [sIP]
      else
         put sIP into domainArray [sDomain]
      end if
   end repeat
   
   # Rename domainArray
   repeat for each key sDomain in domainArray
      put domainArray [sDomain] into sIP
      put piAddressArray [sIP] into piLocal
      if piLocal is not empty then
         put piLocal into domainArray [sDomain]
      else
         breakpoint
      end if
   end repeat
   
   put piAddressArray into piLocalData ["ipArray"]
   put piNameArray into piLocalData ["nameArray"]
   put domainArray into piLocalData ["domainArray"]
   return piLocalData
end pihole_LocalData

function pihole_FetchData
   put pihole_CustomDnsArray() into rArray
   put rArray ["data"] into indexArray
   return indexArray
end pihole_FetchData

function pihole_CNAMEArray
   -- http://pihole.lan/admin/api.php?auth=deadbeef&customcname=1&action=get
   
   put "customcname=1&action=get" into restBit
   put pihole_RestUrl (restBit, true) into restURL
   put url restURL into rJSON
   put json_ToArray (rJSON) into rArray
   return rArray
end pihole_CNAMEArray

function pihole_CustomDnsArray
   put pihole_RestUrl ("customdns=1&action=get", true) into restURL
   put url restURL into rJSON
   put json_ToArray (rJSON) into rArray
   return rArray
end pihole_CustomDnsArray


--> Pihole | Subdomains
-
command pihole_AddSubDomains topWikiDomain, pSubdomains
   if pSubdomains is empty then
      put wikiDomain_SubList (topWikiDomain) into pSubdomains
   end if
   put pihole_ListCNAMEs() into piHoleCNAMEs
   
   set the wholematches to true
   repeat for each line subDomainName in pSubdomains
      set the cursor to busy
      if subDomainName is not among the lines of piHoleCNAMEs then
         put subDomainName & comma after subDomainList
      else
         breakpoint
      end if
   end repeat
   delete char -1 of subDomainList
   
   pihole_AddCustomSubDomain subDomainList, topWikiDomain
   --
   return subDomainList
end pihole_AddSubDomains

command pihole_AddCustomSubDomain subDomainName, targetDomainName
   -- http://pihole.lan/admin/api.php?auth=deadbeef&customcname=1&action=add&domain=&target=&reload=true
   
   put false into reloadBoolean
   
   put "customcname=1&action=add" into restBit
   --
   put "&domain=" & urlencode (subDomainName) after restBit
   put "&target=" & urlencode (targetDomainName) after restBit
   put "&reload=" & reloadBoolean after restBit
   
   put pihole_RestUrl (restBit, true) into restURL
   put url restURL into rJSON
   put json_ToArray (rJSON) into rArray
   return rArray ["message"]
end pihole_AddCustomSubDomain

command pihole_DeleteCustomSubDomain domainName, ipAddress
   put "customcname=1&action=delete" into restBit
   --
   put "&domain=" & urlencode (domainName) after restBit
   put "&ip=" & urlencode (ipAddress) after restBit
   --
   put pihole_RestUrl (restBit, true) into restURL
   put url restURL into rJSON
   put json_ToArray (rJSON) into rArray
   return rArray ["message"]
end pihole_DeleteCustomSubDomain


--> Pihole | Domain
-
command pihole_AddDomaintoNamedPi domainName, piName
   put piName & ".local" into localName
   put hostNameToAddress (localName) into localIP
   --
   if localIP is empty then
      breakpoint
      return "Error, cannot locate" && localName
   end if
   
   pihole_AddCustomDomain domainName, localIP
   --
   display_PiholeTools dView
   return the result
end pihole_AddDomaintoNamedPi

command pihole_AddCustomDomain domainName, ipAddress
   -- http://pihole.lan/admin/api.php?auth=deadbeef&customdns=1&action=add&ip&domain&reload=false
   
   -- ipAddress = IP address
   -- domainName = Single or CSV list of domains to add
   -- reload = restart FTL after adding the record
   put false into reloadBoolean
   
   put "customdns=1&action=add" into restBit
   --
   put "&domain=" & urlencode (domainName) after restBit
   put "&ip=" & urlencode (ipAddress) after restBit
   put "&reload=" & reloadBoolean after restBit
   
   put pihole_RestUrl (restBit, true) into restURL
   put url restURL into rJSON
   put json_ToArray (rJSON) into rArray
   return rArray ["message"]
end pihole_AddCustomDomain

command pihole_DeleteCustomDomain domainName, ipAddress
   -- http://pihole.lan/admin/api.php?auth=deadbeef&customdns=1&action=delete&ip&domain
   
   put "customdns=1&action=delete" into restBit
   --
   put "&domain=" & urlencode (domainName) after restBit
   put "&ip=" & urlencode (ipAddress) after restBit
   --
   put pihole_RestUrl (restBit, true) into restURL
   put url restURL into rJSON
   put json_ToArray (rJSON) into rArray
   return rArray ["message"]
end pihole_DeleteCustomDomain


--> Pihole | REST
-
function pihole_RestUrl restStem, pAddAuth
   put RestRoot & restStem into restURL
   if pAddAuth is true then
      put "&auth=" & API_TOKEN after restURL
   end if
   return restURL
end pihole_RestUrl


--> Deps
-
private function _LazyArray jsonResult
   get char 2 to -2 of jsonResult
   replace quote with empty in it
   split it using CR and ":"
   return it
end _LazyArray
