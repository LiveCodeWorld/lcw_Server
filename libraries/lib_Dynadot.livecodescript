script "lib_Dynadot"
--> MetaData
-
license: GPLv3
name: lib_Dynadot
type: library
version: 0.8

/*
A library for interfacing with DNS services like DigitalOcean and Dynadot
*/


--> Dynadot | Display
-
command display_DynadotDomainInfo domainName
   put dynadot_GetDomainInfoArray (domainName, true) into domainInfoArray
   
   put domainName & comma & "Domain Info" into displayTitle
   display_Array domainInfoArray, displayTitle
   put the result into arrayView
   return arrayView
end display_DynadotDomainInfo


--> Dynadot | Model | List Array
-
function dynadot_ConstructDomainListArray responseArray
   put responseArray ["ListDomainInfoResponse"] ["ListDomainInfoContent"]["DomainInfoList"] into domainListInfoArray
   repeat for each key dNum in domainListInfoArray
      put domainListInfoArray [dNum]["Domain"] into domainArray
      put domainArray ["Name"] into domainName
      
      put domainArray ["NameServerSettings"] into domainListArray [domainName]["NameServerSettings"]
      put domainArray ["Expiration"] into domainListArray [domainName]["Expiration"]
      put domainArray ["RenewOption"] into domainListArray [domainName]["RenewOption"]
      put domainArray ["Whois"] into domainListArray [domainName]["Whois"]
   end repeat
   return domainListArray
end dynadot_ConstructDomainListArray


--> Dynadot | Folder
-
command dynadot_SetFolder domainName, folderName
   -- https://api.dynadot.com/api3.xml?key=mykey&command=set_folder&domain=domian1.com&folder=folder1
   
   put dynadot_GetAdvancedXML ("set_folder", "domain", domainName, "folder", folderName) into someXML
   /*
   <SuccessCode></SuccessCode>If the operation is successful, "0" for success, "-1" for failure
   */
end dynadot_SetFolder

command dynadot_SetParking domainName, pBoolean
   -- https://api.dynadot.com/api3.xml?key=mykey&command=set_parking&domain=domain1.com&with_ads=no
   if pBoolean is false then
      put dns_HostNameServers ("Digital Ocean") into nameServers
      dynadot_SetNameServers domainName, nameServers
      put the result into someXML
   else
      put dynadot_GetAdvancedXML ("set_parking", "domain", domainName) into someXML
      /*
      <SuccessCode></SuccessCode>If the operation is successful, "0" for success, "-1" for failure
      */
   end if
   
   put xml_ToArray (someXML) into responseArray
   return responseArray
end dynadot_SetParking

command dynadot_SetNameServers domainName, nameServers
   -- https://api.dynadot.com/api2.html?key=8S7I2s6Qd8g&command=set_ns&domain=mydomain.com&ns0=ns1.hostns.com&ns1=ns2.hostns.com
   
   -- put dynadot_ConstructApiStem ("set_ns") & "domain=" & domainName into someUrl
   put dynadot_ConstructSimpleURL ("set_ns", "domain", domainName) into someUrl
   
   replace comma with CR in nameServers
   repeat with lineNum = 1 to the number of lines of nameServers
      put lineNum - 1 into nsNum
      put line lineNum of nameServers into nsName
      put "&ns" & nsNum & "=" & nsName into nsBit
      put nsBit after someUrl
   end repeat
   
   -- could use load for async
   put url someUrl into someXML
   
   -- <SetNsResponse><SetNsHeader><SuccessCode>0</SuccessCode><Status>success</Status></SetNsHeader></SetNsResponse>
   if dynadot_CheckError (someXML) is not empty then
      breakpoint
      return empty
   end if
   return someXML
end dynadot_SetNameServers


--> Dynadot | Model | List
-
function dynadot_ListParkedDomainNames pForceUpdate
   put dynadot_GetDomainNameArray (pForceUpdate) into domainNameArray
   repeat for each key domainName in domainNameArray
      if domainNameArray [domainName]["NameServerSettings"]["type"] = "Dynadot Parking" then
         put domainName & CR after domainNames
      end if
   end repeat
   delete char -1 of domainNames
   url_SortDomainIndex domainNames
   return domainNames
end dynadot_ListParkedDomainNames

function dynadot_ListDomainNames pForceUpdate
   -- list domains whose DNS is managed by dynadot (not parked)
   put dynadot_GetDomainNameArray (pForceUpdate) into domainNameArray
   repeat for each key domainName in domainNameArray
      put domainName & CR after domainNames
   end repeat
   delete char -1 of domainNames
   url_SortDomainIndex domainNames
   return domainNames
end dynadot_ListDomainNames

function dynadot_ListManagedDomainNames pForceUpdate
   -- list domains whose DNS is managed by dynadot (not parked)
   put dynadot_GetDomainNameArray (pForceUpdate) into domainNameArray
   repeat for each key domainName in domainNameArray
      if domainNameArray [domainName]["NameServerSettings"]["type"] = "Dynadot DNS" then
         put domainName & CR after domainNames
      end if
   end repeat
   delete char -1 of domainNames
   url_SortDomainIndex domainNames
   return domainNames
end dynadot_ListManagedDomainNames

function dynadot_ListOceanDomainNames pForceUpdate
   put dynadot_GetDomainNameArray (pForceUpdate) into domainNameArray
   repeat for each key domainName in domainNameArray
      get domainNameArray [domainName]["NameServerSettings"]["type"]
      if it = "Name Servers" then
         put domainNameArray [domainName]["NameServerSettings"]["Nameservers"] into nameServerArray
         put true into isOcean
         repeat with dnsServerNum = 1 to 3
            put "Servername[" & dnsServerNum & "]" into nameKey
            put nameServerArray [nameKey] into dnsServerName
            if dnsServerName is not among the items of "ns1.digitalocean.com,ns2.digitalocean.com,ns3.digitalocean.com" then
               put false into isOcean
               exit repeat
            end if
         end repeat
         if isOcean is true then
            put domainName & CR after domainNames
         end if
      end if
   end repeat
   delete char -1 of domainNames
   url_SortDomainIndex domainNames
   return domainNames
end dynadot_ListOceanDomainNames

function dynadot_ListDomainNames pIndexedDomainArray
   if pIndexedDomainArray is not an array then put dynadot_GetIndexedDomainArray() into pIndexedDomainArray
   put dynadot_ConstructDomainListArray (pIndexedDomainArray) into domainListArray
   put keys (domainListArray) into domainNames
   url_SortDomainIndex domainNames
   return domainNames
end dynadot_ListDomainNames


--> Dynadot
-
function dynadot_GetNameServers domainName
   put dynadot_FetchNameServerXml (domainName) into someXML
   if dynadot_CheckError (someXML) is not empty then
      breakpoint
      return empty
   end if
   
   -- success,ns1.digitalocean.com,ns2.digitalocean.com,ns3.digitalocean.com,,,,,,,,,,,Name Servers
   get line 3 of someXML
   if item 1 of it is not "success" then
      breakpoint
      return empty
   end if
   delete item 1 of it
   
   repeat for each item nsServerName in it
      if nsServerName is empty then
         delete char -1 of nsServerNames
         return nsServerNames
      end if
      put nsServerName & CR after nsServerNames
   end repeat
   -- if all possible nameservers are set
   delete char -1 of nsServerNames
   return nsServerNames 
end dynadot_GetNameServers
