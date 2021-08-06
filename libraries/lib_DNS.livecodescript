script "lib_DNS"
--> MetaData
-
license: GPLv3
name: lib_DNS
type: library
version: 0.8


--> Dig
-
function dig_GetNS someDomain
   -- dig fedwiki.org NS +noall +answer +short
   put url_GetTLD (someDomain) into someDomain
   put merge ("dig [[someDomain]] NS +noall +answer +short") into someShell
   put shell (someShell) into nameServers
   return word 1 to -1 of nameServers
end dig_GetNS

function url_GetTLD someDomain
   set the itemdelimiter to "."
   put item -2 to -1 of someDomain into topLevelDomain
   return topLevelDomain
end url_GetTLD

function dig_GetIP someDomain
   put merge ("dig [[someDomain]] +short") into someShell
   put shell (someShell) into someIP
   return word 1 to -1 of someIP
end dig_GetIP

function dig_GetDomain someIP
   /*
   dig +noall +answer +short cyberciti.biz
   */
   put "dig -x" && someIP into someShell
   put shell (someShell) into someDomain
   return word 1 to -1 of someDomain
end dig_GetDomain


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

--> Bonjour
-
command bonjour_RegisterPortMapper pMapperPort
   put merge ("dns-sd -R 'LiveCode Port Mapper' _livecode._udp. . [[pMapperPort]] pdl=application/livecode") into someShell
   shell_ExecuteInBackground someShell
   put the result into shellResult
   return shellResult
end bonjour_RegisterPortMapper

function socket_ListUsedPorts
   -- On Linux you can use netstat -atp | grep -i "listen")
   -- To show all open ports applications on your machine are listening to you can use this workaround
   
   if the platform is "MacOS" then
      put osx_DaemonArray() into daemonArray
      return keys(daemonArray)
   else
      -- ???
      return empty
   end if
end socket_ListUsedPorts

function osx_DaemonArray
   put "lsof -i -P | grep -i 'listen'" into someShell
   put shell (someShell) into shellResult
   repeat for each line someLine in shellResult
      /*
      1) the `^' (negated) login name or user ID (UID), specified with the -u option;
      2) the `^' (negated) process ID (PID), specified with the -p option;
      3) the `^' (negated) process group ID (PGID), specified with the -g option;
      4) the `^' (negated) command, specified with the -c option;
      5) the (`^') negated TCP or UDP protocol state names, specified with the -s [p:s] option.
      */
      
      put word 1 of someLine into appName
      put word 2 of someLine into pID
      put word 3 of someLine into uName
      put word 4 of someLine into noIdea
      put word 5 of someLine into ipWhat
      put word 6 of someLine into someHex
      put word 7 of someLine into someThingElse
      put word 8 of someLine into pCol
      put word 9 to -1 of someLine into urlBit
      if word -1 of urlBit = "(LISTEN)" then put word 1 to -2 of urlBit into urlBit
      set the itemdelimiter to ":"
      put item 1 of urlBit into someHost
      put item 2 of urlBit into somePort
      
      put appName into daemonArray [somePort]["appName"]
      put someHost into daemonArray [somePort]["host"]
      put pID into daemonArray [somePort]["process id"]
   end repeat
   return daemonArray
end osx_DaemonArray


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


--> DigitalOcean | A Record
-
function digitalocean_FetchArecordNames oceanDomainName
   put digitalocean_FetchArecordArray (oceanDomainName) into aRecordArray
   put keys (aRecordArray) into aRecordNames
   sort aRecordNames
   return aRecordNames
end digitalocean_FetchArecordNames

function digitalocean_FetchArecordArray oceanDomainName
   put digitalocean_FetchDomainRecordArray (oceanDomainName) into oceanDomainRecordArray
   put oceanDomainRecordArray ["domain_records"] into domainArray
   repeat for each key recordNum in domainArray
      if domainArray [recordNum]["type"] is not "A" then next repeat
      
      put domainArray [recordNum]["name"] into subDomain
      put domainArray [recordNum]["data"] into someIP
      put domainArray [recordNum]["id"] into recordID
      
      put someIP into aRecordArray [subDomain]["ip_address"]
      put recordID into aRecordArray [subDomain]["id"]
   end repeat
   return aRecordArray
end digitalocean_FetchArecordArray

function digitalocean_GetArecordID oceanDomainName, subDomain, oceanDomainRecordArray
   if subDomain is empty or subDomain = oceanDomainName then put "@" into subDomain
   put oceanDomainRecordArray ["domain_records"] into domainArray
   repeat for each key recordNum in domainArray
      if domainArray [recordNum]["type"] is not "A" then next repeat
      if domainArray [recordNum]["name"] is not subDomain then next repeat
      return domainArray [recordNum]["id"]
   end repeat
   return empty
end digitalocean_GetArecordID

function digitalocean_FetchArecordID oceanDomainName, subDomain
   put digitalocean_FetchDomainRecordArray (oceanDomainName) into oceanDomainRecordArray
   put digitalocean_GetARecordID (oceanDomainName, subDomain, oceanDomainRecordArray) into recordID
   if recordID is empty then
      return "Error, no A record found for" && subDomain && "in" && oceanDomainName
   end if
   return recordID
end digitalocean_FetchArecordID


--> DigitalOcean | A Record | Create
-
command digitalocean_SetArecords oceanDomainName, newIP
   put digitalocean_FetchArecordArray (oceanDomainName) into aRecordArray
   repeat for each key subDomain in aRecordArray
      put aRecordArray [subDomain]["ip_address"] into testIP
      put aRecordArray [subDomain]["id"] into recordID
      
      if testIP = newIP then next repeat
      digitalocean_UpdateARecordIP newIP, oceanDomainName, subDomain
      put the result into resultArray [subDomain]
   end repeat
   return resultArray
end digitalocean_SetArecords

command digitalocean_CreateARecord oceanDomainName, subDomain, pAnotherIP
   -- {"type":"A","name":"customdomainrecord.com","data":"162.10.66.0","priority":null,"port":null,"weight":null}
   
   -- should check it is an IP
   if pAnotherIP is empty then
      put digitalOcean_FindDropletIP (oceanDomainName) into someIP
   else
      put pAnotherIP into someIP
   end if
   if http_CheckIP (someIP) is false then return "error, fetching ip address for domain" && oceanDomainName
   
   get "{'type':'A','name':'[[subDomain]]','data':'[[someIP]]','priority':null,'port':null,'weight':null}"
   replace "'" with quote in it
   put merge(it) into someJSON
   digitalocean_CreateNewDomainRecord oceanDomainName, someJSON
   put the result into someResult
   return someResult
end digitalocean_CreateARecord

command digitalocean_UpdateARecordIP someIP, oceanDomainName, subDomain
   -- "https://api.digitalocean.com/v2/domains/digitaloceanisthebombdiggity.com/records/3352896"
   -- {"name":"updated-record-name.com"}
   -- curl -X PUT -H 'Content-Type: application/json' -H 'Authorization: Bearer $TOKEN' -d '[[someJSON]]' someUrl
   put word 1 to -1 of someIP into someIP
   
   get "{'data':'[[someIP]]'}"
   replace "'" with quote in it
   put merge(it) into someJSON
   
   put digitalocean_FetchArecordID (oceanDomainName, subDomain) into recordID
   
   digitalocean_UpdateDomainRecord oceanDomainName, recordID, someJSON
   put the result into someResult
   return someResult
end digitalocean_UpdateARecordIP

command digitalocean_DeleteArecord oceanDomainName, subDomain
   -- slow. Consider using an asychnronous call?
   put digitalocean_FetchArecordID (oceanDomainName, subDomain) into recordID
   if recordID is empty then
      return merge("error, can't find A record for [[subDomain]] of [[oceanDomainName]]")
   end if
   digitalocean_DeleteDomainRecord oceanDomainName, recordID
   put the result into resultArray
   return resultArray
end digitalocean_DeleteArecord


--> DigitalOcean | NS Record
-
command digitalocean_CreateNameServerRecord oceanDomainName, nameServerDomain
   dns_AddDotToDomain nameServerDomain
   get "{'type':'NS','data':'[[nameServerDomain]]'}"
   replace "'" with quote in it
   put merge(it) into someJSON
   digitalocean_CreateNewDomainRecord oceanDomainName, someJSON
   put the result into someResult
   return someResult
end digitalocean_CreateNameServerRecord

command digitalocean_DeleteNameServerRecord oceanDomainName, nameServer
   put digitalocean_FetchNSrecordID (oceanDomainName, nameServer) into recordID
   if recordID is empty then
      return merge("error, can't find a NS record for [[subDomain]] of [[oceanDomainName]]")
   end if
   
   digitalocean_DeleteDomainRecord oceanDomainName, recordID
   put the result into theResult
   return theResult
end digitalocean_DeleteNameServerRecord

function digitalocean_FetchNSrecordID oceanDomainName, nameServer
   put digitalocean_FetchDomainRecordArray (oceanDomainName) into oceanDomainRecordArray
   put digitalocean_GetNSrecordID (oceanDomainName, nameServer, oceanDomainRecordArray) into recordID
   if recordID is empty then
      return "Error, no NS record found for" && nameServer && "in" && oceanDomainName
   end if
   return recordID
end digitalocean_FetchNSrecordID

function digitalocean_GetNSrecordID oceanDomainName, nameServer, oceanDomainRecordArray
   put oceanDomainRecordArray ["domain_records"] into domainArray
   repeat for each key recordNum in domainArray
      if domainArray [recordNum]["type"] is not "NS" then next repeat
      if domainArray [recordNum]["data"] is not nameServer then next repeat
      return domainArray [recordNum]["id"]
   end repeat
   return empty
end digitalocean_GetNSrecordID


--> DigitalOcean | Domain Records
-
function digitalocean_FetchDomainRecordArray oceanDomainName
   -- constant dsfa = "https://api.digitalocean.com/v2/domains/digitaloceanisthebombdiggity.com/records"
   -- curl -X GET -H 'Content-Type: application/json' -H 'Authorization: Bearer $Token' "[[fdas]"
   
   put "domains/" & oceanDomainName & "/records" into domainPath
   put "?per_page=200" after domainPath
   --
   put digitalocean_FetchJsonArray (domainPath) into domainInfoArray
   return domainInfoArray
end digitalocean_FetchDomainRecordArray

function digitalocean_RetrieveDomainRecord oceanDomainName, recordID
   -- same data as is received in batch from "digitalocean_FetchDomainRecordArray"
   
   -- constant dsfa = "https://api.digitalocean.com/v2/domains/digitaloceanisthebombdiggity.com/records/3352896"
   -- curl -X GET -H 'Content-Type: application/json' -H 'Authorization: Bearer b7d03a6947b217efb6f3ec3bd3504582' "[[apiUrl]]"
   
   put "domains/" & oceanDomainName & "/records/" & recordID into domainPath
   --
   put digitalocean_FetchJsonArray (domainPath) into domainInfoArray
   return domainInfoArray
end digitalocean_RetrieveDomainRecord

command digitalocean_UpdateDomainRecord oceanDomainName, recordID, someJSON
   /*
   https://developers.digitalocean.com/documentation/v2/#update-a-domain-record
   
   To update an existing record, send a PUT request to /v2/domains/$DOMAIN_NAME/records/$RECORD_ID. 
   Any attribute valid for the record type can be set to a new value for the record.
   
   -- constant dsfa = "https://api.digitalocean.com/v2/domains/digitaloceanisthebombdiggity.com/records"
   -- curl -X GET -H 'Content-Type: application/json' -H 'Authorization: Bearer $Token' "[[fdas]"
   */
   
   put "domains/" & oceanDomainName & "/records/" & recordID into domainPath
   digitalocean_RestPut domainPath, someJSON
   put the result into someResult
   return someResult
end digitalocean_UpdateDomainRecord

command digitalocean_CreateNewDomainRecord oceanDomainName, someJSON
   /*
   To create a new record to a domain, send a POST request to /v2/domains/$DOMAIN_NAME/records. 
   The request must include all of the required fields for the domain record type being added. 
   The required attributes per domain record type:
   
   -- https://api.digitalocean.com/v2/domains/digitaloceanisthebombdiggity.com/records
   -- someJSON = {"type":"A","name":"customdomainrecord.com","data":"162.10.66.0","priority":null,"port":null,"weight":null}
   curl -X POST -H 'Content-Type: application/json' -H 'Authorization: Bearer [[$TOKEN]]' -d '[[someJSON]]' "[[apiURL]]"
   */
   
   put "domains/" & oceanDomainName & "/records" into domainPath
   digitalocean_RestPost domainPath, someJSON
   put the result into someResult
   return someResult
end digitalocean_CreateNewDomainRecord

command digitalocean_DeleteDomainRecord oceanDomainName, recordID
   /*
   https://developers.digitalocean.com/documentation/v2/#delete-a-domain-record
   
   To delete a record for a domain, send a DELETE request to /v2/domains/$DOMAIN_NAME/records/$RECORD_ID.
   The record will be deleted and the response status will be a 204. 
   This indicates a successful request with no body returned.
   
   put "https://api.digitalocean.com/v2/domains/digitaloceanisthebombdiggity.com/records/3352896" into apiUrl
   curl -X DELETE -H 'Content-Type: application/json' -H 'Authorization: Bearer [[$TOKEN]]' "[[apiUrl]]"
   */
   
   put "domains/" & oceanDomainName & "/records/" & recordID into domainPath
   digitalocean_RestDelete domainPath
   
   dispatch "digitalocean_UpdateDomainInfoArray"
   return the result
end digitalocean_DeleteDomainRecord


--> DigitalOcean | Domains
-
command digitalocean_CreateDomain domainName, someIP
   /*
   -- v2
   -- https://developers.digitalocean.com/documentation/v2/#create-a-new-domain
   
   To create a new domain, send a POST request to /v2/domains. 
   Set the "name" attribute to the domain name you are adding. 
   Set the "ip_address" attribute to the IP address you want to point the domain to.
   
   -- curl -X POST -H 'Content-Type: application/json' -H 'Authorization: Bearer $TOKEN'
   -- -d '{"name":"digitaloceanisthebombdiggity.com","ip_address":"1.2.3.4"}' 
   -- "https://api.digitalocean.com/v2/domains"
   
   -d '{"name":"digitaloceanisthebombdiggity.com","ip_address":"1.2.3.4"}' 
   "https://api.digitalocean.com/v2/domains"
   
   {
   "name": "digitaloceanisthebombdiggity.com",
   "ip_address": "1.2.3.4"
   }
   */
   
   -- dns_AddDotToDomain domainName
   put merge ("{'name':'[[domainName]]','ip_address':'[[someIP]]'}") into someJSON
   replace "'" with quote in someJSON
   
   digitalocean_RestPost "domains", someJson
   put the result into jsonResult
   return jsonResult
end digitalocean_CreateDomain
