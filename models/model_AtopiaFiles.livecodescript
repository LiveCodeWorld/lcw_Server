script "model_AtopiaFiles"
--> MetaData
-
license: GPLv3
name: model_AtopiaFiles
type: model
version: 0.3

/*
This model provides access to files and folders on the Atopia server on DigitalOcean.
As this server is a Fedwiki Farm, most of these files are page-json files for wiki.
It uses ssh to access the remote file system. 
The handlers expect passwordless ssh key access to the server

Here we provide handlers to build and do CRUD operations on the Atopia Fedwiki server wiki model.
config.json is not a folder and should not show up in any case. Keep here just in case
Rename and probably move fedwiki_owners when we have automatic control over owner files
There are other ways of accessing information stored about the server though page-json or the JSON Plugin.
*/

--> Variables
-
/* All the constants below are only used by handlers in this model. */

constant AtopiaDropletName = "Atopia"
constant AtopiaDomain = "fedwiki.org"
constant AtopiaSshUser = "root"
local AtopiaDropletIP


--> Atopia | Dangerous
-
command atopia_DoRemoteShell remoteShell
   -- used by lib_Atopia to do folder moving and deleting
   -- be very carefull with this
   -- with the right private ssh key a dangerous shell command can wipe the entire server
   -- put atopia_GetIP() into dropletIP -- changed to AtopiaDomain
   
   ssh_DoRemoteShell AtopiaSshUser, AtopiaDomain, remoteShell
   put the result into shellResult
   return shellResult
end atopia_DoRemoteShell


--> Atopia | Files
-
command atopia_DeleteWikiSitemap fedwikiDomain
   put fedwiki_ConstructSitemapPath (fedwikiDomain) into sitemapPath
   --
   atopia_DeleteFile sitemapPath
   --
   put the result into shellResult
   return shellResult
end atopia_DeleteWikiSitemap


--> Atopia | Files | Model
-
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

command atopia_StoreData somePath, someData
   digitalOcean_StoreData someData, AtopiaDropletName, somePath, AtopiaSshUser
   put the result into shellResult
   return shellResult
end atopia_StoreData

command atopia_DeleteFile pathToDelete
   digitalOcean_DeleteFile pathToDelete, AtopiaDropletName, AtopiaSshUser
   put the result into shellResult
   return shellResult
end atopia_DeleteFile

function atopia_FetchLsArray serverPath
   put server_FetchFileList ("fedwiki.org", serverPath, true, AtopiaSshUser) into lsResult
   if char 1 of lsResult = "@" then
      return lsResult
   end if
   put shell_ConstructLSArray (lsResult, true) into infoArray
   return infoArray
end atopia_FetchLsArray


--> Atopia | Model | Fetch | List
-
function atopia_ListDefaultWikiPages
   put atopia_WikiDefaultPagesFolder() into serverPath
   put atopia_FetchLsArray (serverPath) into infoArray
   put infoArray ["file"] into fileArray
   put keys (fileArray) into wikiPages
   return wikiPages
end atopia_ListDefaultWikiPages

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


--> Atopia | Model | Folders
-
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


--> Atopia | IP
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


--> Atopia | Model | Files and Folders
-
function atopia_WikiStatusFolder wikiDomain
   -- absolute path for safety
   put wikiDomain & "/status/" into relFolder
   return atopia_WikiFolder (relFolder)
end atopia_WikiStatusFolder

function atopia_WikiPageFolder wikiDomain
   -- absolute path for safety
   put wikiDomain & "/pages/" into relFolder
   return atopia_WikiFolder (relFolder)
end atopia_WikiPageFolder

function atopia_WikiDomainFolder wikiDomain
   -- absolute path for safety
   put atopia_WikiFolder (wikiDomain) into domainFolder
   put slash after domainFolder
   return domainFolder
end atopia_WikiDomainFolder

function atopia_UnhostedFolder
   return atopia_WikiFolder ("_unhosted_sites/")
end atopia_UnhostedFolder

function atopia_FolderInTrashFolder wikiDomain
   -- hard wired absolute path for safety
   put atopia_TrashFolder() & wikiDomain & slash into folderInTrashFolder
   shell_BashParamEscape folderInTrashFolder
   return folderInTrashFolder
end atopia_FolderInTrashFolder

function atopia_TrashFolder
   -- hard wired absolute path for safety
   return atopia_WikiFolder ("_trash/")
end atopia_TrashFolder

function atopia_WikiFolder pRelativePath
   -- absolute path for safety
   put atopia_WikiRootFolder() into wikiRootFolder
   put pRelativePath after wikiRootFolder
   return wikiRootFolder
end atopia_WikiFolder

function atopia_WikiRootFolder
   -- absolute path for safety
   put "/root/.wiki/" into wikiRootFolder
   return wikiRootFolder
end atopia_WikiRootFolder

function atopia_DefaultWikiPagePath pageSlug
   put atopia_WikiDefaultPagesFolder() & pageSlug into wikiPagePath
   return wikiPagePath
end atopia_DefaultWikiPagePath

function atopia_WikiDefaultPagesFolder
   return "/root/.nvm/versions/node/v6.11.3/lib/node_modules/wiki/node_modules/wiki-server/default-data/pages/"
end atopia_WikiDefaultPagesFolder
