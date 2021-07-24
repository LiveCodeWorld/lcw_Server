script "Global | Atopia | Build | Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_Build_Menu
type: controller
version: 0.2

on mDoubleUp_WikiDomain displayView, wikiDomain
   put wikiDomain
end mDoubleUp_WikiDomain


--> Menu | Init
-
local LocalArray

on menu_Init tObject, mTarget
   put display_FindView ("Atopia", "New Folders") into newFolderView
   put exists (newFolderView) into newFolderViewExists
   put newFolderViewExists into LocalArray ["newFolderViewExists"]
   if newFolderViewExists then
      put the displayed_Index of newFolderView into newFolderIndex
      put newFolderIndex into LocalArray ["newFolderIndex"]
   else
      put empty into LocalArray ["newFolderIndex"]
   end if
end menu_Init

getprop disabled_UnloadCached
   put the cachedurls into cURLs
   if cURLs is empty then
      return true
   else
      return false
   end if
end disabled_UnloadCached

private command _BuildWithoutAtopia @fedray, withoutAtopiaDomains, displayView
   url_SortDomainIndex withoutAtopiaDomains
   set the displayed_Index of displayView to withoutAtopiaDomains
   --
   repeat for each line wikiDomain in withoutAtopiaDomains
      if the commandKey is "Down" then breakpoint
      display_Spin wikiDomain, displayView, "purple"
      --
      put dig_GetIP (wikiDomain) into someIP
      if someIP is empty then
         put empty into resultArray ["no ip"][wikiDomain]
         next repeat
      end if
      put fedwiki_FetchSitemapArray (wikiDomain) into sitemapArray
      if sitemapArray is empty then
         put empty into resultArray ["no sitemapArray"][wikiDomain]
         next repeat
      end if
      
      put empty into resultArray ["created"][wikiDomain]
      --
      put someIP into wikiDomainArray ["ipAddress"]
      put fedwiki_FetchOwnerName (wikiDomain) into ownerName
      put ownerName into wikiDomainArray ["owner"]
      put fedwiki_ExtractSiteCreationDate (wikiDomain, sitemapArray) into wikiCreationDate
      put wikiCreationDate into wikiDomainArray ["created"]
      --  
      fedray_UpdateWikiDomainArray wikiDomainArray, wikiDomain, sitemapArray
      --
      put wikiDomainArray into fedray [wikiDomain]
   end repeat
   return resultArray
end _BuildWithoutAtopia

private command _UpdateWithoutAtopia @fedray, fedrayWithoutAtopia, atopiaDomainArray, displayView
   difference fedrayWithoutAtopia with atopiaDomainArray
   put the keys of fedrayWithoutAtopia into withoutAtopiaDomains
   url_SortDomainIndex withoutAtopiaDomains
   set the displayed_Index of displayView to withoutAtopiaDomains
   --
   repeat for each line wikiDomain in withoutAtopiaDomains
      if the commandKey is "Down" then breakpoint
      display_Spin wikiDomain, displayView, "purple"
      --
      put fedwiki_FetchSitemapArray (wikiDomain) into sitemapArray
      put fedray [wikiDomain] into wikiDomainArray
      if sitemapArray is empty then
         put wikiDomainArray into resultArray ["deleted"][wikiDomain]
         delete variable fedray [wikiDomain]
      else
         put wikiDomainArray into resultArray ["updated"][wikiDomain]
         fedray_UpdateWikiDomainArray wikiDomainArray, wikiDomain, sitemapArray
         put wikiDomainArray into fedray [wikiDomain]
      end if
   end repeat
   return resultArray
end _UpdateWithoutAtopia


--> Global | Atopia | Build | Menu
-
on menu_UpdateAtopiaFromCatModel displayView
   put atopia_ConstructCatModel() into atopiaCatModel
   --
   lcw_Answer "Are you sure you want to trash and update metadata for all these Atopia domains?", displayView
   --
   atopia_UpdateFromCatModel atopiaCatModel
   --
   display_AtopiaCatModel
end menu_UpdateAtopiaFromCatModel

on submenu_TransportServer
   return "Global | Transport | Model | Menu"
end submenu_TransportServer

on _
end _

on menu_Refresh
   display_AtopiaCatModel
end menu_Refresh

on _
end _

on menu_RecentFederationDomains displayView
   put federation_ListRecentDomains() into wikiDomains
   set the displayed_Index ["Recent Federation Domains"] of displayView to wikiDomains
end menu_RecentFederationDomains

on menu_LinearTestDisplayed displayView
   -- see "menu_FedrayLoadUpdate" for async version
   put the displayed_Index of displayView into atopiaFolders
   --
   fedray_LoadCache atopiaFolders
   display_StartFedrayUpdate atopiaFolders, displayView
   --
   repeat for each line wikiDomain in atopiaFolders
      display_Spin wikiDomain, displayView
      --
      put fedwiki_JsonSiteMapUrl (wikiDomain) into sitemapURL
      put url sitemapURL into sitemapJSON
      fedray_UpdateTestMetadata wikiURL, wikiDomain, sitemapJSON
   end repeat
   --
   display_FinishedAtopiaUpdate
   -- fedray_UnLoadedUrls
   fedray_ClearCache
end menu_LinearTestDisplayed

on _
end _

on menu_UpdateFedray displayView
   set the cursor to watch
   --
   put atopia_FetchDomainArray() into atopiaDomainArray
   put fedray_FetchModel() into fedrayWithoutAtopia
   --
   _UpdateWithoutAtopia fedray, fedrayWithoutAtopia, atopiaDomainArray, displayView
   put the result into resultArray
   --
   lcw_Answer "Store fedray?", displayView
   --
   breakpoint
   fedray_StoreModel fedray
   return resultArray
end menu_UpdateFedray

on _
end _

on menu_DisplayAtopiaCatModel
   display_AtopiaCatModel
end menu_DisplayAtopiaCatModel

on menu_BuildWardsWithoutAtopia displayView
   set the cursor to watch
   --
   put atopia_FetchDomainArray() into fedray
   put fedray_FetchUnion() into fedrayWithoutAtopia
   --
   difference fedrayWithoutAtopia with fedray
   put the keys of fedrayWithoutAtopia into withoutAtopiaDomains
   -- 
   _BuildWithoutAtopia fedray, withoutAtopiaDomains, displayView
   put the result into resultArray
   --
   -- lcw_Answer "Store fedray?", displayView
   fedray_StoreModel fedray
   --
   display_Data resultArray, "WithoutAtopia", "Build Wards"
   put the result into displayView
   set the title_Menu of displayView to "Global | Fedray | Rebuild | Menu" 
   --
   return resultArray
end menu_BuildWardsWithoutAtopia

on menu_RebuildNewAtopiaFedray displayView
   put atopia_FetchFolders() into atopiaDomains
   set the displayed_Index of displayView to atopiaDomains
   --
   put atopia_FetchDomainArray() into atopiaDomainArray
   --
   repeat for each line wikiDomain in atopiaDomains
      if the commandKey is "Down" then breakpoint
      display_Spin wikiDomain, displayView, "yellow"
      --
      put fedwiki_FetchSitemapArray (wikiDomain) into sitemapArray
      if sitemapArray is empty then
         put fedray [wikiDomain] into resultArray ["deleted"][wikiDomain]
         delete variable fedray [wikiDomain]
         delete variable atopiaDomainArray [wikiDomain]
      else
         put fedray_FetchNewCreateDomainArray (wikiDomain, sitemapArray) into wikiDomainArray
         fedray_UpdateWikiDomainArray wikiDomainArray, wikiDomain, sitemapArray
         --
         put fedray [wikiDomain] into resultArray ["updated"][wikiDomain]
         put wikiDomainArray into fedray [wikiDomain]
         put wikiDomainArray into atopiaDomainArray [wikiDomain]
      end if
   end repeat
   --
   lcw_Answer "Store fedrays?", displayView
   --
   atopia_StoreModel atopiaDomainArray
   return resultArray
end menu_RebuildNewAtopiaFedray

on menu_RebuildAtopiaFedray displayView
   put atopia_FetchFolders() into atopiaDomains
   set the displayed_Index of displayView to atopiaDomains
   --
   put atopia_FetchDomainArray() into atopiaDomainArray
   put fedray_FetchModel() into fedray
   --
   repeat for each line wikiDomain in atopiaDomains
      if the commandKey is "Down" then breakpoint
      display_Spin wikiDomain, displayView, "yellow"
      --
      put fedwiki_FetchSitemapArray (wikiDomain) into sitemapArray
      if sitemapArray is empty then
         put fedray [wikiDomain] into resultArray ["deleted"][wikiDomain]
         delete variable fedray [wikiDomain]
         delete variable atopiaDomainArray [wikiDomain]
      else
         put fedray_FetchNewCreateDomainArray (wikiDomain, sitemapArray) into wikiDomainArray
         fedray_UpdateWikiDomainArray wikiDomainArray, wikiDomain, sitemapArray
         --
         put fedray [wikiDomain] into resultArray ["updated"][wikiDomain]
         put wikiDomainArray into fedray [wikiDomain]
         put wikiDomainArray into atopiaDomainArray [wikiDomain]
      end if
   end repeat
   --
   lcw_Answer "Store fedrays?", displayView
   --
   atopia_StoreDomainArray atopiaDomainArray
   fedray_StoreModel fedray
   return resultArray
end menu_RebuildAtopiaFedray

on _
end _

on menu_CheckDisplayedLastModified displayView
   put the displayed_Index of displayView into wikiDomains
   put fedwiki_CheckWithSitemapArray (wikiDomains, 7) into resultArray
   --
   display_Data resultArray, "7 days", "fedwiki_CheckWithSitemapArray"
end menu_CheckDisplayedLastModified

on menu_UpdateLastModified
   breakpoint
   put atopia_FetchFolders() into atopiaFolders
   set the displayed_Index ["Atopia Folders"] of indexView to atopiaFolders
   --
   put atopia_FetchDomainArray() into fedray
   --
   set the socketTimeoutInterval to 100
   repeat for each line wikiDomain in atopiaFolders
      display_Spin wikiDomain, indexView
      put the result into lineNum
      --
      put fedwiki_GetlastModified (wikiDomain) into lastModifiedDate
      --
      fedray_StoreSiteCreationDate wikiDomain, siteCreationDate
   end repeat
   set the socketTimeoutInterval to 10000
   --
   lcw_Answer "Store newly created Atopia Fedray?", indexView
end menu_UpdateLastModified

on menu_TestLastModified indexView
   put the displayed_Index of indexView into atopiaDomains
   --
   put fedwiki_CheckWithSitemapArray (atopiaDomains, empty, indexView) into resultArray
   --
   set the coloured_Lines ["green"] of indexView to resultArray ["recent"]
   set the coloured_Lines ["red"] of indexView to resultArray ["no sitemap"]
   set the coloured_Lines ["orange"] of indexView to resultArray ["earlier"]
   set the coloured_Lines ["blue"] of indexView to resultArray ["same"]
   --
   put atopia_FetchDomainArray() into atopiaFedray
   put fedray_FetchModel() into fedray
   repeat for each line atopiaDomain in atopiaDomains
      get resultArray ["recent"][atopiaDomain]
      put it into resultArray ["last modified"][atopiaDomain]["tree"]
      --
      put fedray_GetLastModified (atopiaDomain, atopiaFedray) into atopiaMilliseconds
      put date_ConvertMilliseconds (atopiaMilliseconds) into atopiaLastModified 
      
      put fedray_GetLastModified (atopiaDomain, fedray) into fedrationMilliseconds
      put date_ConvertMilliseconds (fedrationMilliseconds) into fedrationLastModified
      --
      put atopiaLastModified into resultArray ["last modified"][atopiaDomain]["atopiaFedray"]
      put fedrationLastModified into resultArray ["last modified"][atopiaDomain]["fedray"]
   end repeat
   --
   put the title_Text of indexView into indexTitle
   display_Data resultArray, "Last Modified", indexTitle
   put the result into displayView
   --
   set the title_Menu of displayView to "Global | Wiki | LastModified | Menu"
   set the line_Menu of displayView to "Global | Wiki | LastModified | Line | Menu"
end menu_TestLastModified

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_LaunchAtopiaDomainIndex
   fedwiki_Launch "server.fedwiki.org", "Atopia Domain Index"
end menu_LaunchAtopiaDomainIndex

on menu_DisplayAtopiaFedray indexView
   display_AtopiaFedray indexView
end menu_DisplayAtopiaFedray

on _
end _

on menu_UpdateAtopiaConfig
   put atopia_FetchConfigArray() into configArray
   atopia_SetConfigArray configArray
   --
   display_AtopiaConfigJson
end menu_UpdateAtopiaConfig

on menu_UpdateDigitalOceanArrays
   digitalOcean_FetchAndSetDropletArrays
   lcw_AnswerWarning "Updated local Droplet, and domain arrays for Digital Ocean"
end menu_UpdateDigitalOceanArrays

on _
end _

on menu_OldReconstructAtopiaMetadata displayView
   lcw_Answer "Update metadata for all the domains on the Atopia server?", displayView
   -- put atopia_ListNewRosterFolders() into atopiaDomains -- recently added (not in roster)
   put atopia_FetchFolders() into atopiaDomains
   --
   display_TrashUpdateAtopia atopiaDomains, displayView
   put the result into resultArray
   --
   display_Data resultArray, the short date, "Result"
   put resultArray ["Updated"] into addedArray
   put the keys of addedArray into newSites
end menu_OldReconstructAtopiaMetadata

on menu_UpdateAtopiaLastModified displayView
   lcw_Answer "Update the last modified for recently modified Atopia domains?", displayView
   atopia_UpdateLastModifiedDomains displayView
end menu_UpdateAtopiaLastModified

on _
end _

on menu_TestAtopiaFolders displayView
   put atopia_FetchFolders() into atopiaFolders
   fedray_LoadUpdateTests atopiaFolders, displayView
end menu_TestAtopiaFolders

on menu_FedrayLoadUpdate displayView
   put the displayed_Index of displayView into atopiaFolders
   fedray_LoadUpdateTests atopiaFolders, displayView
end menu_FedrayLoadUpdate

on _
end _

on menu_UpdateFederation
   display_UpdateFederation
end menu_UpdateFederation

on menu_CheckAtopiaDomainArray displayView
   put the displayed_Array of displayView into atopiaDomainArray
   put the keys of atopiaDomainArray into atopiaDomains
   repeat for each line wikiDomain in atopiaDomains
      put fedwiki_JsonSiteMapUrl (wikiDomain) into sitemapURL
      load url sitemapURL with "atopia_CheckDomainAndUpdateMetadata"
      exit repeat
   end repeat
end menu_CheckAtopiaDomainArray

on _
end _

on _
end _

on menu_UpdateFederation indexView
   display_UpdateFederation
end menu_UpdateFederation

on menu_UpdateBothFedrays indexView
   display_UpdateBothFedrays indexView
end menu_UpdateBothFedrays

on _
end _

on menu_AddNewFederationSites indexView
   -- only updates indexes (no trashing) - uses "fedray_UpdateLastModified"
   display_AndAddNewFederationSites indexView
end menu_AddNewFederationSites

on _
end _

on menu_StoreAtopiaFoldersAsRoster indexView
   put atopia_FetchFolders() into atopiaDomains
   set the displayed_Index ["Atopia Folders"] of indexView to atopiaDomains
   lcw_Answer "Store the displayed domains to the roster on server.fedwiki.org?", indexView
   --
   url_SortDomainIndex atopiaDomains
   atopia_StoreRoster atopiaDomains
   --
   put atopia_FetchRosterDomains() into newlyStoredRoster
   if newlyStoredRoster = atopiaDomains then
      lcw_Notify "Stored these domains to the roster on server.fedwiki.org"
   else
      put atopiaDomains
      answer warning "Failed to store roster!"
   end if
end menu_StoreAtopiaFoldersAsRoster

on menu_StoreAtopiaFedray indexView
   put atopia_FetchFolders() into atopiaDomains
   set the displayed_Index ["Atopia Folders"] of indexView to atopiaDomains
   --
   lcw_Answer "Create new Atopia fedray from these folders on the Atopia server?", indexView
   --
   local fedray
   repeat for each line wikiDomain in atopiaDomains
      display_Spin wikiDomain, indexView
      fedray_UpdateLastModified fedray, wikiDomain
   end repeat
   --
   lcw_Answer "Store newly created Atopia Fedray?", indexView
   atopia_StoreDomainArray fedray
   --
   display_AtopiaFedrayDomains
end menu_StoreAtopiaFedray

on _
end _

on menu_DisplayMissingSitemaps indexView
   put the displayed_Array of indexView into resultArray
   put resultArray ["missing sitemap"] into missingDomainArray
   put keys (missingDomainArray) into missingDomains
   url_SortDomainIndex missingDomains
   set the displayed_Index ["Missing CSE Sitemaps"] of indexView to missingDomains
end menu_DisplayMissingSitemaps

on menu_UnloadCached
   put the cachedurls into cURLs
   display_Lines cURLs, "Cached URLs", empty, "menu_UnloadCached"
   put the result into indexView
   --
   repeat for each line someURL in cURLs
      display_Spin someURL, indexView
      put the result into lineNum
      unload url someURL
      set the deleted_Line of indexView to someURL
   end repeat
   --
   put the stack_Name of indexView into stackName
   delete stack stackName
end menu_UnloadCached

on _
end _

on menu_AddOwnedToFedray indexView
   put atopia_GetLocalEmailOwnerData() into ownershipArray
   fedray_AddOwnershipArray ownershipArray, "atopia.array"
end menu_AddOwnedToFedray

on menu_BuildAtopiaDnsArray indexView
   put "Do you want to build the dns array for all server side (good) wiki folders?" into someQuestion
   lcw_Answer someQuestion, indexView
   --
   atopia_ConstructDnsArray true
   --
   menu_DisplayAtopiaArray indexView
end menu_BuildAtopiaDnsArray

on menu_BuildAtopiaDomainArray someQuestion
   put "This is very slow! Update instead?" into someQuestion
   lcw_Answer someQuestion, indexView
   --
   put atopia_FetchAndBuildArray() into pAtopiaData
   atopia_SetData pAtopiaData   
   --
   display_AtopiaDomainErrorArray
end menu_BuildAtopiaDomainArray


--> Deps
-
command digitalOcean_FetchAndSetDropletArrays
   digitalocean_UpdateDropletInfoArray
   if the result is not an array then
      lcw_Answer "Fetching DropletInfoArray failed"
   end if
   
   digitalocean_UpdateDomainInfoArray
   if the result is not an array then
      lcw_Answer "Fetching DomainInfoArray failed"
   end if
   
   put atopia_FetchConfigArray() into configArray
   if the result is not an array then
      lcw_Answer "Fetching configArray failed"
   end if
   atopia_SetConfigArray configArray
end digitalOcean_FetchAndSetDropletArrays
