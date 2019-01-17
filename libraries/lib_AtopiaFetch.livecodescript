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
function atopia_GetDomain topDomain
   
end atopia_GetDomain
   
function atopia_FetchDomain topDomain
   put atopia_FetchAllFolderList() into wikiFolders
   put "*." & topDomain into someFilter
   --
   set the wholematches to true
   put topDomain is among the lines of wikiFolders into topThere
   filter wikiFolders with someFilter
   if topThere then
      put topDomain & CR before wikiFolders
      put word 1 to -1 of wikiFolders into wikiFolders
   end if
   return wikiFolders
end atopia_FetchDomain


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

function atopia_FetchReservedFoldersList
   -- here we fetch a list of all the reserved folders that filtering will remove
   -- can use to check / visualise how the efiltering works
   put atopia_FetchWikiRootLsFolderArray() into filteredFolderArray
   atopia_FilterAllFolderArray filteredFolderArray
   put the result into removedFolderNames
   return removedFolderNames
end atopia_FetchReservedFoldersList


--> Atopia | Model | Fetch | List
-
function atopia_FetchTopDomains
   put atopia_FetchAllFolderList() into wikiDomains
   put url_ListTopDomains (wikiDomains) into topDomains
   url_SortDomainIndex topDomains
   return topDomains
end atopia_FetchTopDomains

function atopia_FetchAllFolderList
   -- fetch all folders, then filter out reserved names
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
