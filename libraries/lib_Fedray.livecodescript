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

--> Fedray | Ward
-
function fedray_FetchUpdated
   put ward_FetchSiteModel() into fedray
   repeat for each line wikiDomain in fedDomains
      set the cursor to busy
      fedray_UpdateLastModified fedray, wikiDomain, true
   end repeat
   return fedray
end fedray_FetchUpdated

function fedray_FetchSizeRoster pCheck
   set the cursor to watch
   put ward_FetchSiteModel() into fedSiteArray
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


--> Fedray | Time
-
function fedray_GetLastModified wikiDomains, pFedray
   if pFedray is empty then put fedray_FetchModel() into pFedray
   put 0 into maxUpdate
   repeat for each line wikiDomain in wikiDomains
      put pFedray [wikiDomain]["last modified"] into lastUpdate
      if lastUpdate > maxUpdate then
         put lastUpdate into maxUpdate
      end if
   end repeat
   return maxUpdate
end fedray_GetLastModified

function fedray_SiteFirstDate wikiDomains, fedray
   -- for a quick hack we get the creation dates of welcome-visitors
   put the milliseconds into firstDate
   repeat for each line wikiDomain in wikiDomains
      put fedray [wikiDomain]["created"] into creationDate
      if creationDate < firstDate then
         put creationDate into firstDate
      end if
   end repeat
   return firstDate
end fedray_SiteFirstDate


--> Fedray
-
function fedray_Construct atopiaDomains
   local fedray
   repeat for each line wikiDomain in atopiaDomains
      set the cursor to busy
      fedray_UpdateLastModified fedray, wikiDomain
   end repeat
   return fedray
end fedray_Construct

function fedray_IsIndexed wikiDomain, pFedray
   put fedray_FetchDomainArray (wikiDomain, pFedray) into fedrayDomainArray
   put fedrayDomainArray is an array into isInFederation
   return isInFederation
end fedray_IsIndexed

command fedray_ToggleIsIndexed wikiDomain, someBoolean
   put fedray_FetchModel() into fedray
   --
   if someBoolean is true then
      fedray_UpdateLastModified fedray, wikiDomain
      if the result is empty then
         return merge ("Error, problem fetching the sitemap for '[[wikiDomain]]'")
      end if
   else
      delete variable fedray [wikiDomain]
   end if
   --
   fedray_StoreModel fedray
   --
   return fedray
end fedray_ToggleIsIndexed

function fedray_FetchDomainArray wikiDomain, pFedray
   if pFedray is empty then
      put fedray_FetchModel() into pFedray
   end if
   put pFedray [wikiDomain] into fedrayDomainArray
   return fedrayDomainArray
end fedray_FetchDomainArray


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


--> Fedray
-
function fedray_ListServerDomains serverName
   put fedserver_FetchFedray (serverName) into serverFedray
   put the keys of serverFedray into domainNames
   url_SortDomainIndex domainNames
   return domainNames
end fedray_ListServerDomains

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
