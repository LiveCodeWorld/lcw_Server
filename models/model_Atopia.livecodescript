script "model_Atopia"
--> MetaData
-
license: GPLv3
name: model_Atopia
type: model
version: 0.2

/*
In this library we interface with the following models:

1. Atopia Roster (uses roster_Fetch() and roster_Store)
2. Atopia Domain Array (uses a json-plugin store)

AtopiaFedray has the same data structure as fedray


function atopia_FetchRecentFolders pSincePeriod
   -- relying on the lastmodified of a folder on linux is not reliable
   -- use "atopia_ListSinceDomains()" which relies on the "tree" command to specify the lastmodified of the "site-index.json" files
   
   if pSincePeriod is empty then put "1 week" into pSincePeriod
   put date_GetSinceSeconds (pSincePeriod) into sinceSeconds
   
   put atopia_FetchFilteredFolderLsArray() into lsArray
   delete variable lsArray ["fedwiki_owners"]
   --
   repeat for each key wikiDomain in lsArray
      put lsArray [wikiDomain]["lastmodified"] into lastmodified
      convert lastmodified from internet date to seconds
      if lastmodified > sinceSeconds then
         put wikiDomain & CR after recentFolders
      end if
   end repeat
   delete char -1 of recentFolders
   --
   url_SortDomainIndex recentFolders
   return recentFolders
end atopia_FetchRecentFolders
*/


--> Working on
-
function atopia_ListNewStoredCatFolders pListStored
   put transport_FetchAtopiaCatModel() into atopiaCatModel
   --
   put atopiaCatModel ["new sites"] into newSiteArray
   put keys (newSiteArray) into newAtopiaSites
   url_SortDomainIndex newAtopiaSites
   return newAtopiaSites
end atopia_ListNewStoredCatFolders

function atopia_ListNewCatFolders
   put atopia_ConstructCatModel() into atopiaCatModel
   --
   put atopiaCatModel ["new sites"] into newSiteArray
   put keys (newSiteArray) into newAtopiaSites
   url_SortDomainIndex newAtopiaSites
   return newAtopiaSites
end atopia_ListNewCatFolders

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


--> Atopia | DomainArray | Model
-
function atopia_FetchDomainArray
   -- also "fedserver_FetchFedray" of model_FedServer
   put fedwiki_FetchPluginJSON ("atopia-domain-index", "server.fedwiki.org") into someJSON
   put json_ToArray (someJSON) into atopiaFedray
   if atopiaFedray is false then return empty
   return atopiaFedray
end atopia_FetchDomainArray

command atopia_StoreDomainArray atopiaFedray
   if atopiaFedray is not an array then return "Error, atopiaFedray is not an array. Delete instead?"
   --
   put json_FromArray (atopiaFedray) into someJSON
   put secret_Get ("AtopiaJsonApiKey", "jsonApiKey") into apiKey
   fedwiki_PutPluginJSON someJSON, "atopia-domain-index", "server.fedwiki.org", apiKey
   put the result into putError
   return putError
end atopia_StoreDomainArray

function secret_Get secretName
   -- for server use only
   if the environment is not "server" then pass "secret_Get"
   --
   put rigFetchConfigItem (secretName) into someSecret
   return someSecret
end secret_Get


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
   pageArray_Store wikiDomain, pageSlug, pageArray
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
