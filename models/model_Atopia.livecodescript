script "model_Atopia"
--> MetaData
-
license: GPLv3
name: model_Atopia
type: model
version: 0.1

/*
Here we provide handlers to build and do CRUD operations on the Atopia Fedwiki server wiki model.

All the constants below are only used by handlers in this model.

config.json is not a folder and should not show up in any case. Keep here just in case
Rename fedwiki_owners when we have automatic control over owner files
*/

constant AtopiaModelShortFile = "atopia_FetchError.array"
constant AtopiaDropletName = "Atopia"
constant AtopiaSshUser = "root"
constant ReservedFolderNames = "_old_sites,_unhosted_sites,_trash,fedwiki_owners"


--> Working on
-
-- command atopia_FilterWikiFolders @wikiFolders
-- overkill to be safe
-- should not need
breakpoint

repeat for each item rName in ReservedFolderNames
   line_Delete rName, wikiFolders
end repeat
filter wikiFolders without "_*"
end atopia_FilterWikiFolders


--> Atopia | Model | Build
-
command atopia_UpdateDomainErrorArray pWikiFolders
   if pWikiFolders is empty then
      put atopia_FetchNewFolderList() into pWikiFolders
   end if
   put atopia_GetDomainErrorArray() into domainErrorArray
   --
   repeat for each line wikiFolder in pWikiFolders
      atopia_AddToDomainErrorArray domainErrorArray, wikiFolder
   end repeat
   --
   atopia_SetDomainErrorArray domainErrorArray
   return domainErrorArray
end atopia_UpdateDomainErrorArray

command atopia_AddToDomainErrorArray @domainErrorArray, wikiFolders, pMinNum
   if pMinNum is empty then put 1 into pMinNum
   
   repeat for each line wikiFolder in wikiFolders
      set the cursor to busy
      if wikiFolder is among the items of ReservedFolderNames then next repeat
      --
      put atopia_FetchWikiPageList (wikiFolder) into wikiPages
      if the number of lines of wikiPages > pMinNum then
         put wikiPages into domainErrorArray ["good"][wikiFolder]
      else
         put wikiPages into domainErrorArray ["bad"][wikiFolder]
      end if
      add 1 to lineNum
   end repeat
   
   -- not needed now?
   put atopia_ConstructErrorArrayIndexArray (domainErrorArray, pMinNum) into domainInfoArray
   put domainInfoArray into domainErrorArray ["info"]
end atopia_AddToDomainErrorArray

function atopia_ConstructDomainOwnershipArray wikiFolders, pConfigArray
   local indexedArray, domainOwnershipArray
   
   if pConfigArray is not an array then
      put atopia_FetchConfigArray() into pConfigArray
   end if
   
   repeat for each line wikiFolder in wikiFolders
      set the cursor to busy
      --
      put atopia_FindOwnerArray (wikiFolder, pConfigArray) into ownerArray
      --
      put fedwiki_GetOwnerEmail (ownerArray) into ownerEmail
      if ownerEmail is empty then
         put "No email" into ownerEmail
      end if
      
      put domainOwnershipArray [ownerEmail]["domains"] into indexedArray
      --
      array_AddToNumbered indexedArray, "domain", wikiFolder
      put the result into newIndexNum
      put ownerArray into indexedArray [newIndexNum]["ownerArray"]
      --
      put indexedArray into domainOwnershipArray [ownerEmail]["domains"]
   end repeat
   return domainOwnershipArray
end atopia_ConstructDomainOwnershipArray

function atopia_ConstructErrorArrayIndexArray domainErrorArray, pMinNum
   /*
   This is a crappy way to index things
   Use numbered arrays instead.
   Given that each domain must be unique, we don;t need to care about the order?
   */
   
   put atopia_ListDomainFolders (domainErrorArray) into wikiFolders
   put 1 into lineNum
   repeat for each line wikiFolder in wikiFolders
      put atopia_DomainIsBad (wikiFolder, domainErrorArray) into isBad
      if isBad is true then
         put lineNum & comma after badNums
      else
         put lineNum & comma after goodNums
      end if
      add 1 to lineNum
   end repeat
   
   put pMinNum into domainInfoArray ["minNum"]
   put goodNums into domainInfoArray ["goodNums"]
   put badNums into domainInfoArray ["badNums"]
   return domainInfoArray
end atopia_ConstructErrorArrayIndexArray

function atopia_FetchAndBuildArray pMinNum, pWikiFolders
   -- really, really slow (consider using cli "tree" thing)
   
   if pMinNum is empty then put 1 into pMinNum
   if pWikiFolders is empty then
      put atopia_FetchAllFolderList() into pWikiFolders
   end if
   
   put 1 into lineNum
   repeat for each line wikiFolder in pWikiFolders
      set the cursor to busy
      if wikiFolder is among the items of ReservedFolderNames then next repeat
      put wikiFolder
      --
      put atopia_FetchWikiPageList (wikiFolder) into wikiPages
      if the number of lines of wikiPages > pMinNum then
         put lineNum & comma after goodNums
         put wikiPages into domainErrorArray ["good"][wikiFolder]
      else
         put lineNum & comma after badNums
         put wikiPages into domainErrorArray ["bad"][wikiFolder]
      end if
      add 1 to lineNum
   end repeat
   
   put pMinNum into domainErrorArray ["info"]["minNum"]
   put goodNums into domainErrorArray ["info"]["goodNums"]
   put badNums into domainErrorArray ["info"]["badNums"]
   return domainErrorArray
end atopia_FetchAndBuildArray


--> Atopia | Model | Move
-
command atopia_MoveAllBadFoldersToTrash
   put atopia_ListBadFolders() into badFolders
   --
   put atopia_FetchFilteredFolderLsArray() into remoteFolderArray
   repeat for each line badFolderName in badFolders
      set the cursor to busy
      put badFolderName
      if atopia_RemoteWikiFolderExists (badFolderName, remoteFolderArray) is false then
         breakpoint
         put badFolderName & CR after missingFolderNames
         next repeat
      end if
      --
      atopia_MoveToTrash badFolderName
      --
      put the result into domainErrorArray
   end repeat
   return missingFolderNames
end atopia_MoveAllBadFoldersToTrash

command atopia_MoveToTrash shortWikiFolder 
   put atopia_GetDomainErrorArray() into domainErrorArray
   
   -- let's do lot's of checks
   if shortWikiFolder is empty then
      breakpoint
      return empty
   end if
   -- we are assuming it is a bad folder
   if atopia_DomainIsBad (shortWikiFolder, domainErrorArray) is false then
      put "This wiki is not bad!" into someQuestion
      lcw_AnswerSheet someQuestion, empty, true
      exit to top
   end if
   --
   -- /root/.wiki/sub.domain.wiki/ -- absolute path for safety
   put atopia_WikiDomainFolder (shortWikiFolder) into domainFolder
   if domainFolder begins with "/root/.wiki/" is false then
      breakpoint
      return empty
   end if
   
   put atopia_TrashFolder() into trashFolder
   put "mv" && domainFolder && trashFolder into remoteShell
   --
   atopia_DoRemoteShell remoteShell
   put the result into moveResult
   if moveResult is not empty then
      put moveResult
      lcw_WarnAndExit "Fail to move domain to wiki_trash folder"
   end if
   
   -- tidy domainErrorArray
   put domainErrorArray ["bad"][shortWikiFolder] into badFolderWikiFiles -- probably empty
   delete variable domainErrorArray ["bad"][shortWikiFolder]
   put badFolderWikiFiles into domainErrorArray ["_trash"][shortWikiFolder]
   --
   atopia_SetDomainErrorArray domainErrorArray
   --
   return domainErrorArray
end atopia_MoveToTrash

command atopi_MoveGoodToUnhosted
   put atopia_ListGoodFolders() into goodFolders
   put atopia_GetDomainErrorArray() into domainErrorArray
   put digitalOcean_GetDropletIP (AtopiaDropletName) into dropletIP
   --
   repeat for each line goodShortFolder in goodFolders
      set the cursor to busy
      put goodShortFolder
      --
      put dig_GetIP (goodShortFolder) into testIP
      --
      if testIP = dropletIP then
         -- it's good
         put dig_GetNS (goodShortFolder) into domainErrorArray ["dns"][goodShortFolder]["NS"]
         put testIP into domainErrorArray ["dns"][goodShortFolder]["A record"]
         atopia_SetDomainErrorArray domainErrorArray -- in case we crash :)
      else
         -- let's move it
         atopia_MoveToUnhosted goodShortFolder
         put the result into domainErrorArray
         
         /*
         put domainErrorArray ["good"][goodShortFolder] into goodPageIndex
         put goodPageIndex into domainErrorArray ["unhosted"][goodShortFolder]
         delete variable domainErrorArray ["good"][goodShortFolder]
         */     
      end if
   end repeat
   return domainErrorArray
end atopi_MoveGoodToUnhosted

command atopia_MoveToUnhosted shortWikiFolder
   put atopia_GetDomainErrorArray() into domainErrorArray
   
   -- let's do lot's of checks
   if shortWikiFolder is empty then
      breakpoint
      put "The wiki domain is empty!" into someQuestion
      lcw_WarnAndExit someQuestion
   end if
   -- /root/.wiki/sub.domain.wiki/ -- absolute path for safety
   put atopia_WikiDomainFolder (shortWikiFolder) into domainFolder
   if domainFolder begins with "/root/.wiki/" is false then
      breakpoint
      put "The wiki domain is invalid!" into someQuestion
      lcw_WarnAndExit someQuestion
   end if
   
   -- we are assuming it is a good folder
   get atopia_DomainIsBad (shortWikiFolder, domainErrorArray)
   if it is true then
      put "This wiki is not good!" into someQuestion
      lcw_WarnAndExit someQuestion
   end if
   
   -- it must have NOT a valid A record
   put dig_GetIP (shortWikiFolder) into aRecord
   put digitalOcean_GetDropletIP (AtopiaDropletName) into dropletIP
   if aRecord = dropletIP then
      put aRecord
      put "This wiki is hosted on Atopia!" into someQuestion
      lcw_WarnAndExit someQuestion
   end if
   
   --
   put atopia_UnhostedFolder() into unhostedFolder
   put "mv" && domainFolder && unhostedFolder into remoteShell
   atopia_DoRemoteShell remoteShell
   put the result into moveResult
   if moveResult is not empty then
      put moveResult
      lcw_WarnAndExit "Fail to move domain to wiki_trash folder"
   end if
   --
   
   -- tidy domainErrorArray
   put domainErrorArray ["good"][shortWikiFolder] into goodPageIndex
   put goodPageIndex into domainErrorArray ["_unhosted_sites"][shortWikiFolder] 
   delete variable domainErrorArray ["good"][shortWikiFolder]
   --
   atopia_SetDomainErrorArray domainErrorArray
   --
   return domainErrorArray
end atopia_MoveToUnhosted


--> Atopia | Check
-
function atopia_DomainIsBad folderName, domainErrorArray
   put domainErrorArray ["good"] into goodArray
   put domainErrorArray ["bad"] into badArray
   
   set the caseSensitive to true
   put folderName is among the keys of badArray into isBad
   put folderName is among the keys of goodArray into isGood
   
   if isGood and isbad is true then
      breakpoint -- shoud be one or the other
      return false
   else if isGood is true then
      return false
   else if isBad is true then
      return true
   end if
end atopia_DomainIsBad

function atopia_RemoteWikiFolderExists folderName, pRemoteFolderArray
   if pRemoteFolderArray is empty then
      put atopia_FetchFilteredFolderLsArray() into pRemoteFolderArray
   end if
   
   put folderName is among the keys of pRemoteFolderArray into remoteExists
   return remoteExists
end atopia_RemoteWikiFolderExists

function atopia_CheckUnhosted goodFolders
   put digitalOcean_GetDropletIP (AtopiaDropletName) into dropletIP
   repeat for each line goodShortFolder in goodFolders
      set the cursor to busy
      put goodShortFolder
      --
      put dig_GetIP (goodShortFolder) into testIP
      put dig_GetNS (goodShortFolder) into testDNS
      --
      if testIP = dropletIP then
         -- it's good
         put testDNS into dnsArray ["good ip"][goodShortFolder]["NS"]
         put testIP into dnsArray ["good ip"][goodShortFolder]["A record"]
      else
         put testDNS into dnsArray ["bad ip"][goodShortFolder]["NS"]
         put testIP into dnsArray ["bad ip"][goodShortFolder]["A record"]
      end if
   end repeat
   return dnsArray
end atopia_CheckUnhosted


--> Atopia | Model | Filter
-
function atopia_MissingRemoteFolderArray
   -- check if they are still there
   put atopia_ListBadFolders() into badFolders
   put atopia_ListGoodFolders() into goodFolders
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


--> Atopia | Model | Local
-
function atopia_GetDomainErrorArray
   put user_GetArray (AtopiaModelShortFile) into domainErrorArray
   return domainErrorArray
end atopia_GetDomainErrorArray

command atopia_SetDomainErrorArray domainErrorArray
   atopia_FilterGoodAndBad domainErrorArray -- just in case???
   user_SetArray AtopiaModelShortFile, domainErrorArray
   put the result into modelDataFile
   return modelDataFile
end atopia_SetDomainErrorArray

function atopia_GetDomainOwnershipArray
   put user_GetArray (AtopiaModelShortFile) into domainErrorArray
   put domainErrorArray ["owner"] into domainOwnershipArray
   return domainOwnershipArray
end atopia_GetDomainOwnershipArray

command atopia_SetDomainOwnershipArray domainOwnershipArray
   put user_GetArray (AtopiaModelShortFile) into domainErrorArray
   put domainOwnershipArray into domainErrorArray ["owner"]
   user_SetArray AtopiaModelShortFile, domainErrorArray
   put the result into modelDataFile
   return modelDataFile
end atopia_SetDomainOwnershipArray

private command atopia_FilterGoodAndBad @domainErrorArray
   repeat for each item keyName in "good,bad"
      put domainErrorArray [keyname] into goodArray
      atopia_FilterAllFolderArray goodArray
      put the result into filteredDomainNames
      put goodArray into domainErrorArray [keyname]
      put filteredDomainNames & CR after filteredNames
   end repeat
   delete char -1 of filteredNames
   return filteredNames
end atopia_FilterGoodAndBad


--> Atopia | Model | Fetch
-
function atopia_FetchNewFolderList
   -- prefer to use arrays as faster
   -- put atopia_FetchAllFolderList() into remoteDomainNames
   
   put atopia_FetchFilteredFolderLsArray() into remoteFolderArray
   if item 1 of it is "error" then return empty
   
   put atopia_ListDomainFolders() into localDomainNames
   
   -- let's remove localDomainNames
   repeat for each line localDomainName in localDomainNames
      delete variable remoteFolderArray [localDomainName]
   end repeat
   
   -- extract new folders
   put keys (remoteFolderArray) into newRemoteDomains
   url_SortDomainIndex newRemoteDomains, true
   return newRemoteDomains
end atopia_FetchNewFolderList


--> Atopia | Model | Fetch | Page
-
function atopia_FetchWikiPageList wikiDomain
   put atopia_FetchWikiPageFileArray (wikiDomain) into fileArray
   put keys (fileArray) into wikiPages
   return wikiPages
end atopia_FetchWikiPageList

function atopia_FetchWikiPageFileArray wikiDomain
   -- fetch a list of files in the pages folder of an individual wiki domain folder
   put fedwiki_PagesFolder (wikiDomain) into serverPath
   put atopia_FetchLsArray (serverPath) into infoArray
   put infoArray ["file"] into fileArray
   return fileArray
end atopia_FetchWikiPageFileArray

function atopia_FetchDomainLsArray wikiDomain
   -- fetch a file+folder array for an individual wiki domain folder
   
   put atopia_WikiDomainFolder (wikiDomain) into serverPath
   put atopia_FetchLsArray (serverPath) into fileArray 
   return fileArray
end atopia_FetchDomainLsArray


--> Atopia | Model | Fetch | Folders
-
function atopia_FetchAllFolderList
   -- fetch all folders, then filter out reserved names
   put atopia_FetchFilteredFolderLsArray() into folderArray
   put keys (folderArray) into wikiDomains
   url_SortDomainIndex wikiDomains, true
   return wikiDomains
end atopia_FetchAllFolderList

function atopia_FetchReservedFoldersList
   -- here we fetch a list of all the reserved folders that filtering will remove
   -- can use to check / visualise how the efiltering works
   put atopia_FetchWikiRootLsFolderArray() into filteredFolderArray
   atopia_FilterAllFolderArray filteredFolderArray
   put the result into removedFolderNames
   return removedFolderNames
end atopia_FetchReservedFoldersList

function atopia_FetchFilteredFolderLsArray
   put atopia_FetchWikiRootLsFolderArray() into filteredFolderArray
   atopia_FilterAllFolderArray filteredFolderArray
   return filteredFolderArray
end atopia_FetchFilteredFolderLsArray

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

function atopia_FetchWikiRootLsFolderArray
   put fedwiki_WikiRootFolder() into wikiRootFolder
   put atopia_FetchLsArray (wikiRootFolder) into infoArray
   put infoArray ["folder"] into folderArray
   return folderArray
end atopia_FetchWikiRootLsFolderArray

function atopia_FetchLsArray serverPath
   put digitalOcean_GetDropletIP (AtopiaDropletName) into dropletIP
   --
   put server_FetchFileList (dropletIP, serverPath, true, AtopiaSshUser) into lsResult
   put shell_ConstructLSArray (lsResult, true) into infoArray
   --
   return infoArray
end atopia_FetchLsArray


--> Atopia | Model | Fetch | JSON
-
function atopia_FetchOwnerJson wikiDomain
   put atopia_WikiStatusFolder (wikiDomain) into wikiStatusFolder
   put wikiStatusFolder & "owner.json" into ownerJsonPath
   
   put digitalOcean_FetchFile (ownerJsonPath, AtopiaDropletName, AtopiaSshUser) into someJSON
   return someJSON
end atopia_FetchOwnerJson

function atopia_FetchConfigJSON
   put ".wiki/config.json" into somePath
   put digitalOcean_FetchFile (somePath, AtopiaDropletName, AtopiaSshUser) into someJSON
   return someJSON
end atopia_FetchConfigJSON

function atopia_FetchWikiJson wikiPageSlug, fedwikiDomain
   -- was "fedwiki_FetchRemoteFile"
   put fedwiki_ConstructPath (fedwikiDomain, wikiPageSlug) into wikiPagePath
   put digitalOcean_FetchFile (wikiPagePath, AtopiaDropletName, AtopiaSshUser) into someJSON
   return someJSON
end atopia_FetchWikiJson


--> Atopia | Model | Files and Folders
-
function atopia_WikiStatusFolder wikiDomain
   -- absolute path for safety
   put atopia_WikiDomainFolder (wikiDomain) & "/status/" into wikiStatusFolder
   return wikiStatusFolder
end atopia_WikiStatusFolder

function atopia_UnhostedFolder
   return "/root/.wiki/_unhosted_sites/"
end atopia_UnhostedFolder

function atopia_TrashFolder
   -- hard wired absolute path for safety
   return "/root/.wiki/_trash/"
end atopia_TrashFolder

function atopia_WikiDomainFolder wikiDomain
   -- absolute path for safety
   put "/root/.wiki/" & wikiDomain & slash into domainFolder
   return domainFolder
end atopia_WikiDomainFolder

function atopia_WikiPageFolder wikiDomain
   -- absolute path for safety
   put atopia_WikiDomainFolder (wikiDomain) & "/pages/" into wikiPageFolder
   return wikiPageFolder
end atopia_WikiPageFolder


--> Atopia | Shell
-
command atopia_StoreFile fedwikiDomain, wikiPageSlug, localFile
   -- was "atopia_StoreFile"
   put fedwiki_ConstructPath (fedwikiDomain, wikiPageSlug) into wikiPagePath
   digitalOcean_StoreFile "Atopia", wikiPagePath, localFile
   return the result
end atopia_StoreFile

command atopia_DoRemoteShell remoteShell
   -- carefull with this
   -- with the right private ssh key a dangerous sheel command can wipe the entire server
   
   put digitalOcean_GetDropletIP (AtopiaDropletName) into dropletIP
   ssh_DoRemoteShell AtopiaSshUser, dropletIP, remoteShell
   put the result into shellResult
   return shellResult
end atopia_DoRemoteShell
