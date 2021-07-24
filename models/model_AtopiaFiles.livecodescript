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
constant AtopiaSshUser = "root"
constant AtopiaDomain = "fedwiki.org"
local AtopiaDropletIP


--> Atopia | Dangerous
-
command atopia_DoRemoteShell remoteShell
   -- used by lib_Atopia to do folder moving and deleting
   
   ssh_DoRemoteShell AtopiaSshUser, AtopiaDomain, remoteShell
   put the result into shellResult
   return shellResult
end atopia_DoRemoteShell

function atopia_GetRemoteBash someShell
   /*
   -- nearly
   -- https://stackoverflow.com/questions/47777368/how-to-run-npm-through-ssh
   -- https://stackoverflow.com/questions/7114990/pseudo-terminal-will-not-be-allocated-because-stdin-is-not-a-terminal
   
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   @    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
   Someone could be eavesdropping on you right now (man-in-the-middle attack)!
   It is also possible that a host key has just been changed.
   The fingerprint for the ECDSA key sent by the remote host is
   ca:6c:03:c6:03:52:d3:c8:08:f0:60:a0:63:0e:df:f2.
   Please contact your system administrator.
   Add correct host key in /root/.ssh/known_hosts to get rid of this message.
   Offending ECDSA key in /root/.ssh/known_hosts:4
   remove with: ssh-keygen -f "/root/.ssh/known_hosts" -R fedwiki.org
   ECDSA host key for fedwiki.org has changed and you have requested strict checking.
   Host key verification failed.
   */
   
   put "ssh -tt root@fedwiki.org 'bash -i -c" && kwote (someShell) & "'" into remoteShell
   --
   ssh_DoRemoteShell AtopiaSshUser, AtopiaDomain, remoteShell
   put the result into shellResult
   return shellResult
end atopia_GetRemoteBash


--> Working on
-
function atopia_FetchFiles wikiDomain
   put "ssh root@fedwiki.org" into someShell
   put space & "ls -Rlap" after someShell
   put "/root/.wiki/" & wikiDomain into wikiFolder
   put space & kwote (wikiFolder) after someShell
   put shell (someShell) into shellResult
   return shellResult
end atopia_FetchFiles

function atopia_WikiHasPages wikiFolder, pMinNum
   if pMinNum is empty then put 1 into pMinNum
   put atopia_ListWikiPages (wikiFolder) into wikiPages
   put the number of lines of wikiPages >= pMinNum into hasPages
   return hasPages
end atopia_WikiHasPages

function atopia_ListWikiPages wikiDomain
   put "ssh root@fedwiki.org" into someShell
   put space & "ls -p" after someShell
   put "/root/.wiki/" & wikiDomain & "/pages/" into pagesFolder
   put space & kwote (pagesFolder) after someShell
   put shell (someShell) into shellResult
   return shellResult
end atopia_ListWikiPages


--> Atopia | Files | Model
-
command atopia_DeleteWikiSitemap fedwikiDomain
   put atopia_ConstructSitemapPath (fedwikiDomain) into sitemapPath
   --
   atopia_DeleteFile sitemapPath
   --
   put the result into shellResult
   return shellResult
end atopia_DeleteWikiSitemap

function atopia_FetchData somePath
   put digitalOcean_FetchFile (somePath, AtopiaDropletName, AtopiaSshUser) into someJSON
   return someJSON
end atopia_FetchData

function atopia_FetchLsArray serverPath
   put server_FetchFileList ("fedwiki.org", serverPath, true, AtopiaSshUser) into lsResult
   if char 1 of lsResult = "@" then return lsResult
   put shell_ConstructLSArray (lsResult, true) into infoArray
   return infoArray
end atopia_FetchLsArray


--> Atopia | Model | Folders
-
function atopia_FetchFolders pWikiDomain
   put atopia_FetchFilteredFolderLsArray() into folderArray
   delete variable folderArray ["fedwiki_owners"]
   put keys (folderArray) into wikiDomains
   --
   if pWikiDomain is not empty then
      put wikiDomains into subDomainNames
      filter subDomainNames with ("*." & pWikiDomain)
      --
      if pWikiDomain is among the lines of wikiDomains then
         put pWikiDomain into wikiDomains
         put CR & subDomainNames after wikiDomains
      else
         put subDomainNames into wikiDomains
      end if
   end if
   --
   url_SortDomainIndex wikiDomains
   return wikiDomains
end atopia_FetchFolders

function atopia_FetchWikiFolders pFilter
   -- use tree as with roster_FetchLive
   put atopia_WikiFolder() into remoteFolder
   put atopia_FetchLsArray (remoteFolder) into infoArray
   put infoArray ["folder"] into folderArray
   put keys (folderArray) into wikiDomains
   --
   filter wikiDomains without "_*"
   filter wikiDomains without ".*"
   if pFilter is not empty then
      if pFilter contains "*" then
         filter wikiDomains with pFilter
      else
         if pFilter is among the lines of wikiDomains then
            put wikiDomains into subdomains
            filter subdomains with ("*." & pFilter)
            put pFilter & CR & subdomains into wikiDomains
            put word 1 to -1 of wikiDomains into wikiDomains
         else
            filter wikiDomains with pFilter
         end if
      end if
   end if
   --
   url_SortDomainIndex wikiDomains, true
   return wikiDomains
end atopia_FetchWikiFolders

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


--> Atopia | Folders
-
command atopia_CheckGoodFolders @wikiDomains
   repeat for each line wikiDomain in wikiDomains
      set the cursor to busy
      put atopia_WikiHasPages (wikiDomain) into hasPages
      put empty into domainArray [hasPages][wikiDomain]
   end repeat
   put domainArray [true] into goodDomainArray
   put the keys of goodDomainArray into goodDomains
   put goodDomains into  wikiDomains
   --
   put domainArray [false] into badDomainArray
   put the keys of badDomainArray into badDomains
   return badDomains
end atopia_CheckGoodFolders

function atopia_ConstructSitemapPath wikiDomain
   -- changed to absolute path 
   put atopia_ConstructDomainFolder (wikiDomain) into atopiaDomainFolder
   put atopiaDomainFolder & "status/sitemap.json" into siteMapFile
   return siteMapFile
end atopia_ConstructSitemapPath

function atopia_ConstructPagePath wikiDomain, pPageSlug
   -- specific to Atopia Folder (switched to absolute path)
   -- /root/.wiki/actual.world/pages/some-page   
   put atopia_ConstructDomainFolder (wikiDomain) into wikiPath
   if pPageSlug is empty then return wikiPath
   put "pages/" & pPageSlug after wikiPath
   return wikiPath
end atopia_ConstructPagePath

function atopia_ConstructDomainFolder wikiDomain
   text_AddTrailing wikiDomain, slash
   put atopia_WikiRootFolder() & wikiDomain into atopiaDomainFolder
   return atopiaDomainFolder
end atopia_ConstructDomainFolder

function atopia_WikiRootFolder
   -- specific to Atopia Folder
   -- need to generalise to other servers
   return "/root/.wiki/"
end atopia_WikiRootFolder


--> Atopia | IP
-
function atopia_CheckIP someIP, pForceFetch
   put pForceFetch is not false into pForceFetch
   put atopia_GetIP (pForceFetch) = someIP into isAtopiaServer
   return isAtopiaServer
end atopia_CheckIP

function atopia_GetIP pForceFetch
   if AtopiaDropletIP is not empty and pForceFetch is not true then
      -- cached
      return AtopiaDropletIP
   else
      get atopia_FetchIP()
      if item 1 of it is "Error" then
         exit to top
         return empty
      else
         put it into AtopiaDropletIP
      end if
   end if
end atopia_GetIP

function atopia_FetchIP
   get digitalOcean_GetDropletIP (AtopiaDropletName)
   if http_CheckIP (it) is false then return "Error, fetching ip address for droplet" && dropletName
   
   put it into AtopiaDropletIP
   return AtopiaDropletIP
end atopia_FetchIP


--> Atopia | Top
-
function atopia_FetchTopTSV cseName
   put cse_NameToID (cseName) into cseID
   put atopia_ListTopFolders() into atopiaDomains
   put cse_ConstructTSV (atopiaDomains, cseID) into topTSV
   return topTSV
end atopia_FetchTopTSV

function atopia_ListTopDomains
   -- from roster
   put atopia_FetchRosterDomains() into atopiaDomains
   put url_ListTopDomains (atopiaDomains) into topDomains
   url_SortDomainIndex topDomains
   return topDomains
end atopia_ListTopDomains

function atopia_ListTopFolders
   put atopia_FetchFolders() into atopiaDomains
   put url_ListTopDomains (atopiaDomains) into topDomains
   url_SortDomainIndex topDomains
   return topDomains
end atopia_ListTopFolders


--> Atopia | Model | Fetch | List
-
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
   put atopia_TrashFolder() & wikiDomain & slash into folderInTrashFolder
   return folderInTrashFolder
end atopia_FolderInTrashFolder

function atopia_TrashFolder
   return atopia_WikiFolder ("_trash/")
end atopia_TrashFolder

function atopia_WikiFolder pRelativePath
   put atopia_WikiRootFolder() into wikiRootFolder
   put pRelativePath after wikiRootFolder
   return wikiRootFolder
end atopia_WikiFolder

function atopia_WikiRootFolder
   -- absolute path for safety
   put "/root/.wiki/" into wikiRootFolder
   return wikiRootFolder
end atopia_WikiRootFolder
