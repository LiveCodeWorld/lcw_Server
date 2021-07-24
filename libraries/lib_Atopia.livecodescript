script "lib_Atopia"
--> MetaData
-
license: GPLv3
name: lib_Atopia
type: library
version: 0.3

/*
This library is for processing and interfacing with wiki folders on the Atopia server.
Carful with it as it does a lot of moving and deleting of files and folders using ssh
*/

--> Variables
-
constant ReservedFolderNames = "_old_sites,_unhosted_sites,_trash,fedwiki_owners"


--> Working on
-
function atopia_PathExists folderPath
   put "ls -la" && kwote (folderPath) into remoteShell
   --
   atopia_DoRemoteShell remoteShell
   put the result into listResult
   --
   switch
      case line 1 of listResult begins with "ls: cannot access"
      case line 1 of listResult ends with "No such file or directory"
         return false
      case word 1 of listResult = "total"
         return true
      default
         breakpoint
         return listResult
   end switch
end atopia_PathExists

command atopia_RenameWikiFolder oldDomainName, newDomainName
   if atopia_WikiFolderExists (oldDomainName) is not true then
      -- lazy slow careful check
      breakpoint
      return false
   end if
   
   put atopia_WikiDomainFolder (oldDomainName) into oldWikiFolderPath
   put atopia_WikiDomainFolder (newDomainName) into newWikiFolderPath
   --
   put "mv -f" && kwote (oldWikiFolderPath) && kwote (newWikiFolderPath) into remoteShell
   --
   atopia_DoRemoteShell remoteShell
   put the result into moveResult
   return moveResult
end atopia_RenameWikiFolder

function atopia_WikiFolderExists domainName
   put atopia_WikiDomainFolder (domainName) into wikiFolderPath
   --
   put atopia_PathExists (wikiFolderPath) into folderExists
   return folderExists
end atopia_WikiFolderExists

function atopia_FetchPublicKey
   -- put "ls -la" into someCommand
   put "cat" into someCommand
   --
   put "/root/.ssh/" & "id_rsa.pub" into pubKeyPath
   put someCommand && pubKeyPath into remoteShell
   atopia_DoRemoteShell remoteShell
   put the result into shellResult
   if shellResult begins with "ls: cannot access" then
      return empty
   else
      return shellResult
   end if
end atopia_FetchPublicKey


--> Atopia | Check
-
function atopia_IsInDomainArray wikiDomain
   put atopia_FetchDomainArray() into domainArray
   get domainArray [wikiDomain]
   put it is an array into isInDomainArray
   return isInDomainArray
end atopia_IsInDomainArray

function atopia_WikiIsHosted wikiFolder, pFetchAtopiaIpAddress
   if pFetchAtopiaIpAddress is true then
      put digitalocean_FetchDropletIP ("Atopia") into dropletIP
   else
      put atopia_GetIP() into dropletIP
   end if
   put dig_GetIP (wikiFolder) into testIP
   if testIP = dropletIP then return true
   return false
end atopia_WikiIsHosted

function atopia_CheckUnhosted goodFolders
   -- This is slow
   -- We rotate through all goodFolders and check they have A records for Atopia
   
   put atopia_GetIP() into dropletIP
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

function atopia_IsInRoster wikiDomain
   put atopia_FetchRosterDomains() into atopiaRosterDomains
   set the wholeMatches to true
   put wikiDomain is among the lines of atopiaRosterDomains into isInRoster
   return isInRoster
end atopia_IsInRoster

function atopia_WikiHasPages wikiFolder, pMinNum
   if pMinNum is empty then put 1 into pMinNum
   put atopia_ListWikiPages (wikiFolder) into wikiPages
   put the number of lines of wikiPages >= pMinNum into hasPages
   return hasPages
end atopia_WikiHasPages

function atopia_RemoteWikiFolderExists folderName, pRemoteFolderArray
   if pRemoteFolderArray is empty then
      put atopia_FetchFilteredFolderLsArray() into pRemoteFolderArray
   end if
   
   put folderName is among the keys of pRemoteFolderArray into remoteExists
   return remoteExists
end atopia_RemoteWikiFolderExists


--> Private
-
private command _AddDnsToAtopiaArray @atopiaData, goodShortFolder, testIP
   put dig_GetNS (goodShortFolder) into dnsArray
   put dnsArray into atopiaData ["dns"][goodShortFolder]["NS"]
   put testIP into atopiaData ["dns"][goodShortFolder]["A record"]
   
   -- in case we crash :)
   atopia_SetData atopiaData
   return dnsArray
end _AddDnsToAtopiaArray
