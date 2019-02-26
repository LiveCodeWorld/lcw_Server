script "lib_AtopiaFetch"
--> MetaData
-
license: GPLv3
name: lib_AtopiaFetch
type: library
version: 0.2

/*
This library  is for fetchng and setting files and folders on the Atopia server.
It uses ssh ("ssh_DoRemoteShell" to list files and folder on the server)
And "digitalOcean_StoreFile" and "digitalOcean_FetchFile" to get stuff.

To make this work safely on the server we don't use ssh.
Instead we refer to json files stored in wiki that provide the most up to date information about the state of the server farm available.
Ultimately the wiki-server should provide this information live, and we should structre our development to anticiapte - indeed guide this.

# Local Server
A local wiki-server can provide safe ssh access to the wiki farm from behind the firewall.
This would be useful for authoring purposes.
Alternatively we could use the shell plugin to acheive the same type of thing, if a little less securely :)
*/

--> Variables
-
constant AtopiaDropletName = "Atopia"
constant AtopiaSshUser = "root"
local AtopiaDropletIP


--> Working on
-
function atopia_FetchNewFolderList
   -- prefer to use arrays as faster
   -- put atopia_FetchAllFolderList() into remoteDomainNames
   
   put atopia_FetchFilteredFolderLsArray() into remoteFolderArray
   if item 1 of it is "error" then return empty
   
   -- remove "fedwiki_owners"
   delete variable remoteFolderArray ["fedwiki_owners"]
   
   -- let's remove localDomainNames
   -- could / should fetch from previous stored online atopia index
   put atopia_ListLocalWikiFolders() into localDomainNames
   repeat for each line localDomainName in localDomainNames
      delete variable remoteFolderArray [localDomainName]
   end repeat
   
   -- extract new folders
   put keys (remoteFolderArray) into newRemoteDomains
   url_SortDomainIndex newRemoteDomains, true
   return newRemoteDomains
end atopia_FetchNewFolderList


--> Atopia | Person | JSON
-
function atopia_FetchPersonArray pageSlug
   put atopia_FetchPersonJSON (pageSlug) into someJSON
   put json_ToArray (someJSON) into someArray
   return someArray
end atopia_FetchPersonArray

command atopia_StorePersonArray pageSlug, someArray
   put json_FromArray (someArray) into someJSON
   atopia_StorePersonJSON pageSlug, someJSON
   put the result into putError
   return putError
end atopia_StorePersonArray

function atopia_FetchPersonJSON pageSlug
   put "people.fedwiki.org" into wikiDomain
   put fedwiki_FetchPluginJSON (pageSlug, wikiDomain) into someJSON
   return someJSON
end atopia_FetchPersonJSON

command atopia_StorePersonJSON pageSlug, someJSON
   put atopia_GetJsonSecret() into apiKey
   fedwiki_PutPluginJSON someJSON, pageSlug, "people.fedwiki.org", apiKey
   put the result into putError
   switch putError
      case "error Previous request not completed"
         break
      case empty
         break
      default
         put putError
   end switch
   return putError
end atopia_StorePersonJSON


--> Atopia | dangerous
-
command atopia_DoRemoteShell remoteShell
   -- used by lib_Atopia to do folder moving and delting
   -- be very carefull with this
   -- with the right private ssh key a dangerous sheel command can wipe the entire server
   
   put atopia_GetIP() into dropletIP
   ssh_DoRemoteShell AtopiaSshUser, dropletIP, remoteShell
   put the result into shellResult
   return shellResult
end atopia_DoRemoteShell


--> Atopia | Domains | Fetch
-
function atopia_FetchStoredDomains pFilterDomain, pAddTitle, pMinPageNum
   -- fetches from roster on wiki specific page
   -- see also "atopia_FetchAllLiveDomains" based on "atopia_FetchAllFolderList()" (slow live)
   
   put atopia_FetchServerArray ("Atopia Domains") into atopiaDomainArray
   --
   if pMinPageNum is a number then
      -- this could be faster
      put federation_FilterDomainArray (atopiaDomainArray, pMinPageNum) into goodBadArray
      put goodBadArray ["good"] into atopiaDomainArray
   end if
   --
   put _SortAndFilter (atopiaDomainArray, pFilterDomain, pAddTitle) into domainNames
   return domainNames
end atopia_FetchStoredDomains


--> Atopia | Model | Fetch
-
command atopia_StoreData somePath, someData
   digitalOcean_StoreData someData, AtopiaDropletName, somePath, AtopiaSshUser
   put the result into shellResult
   return shellResult
end atopia_StoreData

function atopia_FetchData somePath
   -- ie fetch some json
   put digitalOcean_FetchFile (somePath, AtopiaDropletName, AtopiaSshUser) into someJSON
   if item 1 of someJSON = "error" then
      breakpoint
      resetall
      put digitalOcean_FetchFile (somePath, AtopiaDropletName, AtopiaSshUser) into someJSON
   end if
   return someJSON
end atopia_FetchData

command atopia_DeleteFile pathToDelete
   digitalOcean_DeleteFile pathToDelete, AtopiaDropletName, AtopiaSshUser
   put the result into shellResult
   return shellResult
end atopia_DeleteFile


--> Working on
-
function atopia_GetIP pForceFetch
   -- cached
   if AtopiaDropletIP is not empty and pForceFetch is not true then
      return AtopiaDropletIP
   else
      get atopia_FetchIP()
      if it is empty then
         -- something is broken
         breakpoint
         exit to top
      else
         put it into AtopiaDropletIP
      end if
   end if
end atopia_GetIP

function atopia_FetchIP
   put digitalOcean_GetDropletIP (AtopiaDropletName) into AtopiaDropletIP
   return AtopiaDropletIP
end atopia_FetchIP


--> Atopia | Model | Fetch | List
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


--> Atopia | Model | Fetch | Calculate
-
function atopia_FetchReservedFoldersList
   -- here we fetch a list of all the reserved folders that filtering will remove
   -- can use to check / visualise how the efiltering works
   put atopia_FetchWikiRootLsFolderArray() into filteredFolderArray
   atopia_FilterAllFolderArray filteredFolderArray
   put the result into removedFolderNames
   return removedFolderNames
end atopia_FetchReservedFoldersList


--> Atopia | Domains | Live | Top
-
function atopia_FetchTopDomains
   put atopia_FetchAllFolderList() into wikiDomains
   put url_ListTopDomains (wikiDomains) into topDomains
   url_SortDomainIndex topDomains
   return topDomains
end atopia_FetchTopDomains


--> Atopia | Domains | Live
-
function atopia_FetchLiveDomainLinks topDomain
   put atopia_FetchAllFolderList() into domainIndex
   put fedwiki_FilterRosterDomains (domainIndex, topDomain) into filteredDomains
   repeat for each line filteredDomain in filteredDomains
      put "- [[" & filteredDomain & "]]" & CR after domainLinks
   end repeat
   delete char -1 of domainLinks
   return domainLinks
end atopia_FetchLiveDomainLinks

function atopia_FetchLiveDomains topDomain
   put atopia_FetchAllLiveDomains() into domainIndex
   put fedwiki_FilterRosterDomains (domainIndex, topDomain) into filteredDomains
   return filteredDomains
end atopia_FetchLiveDomains

function atopia_FetchAllLiveDomains
   -- almost same as "atopia_FetchAllFolderList" except removes "fedwiki_owners"
   put atopia_FetchFilteredFolderLsArray() into folderArray
   
   -- remove stuff
   delete variable folderArray ["fedwiki_owners"]
   
   put keys (folderArray) into wikiDomains
   url_SortDomainIndex wikiDomains
   return wikiDomains
end atopia_FetchAllLiveDomains


--> Atopia | JSON
-
function atopia_FetchServerArray jType
   put atopia_FetchServerJSON (jType) into someJSON
   put json_ToArray (someJSON) into someArray
   return someArray
end atopia_FetchServerArray

command atopia_StoreServerArray jType, someArray
   put json_FromArray (someArray) into someJSON
   atopia_StoreServerJSON jType, someJSON
   put the result into putError
   return putError
end atopia_StoreServerArray

function atopia_FetchServerJSON jType
   _SetSlugDomain jType, pageSlug, wikiDomain
   put fedwiki_FetchPluginJSON (pageSlug, wikiDomain) into someJSON
   if someJSON is empty then
      resetall
      put fedwiki_FetchPluginJSON (pageSlug, wikiDomain) into someJSON
      -- put atopia_FetchServerJSON (jType) into someJSON
   end if
   return someJSON
end atopia_FetchServerJSON

command atopia_StoreServerJSON jType, someJSON
   _SetSlugDomain jType, pageSlug, wikiDomain
   put atopia_GetJsonSecret() into apiKey
   fedwiki_PutPluginJSON someJSON, pageSlug, wikiDomain, apiKey
   put the result into putError
   return putError
end atopia_StoreServerJSON


--> Atopia | Model | Folders
-
function atopia_FetchAllFolderList
   -- almost same as "atopia_FetchAllLiveDomains"
   -- fetch all folders, then filter out reserved names
   -- see fast stored "atopia_FetchStoredDomains()"
   put atopia_FetchFilteredFolderLsArray() into folderArray   
   put keys (folderArray) into wikiDomains
   url_SortDomainIndex wikiDomains
   return wikiDomains
end atopia_FetchAllFolderList

function atopia_FetchRawFolderList relativePath
   put atopia_WikiFolder (relativePath) into remoteFolder
   text_AddTrailing remoteFolder, slash
   --
   put atopia_FetchLsArray (remoteFolder) into infoArray
   put infoArray ["folder"] into folderArray
   --
   put keys (folderArray) into wikiDomains
   url_SortDomainIndex wikiDomains, true
   return wikiDomains
end atopia_FetchRawFolderList

function atopia_FetchFilteredFolderLsArray
   put atopia_FetchWikiRootLsFolderArray() into filteredFolderArray
   atopia_FilterAllFolderArray filteredFolderArray
   return filteredFolderArray
end atopia_FetchFilteredFolderLsArray

function atopia_FetchWikiRootLsFolderArray
   put atopia_WikiRootFolder() into wikiRootFolder -- see also fedwiki_RelativeWikiRootFolder()
   put atopia_FetchLsArray (wikiRootFolder) into infoArray
   put infoArray ["folder"] into folderArray
   return folderArray
end atopia_FetchWikiRootLsFolderArray

function atopia_FetchLsArray serverPath
   put atopia_GetIP() into dropletIP
   --
   put server_FetchFileList (dropletIP, serverPath, true, AtopiaSshUser) into lsResult
   /*
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   @    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   */
   if char 1 of lsResult = "@" then
      breakpoint
   end if
   put shell_ConstructLSArray (lsResult, true) into infoArray
   --
   return infoArray
end atopia_FetchLsArray


--> Atopia | JSON | Secret
-
function atopia_GetJsonSecret
   put secret_Get ("AtopiaJsonApiKey", "jsonApiKey") into apiKey
   return apiKey
end atopia_GetJsonSecret

command atopia_SetJsonSecret apiKey
   secret_Set "AtopiaJsonApiKey", "jsonApiKey", apiKey
   return the result
end atopia_SetJsonSecret


--> Private
-
private command _SetSlugDomain jType, @pageSlug, @wikiDomain
   switch jType
      case "Servers"
         put "site-of-servers" into pageSlug
         put "server.fedwiki.org" into wikiDomain
         break
      case "Federation Domains"
         put "federation-domain-index" into pageSlug
         put "roster.fedwiki.org" into wikiDomain
         break
      case "Atopia Domains"
         put "atopia-domain-index" into pageSlug
         put "roster.fedwiki.org" into wikiDomain
         break
      default
         -- some error
         exit to top
   end switch
end _SetSlugDomain

private function _SortAndFilter domainArray, pFilterDomains, pAddTitle
   put keys (domainArray) into domainNames
   if pFilterDomains is not empty then put fedwiki_FilterRosterDomains (domainNames, pFilterDomains, pAddTitle) into domainNames
   if pAddTitle is not true then url_SortDomainIndex domainNames
   return domainNames
end _SortAndFilter
