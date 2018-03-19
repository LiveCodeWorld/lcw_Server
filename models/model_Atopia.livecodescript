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

local AtopiaDropletIP


--> Working on
-
function atopia_GetIP
   -- cached
   if AtopiaDropletIP is empty then
      put digitalOcean_GetDropletIP (AtopiaDropletName) into AtopiaDropletIP
      if AtopiaDropletIP is empty then
         -- something is broken
         breakpoint
         exit to top
      end if
   end if
   return AtopiaDropletIP
end atopia_GetIP

command display_AtopiaUpdateResult resultArray, pIndexView
   display_Array resultArray
   --
   put array_ToMarkdown (resultArray) into mdText
   if exists (pIndexView) is false then
      put mdText
      return pIndexView
   end if
   --
   
   lock screen
   set the atopia_ColouredLines of pIndexView to mdText
   set the label of the stack_Object of pIndexView to "atopia_UpdateArrayAndMove"
   set the title_Text of pIndexView to "Update Result"
   unlock screen
   return mdText
end display_AtopiaUpdateResult

function array_ToMarkdown markDownArray
   repeat for each key someTitle in markDownArray
      put "#" && someTitle & CR after mdText
      put markDownArray [someTitle] into mdBody
      put mdBody & CR & CR after mdText
   end repeat
   return word 1 to -1 of mdText
end array_ToMarkdown


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
function atopia_ListLocalWikiFolders pDomainErrorArray
   -- reconstruct from array  
   if pDomainErrorArray is empty then
      put atopia_GetDomainErrorArray() into pDomainErrorArray
   end if
   if pDomainErrorArray is empty then return empty -- ideally should not be?
   
   put atopia_GetLocalGoodArray (pDomainErrorArray) into allArray
   put atopia_GetLocalBadArray (pDomainErrorArray) into badArray
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


--> Atopia | Model | Local | Wrappers
-
function atopia_GetLocalGoodArray pDomainErrorArray
   if pDomainErrorArray is empty then
      put atopia_GetDomainErrorArray() into pDomainErrorArray
   end if
   put pDomainErrorArray ["good"] into goodArray
   return goodArray
end atopia_GetLocalGoodArray

function atopia_GetLocalBadArray pDomainErrorArray
   if pDomainErrorArray is empty then
      put atopia_GetDomainErrorArray() into pDomainErrorArray
   end if
   put pDomainErrorArray ["bad"] into badArray
   return badArray
end atopia_GetLocalBadArray

function atopia_GetLocalUnhostedArray pDomainErrorArray
   if pDomainErrorArray is empty then
      put atopia_GetDomainErrorArray() into pDomainErrorArray
   end if
   put pDomainErrorArray ["_unhosted_sites"] into unhostedArray
   return unhostedArray
end atopia_GetLocalUnhostedArray


--> Atopia | Model | Local
-
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


--> Atopia | Model | Remote | Fetch
-
function atopia_FetchNewFolderList
   -- prefer to use arrays as faster
   -- put atopia_FetchAllFolderList() into remoteDomainNames
   
   put atopia_FetchFilteredFolderLsArray() into remoteFolderArray
   if item 1 of it is "error" then return empty
   
   put atopia_ListLocalWikiFolders() into localDomainNames
   
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
   put atopia_GetIP() into dropletIP
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
   
   put atopia_GetIP() into dropletIP
   ssh_DoRemoteShell AtopiaSshUser, dropletIP, remoteShell
   put the result into shellResult
   return shellResult
end atopia_DoRemoteShell
