script "Global_Atopia_Build_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_Build_Menu
type: menu
version: 0.2


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
   
getprop disabled_CheckDisplayedFolders
   if LocalArray ["newFolderIndex"] is empty then
      return true
   else
      return false
   end if
end disabled_CheckDisplayedFolders


--> Global | Atopia | Build | Menu
-
on menu_CheckDisplayedFolders indexView
   -- set the displayed_Index ["Hosted Folders"] of indexView to allDomains
   lcw_AnswerSheet "Check if displayed folders are bad. Move to trash, or unhosted..."
   put the displayed_Index of indexView into allDomains
   set the title_Text of indexView to "Checking sites..."
   -- 
   repeat for each line domainName in allDomains
      display_Spin domainName, indexView
      put the result into lineNum
      --
      if atopia_WikiHasPages (domainName) then
         if atopia_WikiIsHosted (domainName) then
            set the line_Colour [lineNum] of indexView to green
         else
            set the cursor to watch
            set the line_Colour [lineNum] of indexView to red
            atopia_MoveToUnhosted domainName
            put the result into atopiaArray
            set the deleted_Line of indexView to domainName
         end if
      else
         set the line_Colour [lineNum] of indexView to red
         set the cursor to watch
         atopia_MoveToTrash domainName
         put the result into atopiaArray
         --
         set the deleted_Line of indexView to domainName
      end if
   end repeat
   set the title_Text of indexView to "New Folders"
end menu_CheckDisplayedFolders

on menu_FedrayUpdater indexView
   lcw_Answer "Spin through Atopia Fedray, and update the Atopia domain array (Atopia Fedray). Do not save to server yet...", indexView
   --
   put atopia_FetchFedray() into fedray
   display_FedrayUpdate fedray, "Atopia Fedray"
   put the result into indexView
end menu_FedrayUpdater

on menu_StoreAtopiaFedray indexView
   -- put display_FindView ("Atopia") into indexView
   -- if exists (indexView) is false then
   --
   put atopia_FetchDomains ("folder") into atopiaDomains
   set the displayed_Index ["Atopia Folders"] of indexView to atopiaDomains
   --
   lcw_Answer "Create new Atopia fedray from these folders on the Atopia server?", indexView
   --
   local fedray
   repeat for each line wikiDomain in atopiaDomains
      display_Spin wikiDomain, indexView
      fedray_UpdateDomain fedray, wikiDomain, false
   end repeat
   --
   lcw_Answer "Store newly created Atopia Fedray?", indexView
   atopia_StoreFedray fedray
   --
   display_AtopiaDomains "Domain Array"
end menu_StoreAtopiaFedray

on menu_StoreAtopiaDomainRoster indexView
   -- put display_FindView ("Atopia", "New Folders") into indexView
   lcw_Answer "Store Atopia Fedray in Atopia Domain Index roster on wiki server.fedwiki.org?", indexView
   --
   put atopia_FetchFedrayDomains() into atopiaDomains
   atopia_StoreRoster atopiaDomains
   --
   put atopia_FetchRoster() into atopiaDomains
   set the displayed_Index ["Atopia Roster"] of indexView to atopiaDomains
end menu_StoreAtopiaDomainRoster

on _
end _

on menu_CreateAtopiaSitePages indexView
   put atopia_SitePagesToCreate() into atopiaDomains
   set the displayed_Index ["Creating Pages"] of indexView to atopiaDomains
   --
   lcw_AnswerSheet 
   dispatch "lcw_AnswerSheet" to indexView with "Are you sure you want to create all these new pages?"
   --
   put "sites.fedwiki.org" into sitesDomain
   repeat for each line wikiDomain in atopiaDomains
      display_Spin wikiDomain, indexView
      put the result into lineNum 
      --
      put fedwiki_FetchCitePageJSON (wikiDomain) into pageJSON
      if pageJSON is empty then
         breakpoint
         next repeat
      end if
      --
      put fedwiki_ConstructSlug (wikiDomain) into pageSlug
      put fedwiki_ConstructPath (sitesDomain, pageSlug) into wikiPagePath
      atopia_StoreData wikiPagePath, pageJSON
      
      put the result into shellResult
      if shellResult is not empty then
         breakpoint
      end if
   end repeat
   -- now should update the sitemap
   atopia_DeleteWikiSitemap sitesDomain
end menu_CreateAtopiaSitePages

on _
end _

on menu_CheckGoogled indexView
   put atopia_FetchFolders() into allDomains
   set the displayed_Index ["Googled Folders"] of indexView to allDomains
   lcw_Answer "Check all Atopia Folders for CSE status, and display coloured line result?", indexView
   --
   put cse_FetchConsoleDomains() into consoleDomainNames
   if consoleDomainNames is empty then
      breakpoint
      exit to top
   end if
   --
   set the wholematches to true
   repeat for each line domainName in allDomains
      display_Spin domainName, indexView
      put the result into lineNum
      --
      if domainName is among the lines of consoleDomainNames then
         put cse_ListSitemaps (domainName) into siteMaps
         if siteMaps is empty then
            set the line_Colour [lineNum] of indexView to orange
            put true into resultArray ["missing sitemap"][domainName]
         else
            set the line_Colour [lineNum] of indexView to green
            put true into resultArray ["good sitemap"][domainName]
         end if
      else
         put true into resultArray ["missing domain"][domainName]
         set the line_Colour [lineNum] of indexView to red
      end if
   end repeat
   set the displayed_Array of indexView to resultArray
   --
   put resultArray ["missing domain"] into missingDomainArray
   put keys (missingDomainArray) into missingDomains
   url_SortDomainIndex missingDomains
   set the displayed_Index ["Missing CSE Domains"] of indexView to missingDomains
   --
   display_Array resultArray, "Atopia,Google CSE Status"
end menu_CheckGoogled

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


--> END
-
on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_UpdateDigitalOceanArrays
   digitalOcean_FetchAndSetDropletArrays
   lcw_AnswerWarning "Updated local Droplet, and domain arrays for Digital Ocean"
end menu_UpdateDigitalOceanArrays

on menu_UpdateAtopiaConfig
   put atopia_FetchConfigArray() into configArray
   atopia_SetConfigArray configArray
   --
   display_AtopiaConfigArray
end menu_UpdateAtopiaConfig

on _
end _

on menu_BuildOwnershipArray indexView
   lcw_AnswerSheet "Do you want to build an ownership array for all server side (good) wiki folders?"
   --
   atopia_ConstructOwnershipArray true, indexView
   put the result into ownershipArray
   breakpoint
   fedray_AddOwnershipArray ownershipArray, "atopia.array"
   --
   lcw_AnswerSheet "Built and saved ownership array!"
   --
   display_AtopiaDomains "Domain Owners"
end menu_BuildOwnershipArray

on menu_AddOwnedToFedray indexView
   put atopia_GetOwnershipArray() into ownershipArray
   fedray_AddOwnershipArray ownershipArray, "atopia.array"
end menu_AddOwnedToFedray

on menu_BuildAtopiaDnsArray indexView
   lcw_AnswerSheet "Do you want to build the dns array for all server side (good) wiki folders?"
   --
   atopia_ConstructDnsArray true
   --
   menu_DisplayAtopiaArray indexView
end menu_BuildAtopiaDnsArray

on menu_BuildAtopiaDomainArray
   lcw_AnswerSheet "This is very slow! Update instead?"
   --
   put atopia_FetchAndBuildArray() into pAtopiaData
   atopia_SetData pAtopiaData   
   --
   display_AtopiaDomains "All Local Wiki Folders"
   display_AtopiaDomainErrorArray
end menu_BuildAtopiaDomainArray


--> Deps
-
--> Deps
-
function fedwiki_FetchCitePageJSON wikiDomain
   put merge ("http://[[wikiDomain]]/view/welcome-visitors") into lineUpURL
   put fedwiki_ConstructFlagDropJson (lineUpURL) into someJSON
   fedwiki_PostJSON someJSON, "http://home.c2.com:4010/cite"
   put the result into pageJSON
   return pageJSON
end fedwiki_FetchCitePageJSON

function fedwiki_ConstructFlagDropJson lineUpURL
   set the itemdelimiter to slash
   put item 1 to 3 of lineUpURL into wikiDomain
   get merge ("{'text':'','html':'<meta http-equiv=\'Content-Type\' content=\'text/html;charset=UTF-8\'><img src=\'http://[[wikiDomain]]/favicon.png\' height=\'32px\' class=\'favicon\'>','url':'[[lineUpURL]]'}")
   replace "'" with quote in it
   return it
end fedwiki_ConstructFlagDropJson

command digitalOcean_FetchAndSetDropletArrays
   digitalocean_UpdateDropletInfoArray
   if the result is not an array then
      lcw_AnswerSheet "Fetching DropletInfoArray failed"
   end if
   
   digitalocean_UpdateDomainInfoArray
   if the result is not an array then
      lcw_AnswerSheet "Fetching DomainInfoArray failed"
   end if
   
   put atopia_FetchConfigArray() into configArray
   if the result is not an array then
      lcw_AnswerSheet "Fetching configArray failed"
   end if
   atopia_SetConfigArray configArray
end digitalOcean_FetchAndSetDropletArrays
