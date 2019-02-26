script "Global_Atopia_Tree_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_Tree_Menu
type: controller
version: 0.4


--> Global | Atopia | Tree | Menu
-
on menu_CreateSitePages indexView
   -- put atopia_FetchStoredDomains() into atopiaDomains
   put atopia_FetchAllLiveDomains() into atopiaDomains
   
   put "sites.fedwiki.org" into sitesDomain
   set the displayed_Index ["Creating Pages"] of indexView to atopiaDomains
   --
   repeat for each line wikiDomain in atopiaDomains
      display_IndexSpin wikiDomain, indexView
      put the result into lineNum 
      --
      put fedwiki_FetchSiteIndexJSON (wikiDomain) into pageJSON
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
end menu_CreateSitePages

on menu_ProcessNewFolders indexView
   lcw_AnswerSheet "Check if new folders are bad and trash, move to unhosted and update them?"
   --
   atopia_UpdateArrayAndMove
   put the result into resultArray
   --
   display_AtopiaUpdateResult resultArray, indexView
end menu_ProcessNewFolders

on _
end _

on menu_CheckFolders indexView
   put atopia_FetchAllLiveDomains() into allDomains
   set the displayed_Index ["Hosted Folders"] of indexView to allDomains
   -- 
   repeat for each line domainName in allDomains
      display_IndexSpin domainName, indexView
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
end menu_CheckFolders

on menu_StoreDisplayedDomainArray indexView
   put the displayed_Index of indexView into allDomains
   -- put atopia_FetchAllLiveDomains() into allDomains
   atopia_StoreServerDomainArray allDomains
   --
   display_AtopiaFolders "Stored Atopia"
end menu_StoreDisplayedDomainArray

on menu_CheckGoogled indexView
   put atopia_FetchAllLiveDomains() into allDomains
   set the displayed_Index ["Googled Folders"] of indexView to allDomains
   --
   put cse_FetchConsoleDomains() into consoleDomainNames
   if consoleDomainNames is empty then
      resetall
      put cse_FetchConsoleDomains() into consoleDomainNames
      if consoleDomainNames is empty then
         breakpoint
      end if
   end if
   --
   set the wholematches to true
   repeat for each line domainName in allDomains
      display_IndexSpin domainName, indexView
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
   set the displayed_Index ["Missing domains"] of indexView to missingDomains
   display_Array resultArray
end menu_CheckGoogled

on menu_DisplayMisingSitemaps indexView
   put the displayed_Array of indexView into resultArray
   put resultArray ["missing sitemap"] into missingDomainArray
   put keys (missingDomainArray) into missingDomains
   url_SortDomainIndex missingDomains
   set the displayed_Index ["Missing domains"] of indexView to missingDomains
end menu_DisplayMisingSitemaps

on _
end _

on menu_StoreAtopiaDomainArray
   -- Store a Ward compatible json array in the json-plugin found at
   -- http://sites.fedwiki.org/atopia-domain-index.html
   atopia_StoreServerDomainArray
   --
   display_AtopiaFolders "Stored Atopia"
end menu_StoreAtopiaDomainArray

on menu_StoreAuthorArray
   put "david.bovill@gmail.com" into ownerEmail
   --
   put atopia_GetOwnershipArray() into ownershipArray
   put atopia_GetGoodDomainArray() into atopiaGoodArray
   put ownershipArray [ownerEmail]["domains"] into authorDomainArray
   repeat with itemNum =1 to item 2 of the extents of authorDomainArray
      set the cursor to busy
      put authorDomainArray [itemNum]["domain"] into domainName
      put atopiaGoodArray [domainName] into pageSlugs
      put the number of lines of pageSlugs into numOfPages
      put numOfPages into wDomainArray [domainName]["pages"]
   end repeat
   --
   atopia_StorePersonArray "people-template", wDomainArray
   -- atopia_StorePersonArray "david-bovill", wDomainArray
   put atopia_FetchPersonJSON ("david-bovill")
end menu_StoreAuthorArray

on menu_StoreFederationArray
   -- Store Ward's json array in the json-plugin found at
   -- http://sites.fedwiki.org/federation-domain-index.html
   federation_StoreDomainArray
end menu_StoreFederationArray

on _
end _

on submenu_Display
   return "Global | Atopia | Display | Menu"
end submenu_Display

on submenu_Check
   return "Global | Atopia | Check | Menu"
end submenu_Check

on submenu_Build
   return "Global | Atopia | Build | Menu"
end submenu_Build

on _
end _

on submenu_Atopia
   return "Global | Server | Menu"
end submenu_Atopia

on submenu_Dynadot
   return "Global | Dynadot | Menu"
end submenu_Dynadot

on _
end _

on menu_Refresh indexView
   display_AtopiaFolders
end menu_Refresh

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Test
   put fedwiki_FetchSiteIndexJSON ("david.bovill.me") into pageJSON
   display_JSON pageJSON
end menu_Test

on menu_MoveBadFolders indexView
   put atopia_ListLocalBadFolders() into domainNames
   atopia_SetDisplay indexView, domainNames, "Bad Folders"   
   lcw_AnswerWarning "Move all these bad folders to the _trash folder?"
   --
   atopia_MoveAllBadFoldersToTrash indexView
   put the result into missingFolders
   put missingFolders
   --
   put atopia_ListLocalBadFolders() into domainNames
   atopia_SetDisplay indexView, domainNames, "Bad Folders"   
end menu_MoveBadFolders

on menu_MoveUnhostedBadFolders indexView
   put atopia_ListLocalBadFolders() into domainNames
   atopia_SetDisplay indexView, domainNames, "Bad Folders"   
   lcw_AnswerSheet "Move all unhosted folders to the _unhosted_sites folder?"
   --
   atopi_MoveGoodToUnhosted
   --
   put the result into atopiaData
   put the keys of atopiaData ["_unhosted_sites"] into domainNames
   
   atopia_SetDisplay indexView, domainNames, "Unhosted Folders"
end menu_MoveUnhostedBadFolders

on menu_DomainLsArray indexView
   put atopia_FetchFilteredFolderLsArray() into wikiFolderArray
   display_Array wikiFolderArray
end menu_DomainLsArray

on menu_DisplayMyDomains indexView
   put "david.bovill@gmail.com" into userEmail
   
   put atopia_GetDomainsFromEmail (userEmail)
end menu_DisplayMyDomains


--> Global | Atopia | Tree | Menu | Props
-

--> Global | Atopia | Tree | Menu | Disabled
-

--> Private
-
