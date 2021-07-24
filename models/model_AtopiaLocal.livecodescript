script "model_AtopiaLocal"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: model_AtopiaLocal
type: model
version: 0.1


/*
This model is old.
It is for storing a local database which we can process faster before saving online.
Use "medel_Atopia" instead.
*/


--> Working on
-
/*
Stored locally for now.
Will probably move to an online wiki based array storage.
Used for creating author rosters
*/

--> Atopia | Update
-
command atopia_UpdateArrayAndMove pWikiFolders
   -- this should step through all tests and update everything
   -- moving folders to trash or unhosted as needed
   
   -- defaults to processing new folders
   if pWikiFolders is empty then
      put atopia_FetchNewRosterFolders() into pWikiFolders
   end if
   put atopia_GetData() into atopiaData
   
   -- let's update bad ones
   -- first check how many wiki pages each domain has
   atopia_AddToDomainErrorArray atopiaData, pWikiFolders
   put the result into addedBadFolders
   -- finally move bad ones we added to trash
   atopia_MoveAllBadFoldersToTrash addedBadFolders
   put the result into missingFolders
   if missingFolders is not empty then
      breakpoint
      -- it should not be
      put missingFolders into resultArray ["missingFolders"]
   end if
   put addedBadFolders into resultArray ["addedBadFolders"]
   
   -- now let's check that the good folders left are hosted
   put pWikiFolders into newGoodFoldersleft
   line_DeleteIndex newGoodFoldersleft, addedBadFolders
   if newGoodFoldersleft is empty then return resultArray
   
   -- now let's move those unhosted folders
   atopia_MoveGoodToUnhosted newGoodFoldersleft
   put the result into movedToUnhosted
   put movedToUnhosted into resultArray ["movedToUnhosted"]
   
   -- perhaps removed a few more
   line_DeleteIndex newGoodFoldersleft, movedToUnhosted
   if newGoodFoldersleft is empty then return resultArray
   
   -- now we have the good new folders
   -- from here we add them to local good folder store
   -- the bad ones should already be moved
   -- these three sstages could be done as one write to the database
   put atopia_GetData() into atopiaData
   atopia_AddToDomainErrorArray atopiaData, newGoodFoldersleft
   atopia_SetData atopiaData
   
   -- and update the ownership and dns array entries
   --
   -- now update the ownershipArray for the hosted good folders
   put atopia_GetLocalEmailOwnerData() into ownershipArray
   atopia_AddOwnershipToDomainArray ownershipArray, newGoodFoldersleft
   atopia_SetLocalEmailOwnerData ownershipArray
   put newGoodFoldersleft into resultArray ["newGoodFoldersAdded"]
   
   -- and add DNS entries
   put atopia_GetDomainDnsArray() into dnsArray
   atopia_AddDnsToDomainArray dnsArray, newGoodFoldersleft
   atopia_SetDomainDnsArray dnsArray
   
   return resultArray
end atopia_UpdateArrayAndMove

command atopia_MoveAllBadFoldersToTrash pBadFolders
   if pBadFolders is empty then
      put atopia_ListLocalBadFolders() into pBadFolders
   end if
   --
   put atopia_FetchFilteredFolderLsArray() into remoteFolderArray
   repeat for each line badFolderName in pBadFolders
      set the cursor to busy
      put badFolderName
      if atopia_RemoteWikiFolderExists (badFolderName, remoteFolderArray) is false then
         breakpoint
         put badFolderName & CR after missingFolders
         next repeat
      end if
      --
      atopia_MoveToTrash badFolderName
      put the result into atopiaData
      --
      put the result into atopiaData
   end repeat
   delete char -1 of missingFolders
   return missingFolders
end atopia_MoveAllBadFoldersToTrash

command atopia_MoveGoodToUnhosted pGoodFolders, pForce
   if pGoodFolders is empty then
      put atopia_ListLocalGoodFolders() into pGoodFolders
   end if
   --
   put atopia_GetData() into atopiaData
   put atopia_GetIP() into dropletIP
   --
   repeat for each line goodShortFolder in pGoodFolders
      set the cursor to busy
      put goodShortFolder
      --
      put dig_GetIP (goodShortFolder) into testIP
      --
      if testIP = dropletIP then
         -- it's good so let's add some DNS information for fun
         _AddDnsToAtopiaArray atopiaData, goodShortFolder, testIP
      else
         -- let's move it
         atopia_MoveToUnhosted goodShortFolder
         --
         put goodShortFolder & CR after goodFoldersMoved
         put the result into atopiaData
      end if
   end repeat
   delete char -1 of goodFoldersMoved
   return goodFoldersMoved
end atopia_MoveGoodToUnhosted


--> Fedray | Add
-
command fedray_AddOwnershipArray ownershipArray, pShortFile
   put fedray_GetArray (pShortFile) into fedray
   --
   repeat for each key ownerEmail in ownershipArray
      put ownershipArray [ownerEmail]["domains"] into indexedDomainArray
      repeat for each key indexNum in indexedDomainArray
         put indexedDomainArray [indexNum]["domain"] into domainName
         put indexedDomainArray [indexNum]["ownerArray"] into ownerArray
         --
         put ownerArray into fedray ["metadata"]["domain"][domainName]["ownerArray"]
         put ownerEmail into fedray ["metadata"]["domain"][domainName]["ownerEmail"]
      end repeat
   end repeat
   --
   fedray_SetArray fedray, shortFile
   return fedray
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

command fedwiki_AddDomainMetadata @federationArray, fedwikiDomain
   put fedwiki_FetchOwnerName (fedwikiDomain) into ownerName
   put ownerName into federationArray ["metadata"]["domain"][fedwikiDomain]["ownerName"]
   put dig_GetIP (fedwikiDomain) into someIP
   put someIP into federationArray ["metadata"]["domain"][fedwikiDomain]["ipAddress"]
end fedwiki_AddDomainMetadata


--> Fedray | Forks | Create
-
command fedwiki_AddForksFederationArray @federationArray
   put federationArray ["domain"] into domainArray
   repeat for each key fedwikiDomain in domainArray
      fedwiki_AddForksToDomainArray federationArray, fedwikiDomain
   end repeat
end fedwiki_AddForksFederationArray

command fedwiki_AddForksToDomainArray @federationArray, fedwikiDomain
   put federationArray ["domain"][fedwikiDomain] into slugArray
   repeat for each key pSlug in slugArray
      fedwiki_AddSlugForksToDomainArray federationArray, fedwikiDomain, pSlug
   end repeat
end fedwiki_AddForksToDomainArray

command fedwiki_AddSlugForksToDomainArray @federationArray, fedwikiDomain, pSlug
   put pageArray_Fetch (fedwikiDomain, pSlug) into pageArray
   put pageArray ["journal"] into journalArray
   put item 2 of the extents of journalArray into lastJournalNum
   put 1 into newItemNum
   repeat with jNum = 1 to lastJournalNum
      set the cursor to busy
      --
      put journalArray [jNum] into itemArray
      if itemArray ["type"] = "fork" then
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
      put atopia_FetchFarmStatus (domainName, nsType) into isFarm
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


--> Fedray | Fork
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
   put atopia_FetchFolders() into atopiaDomains
   repeat for each line atopiaDomain in atopiaDomains
      if atopiaDomain is not among the lines of fedrayDomains then
         put atopiaDomain & CR before fedrayDomains
      end if
   end repeat
   sort fedrayDomains
   if line 1 of fedrayDomains = ".." then delete line 1 of fedrayDomains
   return word 1 to -1 of fedrayDomains
end fedray_ListAllDomainNames


--> Fedray | Delete
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


--> Atopia | Model
-
/*
These models are stored and prcessed locally.
Models should use model_Array, rather than user_GetArray
*/

function atopia_GetData
   put user_GetArray ("atopia_FetchError.array") into atopiaData
   return atopiaData
end atopia_GetData

command atopia_SetData atopiaData
   atopia_FilterGoodAndBad atopiaData -- just in case???
   user_SetArray "atopia_FetchError.array", atopiaData
   put the result into modelDataFile
   return modelDataFile
end atopia_SetData


--> Atopia | Model | Wrappers
-
function atopia_GetArray topKey
   put atopia_GetData() into atopiaData
   put atopiaData [topKey] into atopiaArray
   return atopiaArray
end atopia_GetArray

command atopia_SetArray atopiaArray, topKey
   put atopia_GetData() into atopiaData
   put atopiaArray into atopiaData [topKey]
   atopia_SetData atopiaData
   put the result into modelDataFile
   return modelDataFile
end atopia_SetArray

function atopia_GetDomainDnsArray
   put atopia_GetArray ("dns") into dnsArray
   return dnsArray
end atopia_GetDomainDnsArray

command atopia_SetDomainDnsArray dnsArray
   atopia_SetArray dnsArray, "dns"
   put the result into modelDataFile
   return modelDataFile
end atopia_SetDomainDnsArray

function atopia_GetGoodDomainArray
   put atopia_GetArray ("good") into goodDomainArray
   return goodDomainArray
end atopia_GetGoodDomainArray

command atopia_SetGoodDomainArray goodDomainArray
   atopia_SetArray goodDomainArray, "good"
   put the result into modelDataFile
   return modelDataFile
end atopia_SetGoodDomainArray


--> Atopia | Model | Filter
-
function atopia_MissingRemoteFolderArray
   -- check if they are still there
   put atopia_ListLocalBadFolders() into badFolders
   put atopia_ListLocalGoodFolders() into goodFolders
   put atopia_FetchFilteredFolderLsArray() into remoteFolderArray
   if item 1 of it is "error" then return empty
   
   -- check local good folder exists
   repeat for each line goodFolder in goodFolders
      put remoteFolderArray [goodFolder] into goodFolderArray
      if goodFolderArray is not an array then
         put goodFolder & CR after notGoodThereIndex 
      end if
   end repeat
   delete char -1 of notGoodThereIndex
   
   -- check local bad folder exists
   repeat for each line badFolder in badFolders
      put remoteFolderArray [badFolder] into badFolderArray
      if badFolderArray is not an array then
         put badFolder & CR after notBadThereIndex 
      end if
   end repeat
   delete char -1 of notBadThereIndex
   
   put notGoodThereIndex into notThereArray ["Local Good folder missing"]
   put notBadThereIndex into notThereArray ["Local Bad folder missing"]
   --
   return notThereArray
end atopia_MissingRemoteFolderArray


--> Atopia | Model | Local | List
-
function atopia_ListLocalWikiFolders pAtopiaData
   -- reconstruct from array  
   if pAtopiaData is empty then
      put atopia_GetData() into pAtopiaData
   end if
   if pAtopiaData is empty then return empty -- ideally should not be?
   
   put atopia_GetLocalGoodArray (pAtopiaData) into allArray
   put atopia_GetLocalBadArray (pAtopiaData) into badArray
   union allArray with badArray
   
   -- make a cononical sorted list
   put keys (allArray) into allFolderNames
   url_SortDomainIndex allFolderNames, true
   return word 1 to -1 of allFolderNames
end atopia_ListLocalWikiFolders

function atopia_ListLocalGoodFolders
   put atopia_GetLocalGoodArray() into goodArray
   if goodArray is empty then return empty -- ideally should not be?
   --
   put keys (goodArray) into goodFolderNames
   url_SortDomainIndex goodFolderNames, true
   return word 1 to -1 of goodFolderNames
end atopia_ListLocalGoodFolders

function atopia_ListLocalBadFolders
   put atopia_GetLocalBadArray() into badArray
   if badArray is empty then return empty -- ideally should not be?
   --
   put keys (badArray) into badFolderNames
   url_SortDomainIndex badFolderNames, true
   return word 1 to -1 of badFolderNames
end atopia_ListLocalBadFolders

function atopia_ListLocalUnhostedFolders
   put atopia_GetLocalUnhostedArray() into unhostedArray
   if unhostedArray is empty then return empty -- ideally should not be?
   --
   put keys (unhostedArray) into unhostedFolders
   url_SortDomainIndex unhostedFolders, true
   return word 1 to -1 of unhostedFolders
end atopia_ListLocalUnhostedFolders


--> Atopia | Model | Local | Remove
-
/*
Remove from daomainArray
*/

command atopia_RemoveLocalBad badDomainName
   put atopia_GetData() into atopiaData
   delete variable atopiaData ["bad"][badDomainName]
   atopia_SetData atopiaData
end atopia_RemoveLocalBad


--> Atopia | Model | Local | Wrappers
-
function atopia_GetLocalGoodArray pAtopiaData
   if pAtopiaData is empty then
      put atopia_GetData() into pAtopiaData
   end if
   put pAtopiaData ["good"] into goodArray
   return goodArray
end atopia_GetLocalGoodArray

function atopia_GetLocalBadArray pAtopiaData
   if pAtopiaData is empty then
      put atopia_GetData() into pAtopiaData
   end if
   put pAtopiaData ["bad"] into badArray
   return badArray
end atopia_GetLocalBadArray

function atopia_GetLocalUnhostedArray pAtopiaData
   if pAtopiaData is empty then
      put atopia_GetData() into pAtopiaData
   end if
   put pAtopiaData ["_unhosted_sites"] into unhostedArray
   return unhostedArray
end atopia_GetLocalUnhostedArray


--> Filter
-
command atopia_FilterAllFolderArray @folderArray
   -- let's filter
   repeat for each key folderName in folderArray
      switch
         case folderName begins with "."
         case folderName begins with "_"
         case folderName is among the items of ReservedFolderNames
            delete variable folderArray [folderName]
            put folderName & CR after removedFolderNames
            break
         default
            -- it's ok
      end switch
   end repeat
   delete char -1 of removedFolderNames
   return removedFolderNames
end atopia_FilterAllFolderArray


--> Private
-
private command atopia_FilterGoodAndBad @atopiaData
   repeat for each item keyName in "good,bad"
      put atopiaData [keyname] into goodArray
      atopia_FilterAllFolderArray goodArray
      put the result into filteredDomainNames
      put goodArray into atopiaData [keyname]
      put filteredDomainNames & CR after filteredNames
   end repeat
   delete char -1 of filteredNames
   return filteredNames
end atopia_FilterGoodAndBad
