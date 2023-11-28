script "model_Atopia"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_Atopia
type: model
version: 0.2

/*
In this library we interface with the following models:

1. Atopia Roster (uses roster_Fetch() and roster_Store)
2. Atopia Domain Array (uses a json-plugin store)

AtopiaFedray has the same data structure as fedray
*/


--> Working on
-
function atopia_ListNewStoredCatFolders pListStored
   put atopia_FetchCatModel() into atopiaCatModel
   --
   put atopiaCatModel ["new sites"] into newSiteArray
   put keys (newSiteArray) into newAtopiaSites
   url_SortDomainIndex newAtopiaSites
   return newAtopiaSites
end atopia_ListNewStoredCatFolders

function atopia_ListNewRosterFolders pAtopiaDomains
   -- compare Atopia roster sites with actual folders on server
   if pAtopiaDomains is empty then
      put atopia_FetchRosterDomains() into pAtopiaDomains
   end if  
   
   put atopia_FetchFilteredFolderLsArray() into remoteFolderArray
   if item 1 of it is "error" then return empty
   --
   delete variable remoteFolderArray ["fedwiki_owners"]
   repeat for each line wikiDomain in pAtopiaDomains
      set the cursor to busy
      delete variable remoteFolderArray [wikiDomain]
   end repeat
   --
   put keys (remoteFolderArray) into newRemoteDomains
   url_SortDomainIndex newRemoteDomains
   return newRemoteDomains
end atopia_ListNewRosterFolders



--> Atopia | DomainArray | Model | Files
-
function atopia_PluginJsonPath pageSlug, wikiDomain
   -- see fedwiki_ConstructPluginJsonUrl()
   -- http://admin.fedwiki.org/plugin/json/atopia-fedwiki-sites
   put "http://" & wikiDomain & "/plugin/json/" & pageSlug into restURL
   return restURL
end atopia_PluginJsonPath


--> Atopia | DomainArray | Model | CRUD
-
command atopia_AddToDomainArray newAtopiaFedray
   if newAtopiaFedray is not an array then return empty
   --
   put atopia_FetchDomainArray() into atopiaFedray
   union atopiaFedray with newAtopiaFedray
   atopia_StoreDomainArray atopiaFedray
   --
   return atopiaFedray
end atopia_AddToDomainArray

command atopia_AddFedray newAtopiaFedray
   if newAtopiaFedray is not an array then return empty
   --
   put fedray_FetchModel() into fedray
   union fedray with newAtopiaFedray
   fedray_StoreModel fedray
   --
   return fedray
end atopia_AddFedray


--> Atopia | Roster | Model
-
function atopia_FetchRoster
   -- fetch the one big domain index roster then filter
   put roster_Fetch ("server.fedwiki.org", "atopia-domain-index", "741a0fcdd3ff76b2") into rosterText
   return word 1 to -1 of rosterText
end atopia_FetchRoster

command atopia_StoreRoster rosterText
   roster_Store "server.fedwiki.org", "atopia-domain-index", rosterText, "741a0fcdd3ff76b2"
   put the result into pageArray
   return pageArray
end atopia_StoreRoster

function roster_Fetch wikiDomain, pageSlug, pItemID
   -- find in first roster on page
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   if pItemID is empty then
      put pageArray_FindItemType ("roster", pageArray) into itemNum
      put pageArray ["story"][itemNum]["text"] into rosterDomainText
   else
      put pageArray_GetItemText (pageArray, pItemID) into rosterDomainText
   end if
   return rosterDomainText
end roster_Fetch

command roster_Store wikiDomain, pageSlug, rosterText, pItemID
   -- store in first roster on page
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   --
   if pItemID is empty then
      put pageArray_FindItemType ("roster", pageArray) into itemNum
   else
      put pageArray_FindItemID (pItemID, pageArray) into itemNum
   end if
   put rosterText into pageArray ["story"][itemNum]["text"]
   --
   pageArray_Set wikiDomain, pageSlug, pageArray
   return pageArray
end roster_Store


--> Atopia | Model | List | New
-
function atopia_ListDomainsFromFedray pMinPageNum
   put atopia_FetchDomainArray() into atopiaFedray
   --
   if pMinPageNum is a number then fedray_Filter atopiaFedray, pMinPageNum
   put keys (atopiaFedray) into atopiaDomains
   url_SortDomainIndex atopiaDomains
   return atopiaDomains
end atopia_ListDomainsFromFedray

function atopia_ListNewSites pSincePeriod
   -- nelwy created sites
   put atopia_FetchNewSiteDateArray (pSincePeriod) into newDateArray
   put keys (newDateArray) into newSiteDomains
   url_SortDomainIndex newSiteDomains
   return newSiteDomains
end atopia_ListNewSites

function atopia_ListNewFolders pSincePeriod
   -- all new folders (either modified, spam or newly created)
   put atopia_GetLaterThanSeconds (pSincePeriod) into sinceLastSeconds
   --
   put atopia_FetchFilteredFolderLsArray() into remoteFolderArray
   if item 1 of it is "error" then return empty
   delete variable remoteFolderArray ["fedwiki_owners"]
   
   put atopia_FetchOldDateArray (sinceLastSeconds) into oldDateArray
   repeat for each key wikiDomain in oldDateArray
      set the cursor to busy
      delete variable remoteFolderArray [wikiDomain]
   end repeat
   --
   put keys (remoteFolderArray) into newRemoteDomains
   url_SortDomainIndex newRemoteDomains
   return newRemoteDomains
end atopia_ListNewFolders

function atopia_ListEmptySites
   put atopia_FetchFilteredFolderLsArray() into folderArray
   delete variable folderArray ["fedwiki_owners"]
   put atopia_ListWelcomeFolders() into treeInfoFolders
   split treeInfoFolders by CR as set
   --
   difference folderArray with treeInfoFolders
   --
   put the keys of folderArray into emptyFolders
   url_SortDomainIndex emptyFolders
   return emptyFolders
end atopia_ListEmptySites


--> Atopia | Model | List | Recent
-
function atopia_GetLaterThanSeconds pSincePeriod
   -- converts user-friendly pSincePeriod to seconds
   switch pSincePeriod
      case "last update"
         put atopia_GetLastUpDate() into laterThanSeconds
         break
      case empty
         put date_GetSinceSeconds ("1 week") into laterThanSeconds
         break
      default
         put date_GetSinceSeconds (pSincePeriod) into laterThanSeconds
   end switch
   return laterThanSeconds
end atopia_GetLaterThanSeconds

function atopia_ListSinceDomains pSincePeriod  
   put atopia_GetLaterThanSeconds (pSincePeriod) into laterThanSeconds
   put atopia_ListRecentDomains (laterThanSeconds) into wikiDomains
   return wikiDomains
end atopia_ListSinceDomains

function atopia_FetchSinceDomainArray pSincePeriod
   if pSincePeriod is empty then put "1 week" into pSincePeriod
   put date_GetSinceSeconds (pSincePeriod) into pLaterThanSeconds
   put atopia_FetchDateArray (pLaterThanSeconds) into recentAtopiaFedray
   return recentAtopiaFedray
end atopia_FetchSinceDomainArray

function atopia_ListRecentDomains laterThanSeconds
   -- lists domains with "site-index.json" (emits empty spam folders)
   -- relies on the "tree" command installed on the Atopia server
   -- "tree" is used to specify the lastmodified of the "site-index.json" files
   put atopia_FetchDateArray (laterThanSeconds) into recentAtopiaFedray
   put the keys of recentAtopiaFedray into wikiDomains
   url_SortDomainIndex wikiDomains
   return wikiDomains
end atopia_ListRecentDomains


--> Atopia | Roster | Model | Domains
-
function atopia_FetchRosterDomains pDomainFilter
   put atopia_FetchRoster() into atopiaDomains
   roster_StripHeader atopiaDomains
   url_FilterDomainIndex atopiaDomains, pDomainFilter
   return word 1 to -1 of atopiaDomains
end atopia_FetchRosterDomains

command atopia_StoreRosterDomains wikiDomains
   if wikiDomains is empty then return "Error, atopiaDomains is empty (not saving)."
   
   url_SortDomainIndex wikiDomains
   put "Atopia Domains" & CR&CR & wikiDomains into rosterText
   atopia_StoreRoster rosterText
   --
   put the result into pageArray
   return pageArray
end atopia_StoreRosterDomains


--> Atopia | Roster | Model | CRUD
-
command atopia_AddToRoster wikiDomains
   put atopia_FetchRosterDomains() into rosterDomains
   --
   set the wholematches to true
   repeat for each line newLine in wikiDomains
      if newLine is not among the lines of rosterDomains then
         put newLine & CR before rosterDomains
      end if
   end repeat
   url_SortDomainIndex rosterDomains
   --
   atopia_StoreRosterDomains rosterDomains
   return rosterText
end atopia_AddToRoster

command atopia_DeleteFromRoster wikiDomains
   put atopia_FetchRosterDomains() into rosterDomains
   line_DeleteIndex rosterDomains, wikiDomains
   atopia_StoreRosterDomains rosterDomains
   return rosterDomains
end atopia_DeleteFromRoster


--> Private
-
private function date_GetSinceSeconds sincePeriod, pSinceSeconds
   -- used for user friendly dispay / input
   if pSinceSeconds is empty then
      put the seconds into pSinceSeconds
   end if
   --
   put word 1 of sincePeriod into sinceNum
   put word 2 of sincePeriod into sinceWord
   --
   switch sinceWord
      case "min"
      case "mins"
      case "minute"
      case "minutes"
         put sinceNum * 60 into periodInSeconds
         break
      case "hour"
      case "hours"
         put sinceNum * 60 * 60 into periodInSeconds
         break
      case "day"
      case "days"
         put sinceNum * 24 * 60 * 60 into periodInSeconds
         break
      case "week"
      case "weeks"
         put sinceNum * 7 * 24 * 60 * 60 into periodInSeconds
         break
   end switch
   subtract periodInSeconds from pSinceSeconds
   --
   return pSinceSeconds
end date_GetSinceSeconds
