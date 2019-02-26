script "model_Fedray"
--> MetaData
-
license: GPLv3
name: model_Fedray
type: model
version: 0.1


--> Working on
-
function fedray_FetchAllDomainArrayFromWard
   -- bit of a complex format. Probaly better to use "fedray_FetchWardsSiteArray()"
   breakpoint
   put fedray_FetchAllDomainTable() into someIndex
   repeat for each line someLine in someIndex
      -- put word 1 of "admin.asia.wiki.org, 42 pages"
      -- 7800ec3b.ngrok.io, sitemap: 743: unexpected token at 'Tunnel 7800ec3b.ngrok.io not found'
      
      put item 1 of someLine into someDomain
      get word 1 of item 2 of someLine
      if it is not a number then next repeat
      
      put it into pageNumber
      if pageNumber < 2 then next repeat
      
      put pageNumber into domainArray [someDomain]
   end repeat
   return domainArray
end fedray_FetchAllDomainArrayFromWard


--> Fedwiki | Fetch
-
function fedwiki_FetchOwnerName fedwikiDomain
   /*
   get "https://fedwiki.rodwell.me/view/narrative-chart/view/coffeehouse-culture"
   set the itemdelimiter to slash
   put item 3 of it into fedwikiDomain
   */
   put "http://" & fedwikiDomain & "/welcome-visitors.html" into someURL
   put url someURL into someHTML
   --
   put "//*[@id='site-owner']" into someXPath 
   replace "'" with quote in someXPath
   put scrape_WithXPath (someHTML, someXPath, true) into contentSection
   put line 2 to 3 of contentSection into someName
   replace CR with space in someName
   return word 1 to -1 of someName
end fedwiki_FetchOwnerName


--> Fedwiki | Fetch | Ward
-
command atopia_StoreServerDomainArray pAtopiaDomains
   put atopia_ConstructServerDomainArray() into serverDomainArray
   --
   if serverDomainArray is not an array then
      breakpoint
      return "Error, serverDomainArray is not an array"
   end if
   
   atopia_StoreServerArray "Atopia Domains", serverDomainArray
   put the result into putError
   return putError
end atopia_StoreServerDomainArray

function atopia_ConstructServerDomainArray pAtopiaDomains
   -- return in Ward-compatible format
   put atopia_TestAndConstructServerDomainArray (pAtopiaDomains) into goodBadArray
   put goodBadArray ["good"] into newServerDomainArray
   return newServerDomainArray
end atopia_ConstructServerDomainArray

function atopia_TestAndConstructServerDomainArray pAtopiaDomains
   if pAtopiaDomains is empty then
      set the cursor to watch
      resetall -- otherwise things tend to stop working
      put atopia_FetchAllFolderList() into pAtopiaDomains
   end if
   --
   url_SortDomainIndex pAtopiaDomains
   repeat for each line atopiaDomain in pAtopiaDomains
      set the cursor to busy
      put fedwiki_FetchSitemapArray (atopiaDomain) into sitemapArray
      if sitemapArray is not an array then
         put true into goodBadArray ["bad"][atopiaDomain] 
         next repeat
      end if
      put keys (sitemapArray) into pageSlugs
      put the number of lines of pageSlugs into pageNum
      put pageNum into goodBadArray ["good"][atopiaDomain]["pages"]
   end repeat
   return goodBadArray
end atopia_TestAndConstructServerDomainArray

function atopia_FetchNewServerDomainArray pFetchAtopiaDomains
   -- return in Ward-compatible format
   set the cursor to watch   
   put fedray_FetchWardsSiteArray() into fedDomainArray
   if pFetchAtopiaDomains then
      -- slow
      put atopia_FetchAllFolderList() into atopiaDomains
   else
      -- fast
      put atopia_FetchRoster() into atopiaDomains
   end if
   repeat for each line atopiaDomain in atopiaDomains
      set the cursor to busy
      put fedDomainArray [atopiaDomain] into domainArray
      if domainArray is empty then
         put fedwiki_FetchSitemapArray (atopiaDomain) into sitemapArray
         put keys (sitemapArray) into pageSlugs
         put the number of lines of pageSlugs into pageNum
         --
         put pageNum into newServerDomainArray [atopiaDomain]["pages"]
      end if
   end repeat
   return newServerDomainArray
end atopia_FetchNewServerDomainArray

function fedray_FetchNewAtopiaDomainNames pSort
   set the cursor to watch
   -- put atopia_FetchAllFolderList() into atopiaDomains -- slow
   
   put fedray_FetchWardsSiteArray() into fedDomainArray
   put atopia_FetchStoredDomains() into atopiaDomains -- fast
   repeat for each line atopiaDomain in atopiaDomains
      set the cursor to busy
      put fedDomainArray [atopiaDomain] into domainArray
      if domainArray is empty then
         put true into newDomainArray [atopiaDomain]
      end if
   end repeat
   --
   put keys (newDomainArray) into domainNames
   if pSort is true then
      url_SortDomainIndex domainNames
   end if
   return domainNames
end fedray_FetchNewAtopiaDomainNames


--> Fedray | Federation | Fetch
-
function fedray_FetchTopFederationDomains
   -- fetch all federation domains from wards scrape
   -- set the cursor to watch
   put fedray_FetchAllDomainNames() into federationDomains
   put url_ListTopDomains (federationDomains) into topFederationDomains
   return topFederationDomains
end fedray_FetchTopFederationDomains

function fedray_FetchAllDomainNames pSort
   -- takes betewwn 40 to 17 seconds to fetch
   -- see also "fedray_ListAllDomainNames()"
   
   put fedray_FetchWardsSiteArray() into siteArray
   put keys (siteArray) into domainNames
   if pSort is true then
      url_SortDomainIndex domainNames
   end if
   return domainNames
end fedray_FetchAllDomainNames

function fedray_FetchWardsSiteArray
   put fedray_FetchWardsSiteJson() into siteJSON
   put json_ToArray (siteJSON) into siteArray
   return siteArray
end fedray_FetchWardsSiteArray

function fedray_FetchWardsSiteJson
   put url "http://search.fed.wiki.org:3030/site-web.json" into siteJSON
   return siteJSON
end fedray_FetchWardsSiteJson

function fedray_FetchAllDomainTable
   put url "http://search.fed.wiki.org:3030/logs" into folderHTML
   get line 1 of folderHTML
   -- <a href="/logs/Thu-2000.txt">Thu-2000</a><br>
   put "<a href='/logs/(.+)'>.+</a><br>" into someReg
   replace "'" with quote in someReg
   if matchText (it, someReg, shortFile) is false then
      breakpoint
   end if
   
   put "http://search.fed.wiki.org:3030/logs/" & shortFile into someURL
   put url someURL into someTable
   return someTable
end fedray_FetchAllDomainTable


--> Atopia | Farm | Model
-
function atopia_GetFarmArray
   put atopia_GetArray ("farm") into farmArray
   return farmArray
end atopia_GetFarmArray

command atopia_SetFarmArray farmArray
   atopia_SetArray farmArray, "farm"
   put the result into modelDataFile
   return modelDataFile
end atopia_SetFarmArray


--> Fedray | Farm | Model
-
function atopia_ConstructFarmArray domainNames, pConfigArray
   local farmArray, colourArray
   if pConfigArray is empty then
      put atopia_GetConfigArray() into pConfigArray
   end if
   atopia_BuildFarmArray domainNames, configArray, farmArray, colourArray
   return farmArray
end atopia_ConstructFarmArray

command atopia_BuildFarmArray domainNames, configArray, @farmArray, @colourArray
   put atopia_GetConfigArray() into configArray
   repeat with lineNum = 1 to the number of lines of domainNames
      set the cursor to busy
      put line lineNum of domainNames into domainName
      --
      put atopia_FetchNameServerType (domainName) into nsType
      put atopia_FetchFarmStatus (nsType, domainName) into isFarm
      put atopia_GetDomainOwnerIdPath (domainName, configArray) into idPath
      put isFarm AND idPath is not empty into isAuthorFarm
      switch
         case isAuthorFarm
            put domainName into colourArray ["darkgreen"][lineNum]
            put lineNum into farmArray ["author farm"][domainName]
            break
         case isFarm
            put domainName into colourArray ["orange"][lineNum]
            put lineNum into farmArray ["farm"][domainName]
            break
         case nsType = "digitalocean"
            put domainName into colourArray ["green"][lineNum]
            put lineNum into farmArray [nsType][domainName]
            break
         case nsType = "dynadot"
            put domainName into colourArray ["blue"][lineNum]
            put lineNum into farmArray [nsType][domainName]
            break
         case nsType = empty -- does nto exist (should move)
            put domainName into colourArray ["red"][lineNum]
            put lineNum into farmArray ["missing"][domainName]
            break
         default -- external
            put domainName into colourArray ["black"][lineNum]
            put lineNum into farmArray ["external"][domainName]
      end switch
   end repeat
end atopia_BuildFarmArray


--> Fedray | Meta | Model
-
function fedray_GetDomainMetaArray wikiDomain, pFedArray
   if pFedArray is not an array then
      put fedray_GetArray ("atopia.array") into pFedArray
   end if
   put pFedArray ["metadata"]["domain"][wikiDomain] into domainMetaArray
   return domainMetaArray
end fedray_GetDomainMetaArray

command fedray_DeconstructDomainMeta domainMetaArray, @ipAddress, @lastSiteUpdate, @ownerEmail, @ownerName
   put domainMetaArray ["ipAddress"] into ipAddress
   put domainMetaArray ["lastSiteUpdate"] into lastSiteUpdate
   put domainMetaArray ["ownerEmail"] into ownerEmail
   put domainMetaArray ["ownerName"] into ownerName
   return domainMetaArray
end fedray_DeconstructDomainMeta


--> Fedray | Sort
-
command fedray_SortForkArray federationArray
   put federationArray ["domain"] into domainArray
   repeat for each key fedwikiDomain in domainArray
      put domainArray [fedwikiDomain] into slugArray
      repeat for each key pSlug in slugArray
         set the cursor to busy
         --
         put slugArray [pSlug]["fork"] into forkArray
         put item 2 of the extents of forkArray into forkNum
         --
         put rankArray [pSlug]["forkNum"] into oldForkNum
         if forkNum > oldForkNum and forkNum > 2 then
            put forkNum into rankArray [pSlug]["forkNum"]
            put fedwikiDomain into rankArray [pSlug]["domain"]
         end if
         --
         put fedwikiDomain & tab & pSlug & tab & forkNum & CR after forkTable
      end repeat
   end repeat
   delete char -1 of forkTable
   set the itemdelimiter to tab
   sort numeric descending lines of forkTable by item 3 of each
   put line 1 to 40 of forkTable
   --
   display_Array rankArray, "Fork Ranks"
end fedray_SortForkArray

function fedray_SortSlugArray slugArray
   local rankArray
   --
   repeat for each key pSlug in slugArray
      set the cursor to busy
      --
      put slugArray [pSlug] into slugDomainArray
      put keys (slugDomainArray) into domainNames
      put the number of lines of domainNames into domainNum
      --
      put rankArray [pSlug]["domainNum"] into oldDomainNum
      if domainNum > oldDomainNum and domainNum > 3 then
         put domainNum into rankArray [pSlug]["domainNum"]
         put pSlug & tab & domainNum & CR after rankTable
      end if
   end repeat
   delete char -1 of rankTable
   set the itemdelimiter to tab
   sort numeric descending lines of rankTable by item 2 of each
   return rankTable
end fedray_SortSlugArray


--> Fedray | Model
-
function fedray_ConstructForkArray federationArray
   -- no forks no entry
   local linkArray
   put federationArray ["domain"] into domainArray
   repeat for each key domainName in domainArray
      put domainArray [domainName] into slugArray
      repeat for each key pageSlug in slugArray
         set the cursor to busy
         put domainName & slash & pageSlug into toNodeKey
         --
         put slugArray [pageSlug]["fork"] into forkArray
         put item 2 of the extents of forkArray into maxForkNum
         repeat with forkNum = maxForkNum down to 1
            put forkArray [forkNum]["domain"] into forkDomain
            put forkDomain & slash & pageSlug into fromNodeKey
            --
            put empty into linkArray [toNodeKey][fromNodeKey]
            put fromNodeKey into toNodeKey
         end repeat
      end repeat
   end repeat
   return linkArray
end fedray_ConstructForkArray

function fedray_ConstructLinkArray federationArray
   local linkArray
   put federationArray ["domain"] into domainArray
   repeat for each key domainName in domainArray
      put domainArray [domainName] into slugArray
      repeat for each key pageSlug in slugArray
         set the cursor to busy
         put domainName & slash & pageSlug into toNodeKey
         --
         put slugArray [pageSlug]["links"] into linkIndex
         repeat for each line linkSlug in linkIndex
            if linkSlug is among the keys of slugArray then
               put domainName & slash & linkSlug into fromNodeKey
            else
               put "external" & slash & linkSlug into fromNodeKey
            end if
            put empty into linkArray [toNodeKey][fromNodeKey]
         end repeat
      end repeat
   end repeat
   return linkArray
end fedray_ConstructLinkArray


--> Fedray | Model
-
function fedray_GetArray pShortFile
   if pShortFile is empty then
      put "federation.array" into pShortFile
   end if
   put the model_Array [pShortFile] of stack "lcw_Server" into federationArray
   return federationArray
end fedray_GetArray

command fedray_SetArray federationArray, pShortFile
   if pShortFile is empty then
      put "federation.array" into pShortFile
   end if
   set the model_Array [pShortFile] of stack "lcw_Server" to federationArray
   put the result into dataFile
   return dataFile
end fedray_SetArray

function fedray_GetArrayFile pShortFile
   if pShortFile is empty then
      put "federation.array" into pShortFile
   end if
   put the model_DataFile [pShortFile] of stack "lcw_Server" into modelDataFile
   return modelDataFile
end fedray_GetArrayFile


--> Fedray | Model | Local
-
function fedray_GetSlugLinks pageSlug, wikiDomain
   --- here we fetch from wards export added locally to the hard disk
   put fedray_GetSitesFolder() & wikiDomain & "/pages/" & pageSlug & "/links.txt" into linksFile
   put url ("file:" & linksFile) into slugLinks
   return word 1 to -1 of slugLinks
end fedray_GetSlugLinks

function fedray_GetSitesFolder
   put "/Users/BabyBlue/Desktop/git-repos/sites/sites/" into sitesFolder
   if there is a folder sitesFolder then
      return sitesFolder
   else
      return empty
   end if
end fedray_GetSitesFolder

function fedwiki_GetFederationDomainArray fedwikiDomain, pShortFile
   -- get a single domain from the stored array
   put fedray_GetArray (pShortFile) into federationArray
   --
   put federationArray ["domain"][fedwikiDomain] into domainArray
   put domainArray into subFederationArray ["domain"]
   put federationArray ["metadata"]["domain"][fedwikiDomain] into subFederationArray ["metadata"]["domain"]
   
   repeat for each key pageSlug in domainArray
      put federationArray ["slug"][pageSlug] into slugArray
      put slugArray into subFederationArray ["slug"][pageSlug]
   end repeat
   return subFederationArray
end fedwiki_GetFederationDomainArray

command fedwiki_SetFederationDomainArray fedwikiDomain, pShortFile
   -- add a single domain to the stored array
   put fedray_GetArray (pShortFile) into federationArray
   fedwiki_SetFederationArrayDomains federationArray, fedwikiDomain
   fedray_SetArray federationArray, pShortFile
end fedwiki_SetFederationDomainArray

command fedwiki_SetFederationArrayDomains @federationArray, fedwikiDomains
   -- slow!!
   -- add an index of domains to the stored array (for instance all of them!)
   repeat for each line fedwikiDomain in fedwikiDomains
      set the cursor to busy
      fedwiki_DeleteDomainFromFederationArray federationArray, fedwikiDomain
      _AddDomainToArray federationArray, fedwikiDomain
      fedwiki_AddDomainMetadata federationArray, fedwikiDomain
   end repeat
end fedwiki_SetFederationArrayDomains

function fedwiki_ExtractDomainNames federationArray
   put federationArray ["domain"] into domainArray
   put keys (domainArray) into domainNames
   sort domainNames
   return domainNames
end fedwiki_ExtractDomainNames

function fedray_ListAllDomainNames   
   put fedray_GetSitesFolder() into sitesFolder
   put folders (sitesFolder) into fedrayDomains
   
   -- let's add all the domains on the Atoia server which may not be indexed
   put atopia_FetchAllFolderList() into atopiaDomains
   repeat for each line atopiaDomain in atopiaDomains
      if atopiaDomain is not among the lines of fedrayDomains then
         put atopiaDomain & CR before fedrayDomains
      end if
   end repeat
   sort fedrayDomains
   if line 1 of fedrayDomains = ".." then delete line 1 of fedrayDomains
   return word 1 to -1 of fedrayDomains
end fedray_ListAllDomainNames


--> Fedray | Add
-
command fedray_AddOwnershipArray ownershipArray, pShortFile
   put fedray_GetArray (pShortFile) into fedArray
   --
   repeat for each key ownerEmail in ownershipArray
      put ownershipArray [ownerEmail]["domains"] into indexedDomainArray
      repeat for each key indexNum in indexedDomainArray
         put indexedDomainArray [indexNum]["domain"] into domainName
         put indexedDomainArray [indexNum]["ownerArray"] into ownerArray
         --
         put ownerArray into fedArray ["metadata"]["domain"][domainName]["ownerArray"]
         put ownerEmail into fedArray ["metadata"]["domain"][domainName]["ownerEmail"]
      end repeat
   end repeat
   --
   fedray_SetArray fedArray, shortFile
   return fedArray
end fedray_AddOwnershipArray

command fedwiki_AddDomainsToFederationArray @federationArray, fedwikiDomains, pReindex
   repeat for each line fedwikiDomain in fedwikiDomains
      set the cursor to busy
      if pReindex is not true then
         if fedwikiDomain is among the keys of federationArray then
            -- don't index twice
            next repeat
         end if
      end if
      _AddDomainToArray federationArray, fedwikiDomain
   end repeat
end fedwiki_AddDomainsToFederationArray

command fedwiki_AddForksToDomainArray @federationArray, fedwikiDomain
   put federationArray ["domain"][fedwikiDomain] into slugArray
   repeat for each key pSlug in slugArray
      fedwiki_AddSlugForksToDomainArray federationArray, fedwikiDomain, pSlug
   end repeat
end fedwiki_AddForksToDomainArray

command fedwiki_AddSlugForksToDomainArray @federationArray, fedwikiDomain, pSlug
   put fedwiki_FetchPageJSON (fedwikiDomain, pSlug) into pageJSON
   put json_ToArray (pageJson) into pageArray
   put pageArray ["journal"] into journalArray
   put item 2 of the extents of journalArray into lastJournalNum
   put 1 into newItemNum
   repeat with jNum = 1 to lastJournalNum
      set the cursor to busy
      --
      put journalArray [jNum] into itemArray
      if itemArray ["type"] = "fork" then
         /*
         "type": "fork",
         "site": "tools.progressivedemocracy.cc",
         "date": 1512130297675
         */
         put itemArray ["site"] into fromSite
         if fromSite is empty then next repeat -- self-fork
         --
         put fromSite into federationArray ["domain"][fedwikiDomain][pSlug]["fork"][newItemNum]["domain"]
         put itemArray ["date"] into federationArray ["domain"][fedwikiDomain][pSlug]["fork"][newItemNum]["date"]
         add 1 to newItemNum
      end if
   end repeat
end fedwiki_AddSlugForksToDomainArray

command fedwiki_AddSlugArrayToFederationArray @federationArray, sitemapArray, fedwikiDomain
   put item 2 of the extents of sitemapArray into maxNum
   put 0 into maxUpdate
   repeat with indexNum = 1 to maxNum
      -- put sitemapArray [indexNum]["title"] into pageTitle
      -- put sitemapArray [indexNum]["synopsis"] into pageSynopsis
      --
      put sitemapArray [indexNum]["slug"] into pageSlug
      put sitemapArray [indexNum]["date"] into lastUpdate
      if lastUpdate > maxUpdate then
         put lastUpdate into maxUpdate
      end if
      put lastUpdate into federationArray ["domain"][fedwikiDomain][pageSlug]["date"]
      put lastUpdate into federationArray ["slug"][pageSlug][fedwikiDomain]["date"]
      
      -- now add fork from the page slug
      fedwiki_AddSlugForksToDomainArray federationArray, fedwikiDomain, pageSlug
      
      -- now fetch local links (from wards scrape) and add to array
      put fedray_GetSlugLinks (pageSlug, fedwikiDomain) into slugLinks
      if slugLinks is not empty then
         put slugLinks into federationArray ["domain"][fedwikiDomain][pageSlug]["links"]
      end if
   end repeat
   return maxUpdate
end fedwiki_AddSlugArrayToFederationArray

command fedwiki_AddDomainMetadata @federationArray, fedwikiDomain
   put fedwiki_FetchOwnerName (fedwikiDomain) into ownerName
   put ownerName into federationArray ["metadata"]["domain"][fedwikiDomain]["ownerName"]
   put dig_GetIP (fedwikiDomain) into someIP
   put someIP into federationArray ["metadata"]["domain"][fedwikiDomain]["ipAddress"]
end fedwiki_AddDomainMetadata

command fedwiki_AddForksFederationArray @federationArray
   put federationArray ["domain"] into domainArray
   repeat for each key fedwikiDomain in domainArray
      fedwiki_AddForksToDomainArray federationArray, fedwikiDomain
   end repeat
end fedwiki_AddForksFederationArray


--> Fedray | Add
-
command fedwiki_DeleteDomainFromFederationArray @federationArray, wikiDomain
   delete variable federationArray ["domain"][wikiDomain]
   delete variable federationArray ["metadata"]["domain"][wikiDomain]
   put federationArray ["slug"] into slugArray
   repeat for each key pSlug in slugArray
      set the cursor to busy
      delete variable federationArray ["slug"][pSlug][wikiDomain]
   end repeat
end fedwiki_DeleteDomainFromFederationArray


--> Private
-
private command _AddDomainToArray @federationArray, fedwikiDomain
   put fedwiki_FetchSitemap (fedwikiDomain) into sitemapJSON
   put json_ToArray (sitemapJSON) into sitemapArray
   put item 2 of the extents of sitemapArray into maxNum
   if maxNum > 1 then
      fedwiki_AddSlugArrayToFederationArray federationArray, sitemapArray, fedwikiDomain
      put the result into lastSiteUpdate
      put lastSiteUpdate into federationArray ["metadata"]["domain"][fedwikiDomain]["lastSiteUpdate"]
   end if
end _AddDomainToArray


