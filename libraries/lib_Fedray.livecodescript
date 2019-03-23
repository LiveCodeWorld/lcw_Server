script "lib_Fedray"
--> MetaData
-
license: GPLv3
name: lib_Fedray
type: library
version: 0.1

/*
These handlers are for working with "federation arrays" or "fedray" structures.
See also "model_Fedray"
*/

--> Working on
-
command fedray_UpdateDomain @fedray, wikiDomain, pLoad, pSitemapArray
   -- update Wards data structure with latest from sitemap
   -- pages, ipAddress, owner, last modified and created
   
   if pSitemapArray is not an array then
      put fedwiki_FetchSitemapArray (wikiDomain, pLoad) into pSitemapArray
      if pSitemapArray is not an array then
         delete variable fedray [wikiDomain]
         return empty
      end if
   end if
   
   put keys (pSitemapArray) into pageSlugs
   put the number of lines of pageSlugs into pageNum
   put pageNum into fedray [wikiDomain]["pages"]
   --
   put fedwiki_SitemapLastModified (pSitemapArray) into fedray [wikiDomain]["last modified"]
   --
   put fedwiki_FetchCreationDate (wikiDomain) into fedray [wikiDomain]["created"] -- fetch from welcome-visitors
   put fedwiki_FetchOwnerName (wikiDomain) into ownerName
   put ownerName into fedray [wikiDomain]["owner"]
   --
   put dig_GetIP (wikiDomain) into someIP
   put someIP into fedray [wikiDomain]["ipAddress"]
   --
   return pageNum
end fedray_UpdateDomain


--> Fedray | Construct
-
function fedray_ConstructRoster pCheck
   put fedray_FetchSizeRoster (pCheck) into rosterArray
   repeat for each item someName in "Mega,Working,Baby,Mayfly,Bad"
      set the cursor to busy
      --
      put someName && "sites" into sectionName
      put rosterArray [sectionName] into domainArray
      put keys (domainArray) into domainNames
      url_SortDomainIndex domainNames
      --
      put sectionName & CR & CR & domainNames & CR & CR after rosterText
   end repeat
   delete char -2 to -1 of rosterText
   return rosterText
end fedray_ConstructRoster

function fedray_FetchSizeRoster pCheck
   set the cursor to watch
   put fedray_FetchWards() into fedSiteArray
   repeat for each key wikiDomain in fedSiteArray
      if pCheck is true then
         set the cursor to busy
         put fedwiki_FetchSitemapArray (wikiDomain) into sitemapArray
         if sitemapArray is an array then
            put item 2 of the extents of sitemapArray into pageNum
         else
            put empty into rosterArray ["Bad sites"][wikiDomain]
            next repeat
         end if
      else
         put domainArray ["pages"] into pageNum
      end if
      
      put fedSiteArray [wikiDomain] into domainArray
      switch
         case pageNum < 6
            put domainArray into rosterArray ["Mayfly sites"][wikiDomain]
            break
         case 13 > pageNum and pageNum  > 5
            put domainArray into rosterArray ["Baby sites"][wikiDomain]
            break
         case 31 > pageNum and pageNum > 12
            put domainArray into rosterArray ["Working sites"][wikiDomain]
            break
         default
            -- case pageNum > 30
            put domainArray into rosterArray ["Mega sites"][wikiDomain]
      end switch
   end repeat
   return rosterArray
end fedray_FetchSizeRoster


--> Fedray
-
command fedray_Filter @domainArray, pMinPageNum
   repeat for each key domainName in domainArray
      put domainArray [domainName] into infoArray
      put infoArray ["pages"] into pageNum
      if pageNum > pMinPageNum then
         put infoArray into goodArray [domainName]
      else
         put infoArray into badArray [domainName]
      end if
   end repeat
   put goodArray into domainArray
   return badArray
end fedray_Filter


--> Fedray | Update
-
command federation_CreateAuthorAndServerModels fedray, pUpdateFedray
   -- careful this stores data to wiki
   put serverData_FetchUpdated (fedray, pUpdateFedray) into serverData
   put fedray_ConstructAuthorData (fedray) into authorArray
   
   -- now store them online
   federation_StoreServerData serverData
   federation_StoreAuthorData authorArray
end federation_CreateAuthorAndServerModels

function fedray_FetchUpdated
   put fedray_FetchWards() into fedray
   repeat for each line wikiDomain in fedDomains
      set the cursor to busy
      fedray_UpdateDomain fedray, wikiDomain, true
   end repeat
   return fedray
end fedray_FetchUpdated

function fedray_ConstructServerData fedray, pUpdateFedray
   local serverData
   repeat for each key wikiDomain in fedray
      set the cursor to busy
      serverData_UpdateDomain serverData, fedray, wikiDomain, pUpdateFedray
   end repeat
   return serverData
end fedray_ConstructServerData

function fedray_ConstructAuthorData fedray, pUpdateFedray
   local authorArray
   repeat for each key wikiDomain in fedray
      set the cursor to busy
      if pUpdateFedray is true then fedray_UpdateDomain fedray, wikiDomain
      put fedray [wikiDomain] into domainArray
      put domainArray ["owner"] into ownerName
      if ownerName is empty then put "No name" into ownerName
      put domainArray into authorArray [ownerName][wikiDomain]
   end repeat
   return authorArray
end fedray_ConstructAuthorData


--> ServerData | Update
-
command serverData_UpdateServer @serverData, serverName, fedray, pUpdateFedray
   local newServerData
   put serverData [serverName]["domains"] into serverDomainArray
   repeat for each key wikiDomain in serverDomainArray
      set the cursor to busy
      serverData_UpdateDomain newServerData, fedray, wikiDomain, pUpdateFedray -- newServerData will use ipAddress not serverName
   end repeat
   put line 1 of keys (newServerData) into ipAddress
   -- put serverData_FetchNameDictionary() into serverNameDictionary
   -- put serverNameDictionary [ipAddress] into newName -- should be same as "serverName"
   put newServerData [ipAddress] into serverData [serverName]
   serverData_UpdateServerInfo serverData, serverName
   return newServerData
end serverData_UpdateServer

command serverData_UpdateDomain @serverData, fedray, wikiDomain, pUpdateFedray
   if pUpdateFedray is true then fedray_UpdateDomain fedray, wikiDomain
   put fedray [wikiDomain] into domainArray
   put domainArray ["ipAddress"] into ipAddress
   if ipAddress is not empty then
      if the number of lines of ipAddress > 1 then
         put line -1 of ipAddress into ipAddress
      end if
      put domainArray into serverData [ipAddress]["domains"][wikiDomain]
      put ipAddress into serverData [ipAddress]["ipAddress"] -- only needs to do once but OK
   end if
end serverData_UpdateDomain

function serverData_FetchUpdated fedray, pUpdateFedray
   put serverData_FetchNameDictionary() into serverNameDictionary
   put fedray_ConstructServerData (fedray, pUpdateFedray) into serverData
   serverData_Rename serverData, serverNameDictionary
   repeat for each key serverName in serverData
      set the cursor to busy
      serverData_UpdateServerInfo serverData, serverName
   end repeat
   return serverData
end serverData_FetchUpdated

command serverData_Rename @serverData, serverNameDictionary
   repeat for each key serverName in serverData
      put serverNameDictionary [serverName] into newName
      if newName is not empty then
         put serverData [serverName] into serverArray
         put serverArray into serverData [newName]
         delete variable serverData [serverName]
      end if
   end repeat
end serverData_Rename

function serverData_FetchNameDictionary pServerData
   if pServerData is not an array then
      put federation_FetchServerData() into pServerData
   end if
   repeat for each key serverName in pServerData
      put pServerData [serverName] into serverArray
      put serverArray ["ipAddress"] into ipAddress
      put serverName into serverNameDictionary [ipAddress]
   end repeat
   return serverNameDictionary
end serverData_FetchNameDictionary

--> SeverData
-
function serverData_GetRosterText serverName, serverData, pAddTitle
   put serverData [serverName]["domains"] into domainArray
   put keys (domainArray) into domainNames
   url_SortDomainIndex domainNames
   if pAddTitle is true then
      put serverName & "sites" & CR & CR before domainNames
   end if
   return domainNames
end serverData_GetRosterText

command serverData_SetSummary serverData, pListHow
   put the keys of serverData into serverNames
   sort serverNames
   repeat for each line serverName in serverNames
      put word 1 to -1 of serverName into serverName
      if serverName is empty then next repeat
      --
      serverData_UpdateServerInfo serverData, serverName
      put the result into summaryText
      put word -2 of summaryText into domainNum
      put word 1 of summaryText into serverPageNum
      --
      switch pListHow
         case "Extended"
            put "1. [[" & serverName && "Server" & "]] (" & summaryText & ")" into indexLine
            break
         case "Simple"
            put "- [[" & serverName && "Server" & "]]" into indexLine
            break
         default
            put "1. [[" & serverName && "Server" & "]] (" & domainNum && "domains)" into indexLine
      end switch
      put indexLine & CR after markdownList
   end repeat
   delete char -1 of markdownList
   
   switch pListHow
      case "Simple"
         -- don't sort again
         break
      case "Extended"
         -- don't sort again
         sort numeric descending markdownList by word -2 of each
         break
      default
         sort numeric descending markdownList by token -3 of each
   end switch
   return markdownList
end serverData_SetSummary

command serverData_Deconstruct serverData, serverName, @serverDomains, @domainNum, @serverPageNum, @createdDate, @ipAddress
   put serverData [serverName] into serverDomainArray
   --
   put serverDomainArray ["ipAddress"] into ipAddress
   put serverDomainArray ["domains"] into domainArray
   put serverDomainArray ["domainNum"] into domainNum
   put serverDomainArray ["pageNum"] into serverPageNum
   put serverDomainArray ["created"] into createdDate
   put keys (domainArray) into serverDomains
   url_SortDomainIndex serverDomains
   put serverName && "sites" & CR & CR & serverDomains into rosterText
   return rosterText
end serverData_Deconstruct

function serverData_GetAuthorNames serverName, serverData
   put serverData [serverName]["domains"] into domainArray
   repeat for each key domainName in domainArray
      put domainArray [domainName]["owner"] into ownerName
      put empty into authorArray [ownerName]
   end repeat
   put keys (authorArray) into authorNames
   sort authorNames by word -1 of each
   return authorNames
end serverData_GetAuthorNames

command serverData_UpdateServerInfo @serverData, serverName
   put serverData [serverName] into serverDomainArray
   put serverDomainArray ["domains"] into domainArray
   --
   put keys (domainArray) into domainNames
   put the number of lines of domainNames into domainNum
   put domainNum into serverData [serverName]["domainNum"]
   --
   put 0 into serverPageNum
   repeat for each line domainName in domainNames
      put domainArray [domainName]["pages"] into domainPageNum
      add domainPageNum to serverPageNum
   end repeat
   put serverPageNum into serverData [serverName]["pageNum"]
   --
   put serverPageNum && "pages in" && domainNum && "domains" into summaryText
   return summaryText
end serverData_UpdateServerInfo
