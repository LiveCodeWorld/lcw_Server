script "lib_DisplayFedray"
--> MetaData
-
license: GPLv3
name: lib_DisplayFedray
type: library
version: 0.4


--> Working on
-
command display_FederationServers
   put fedserver_FetchModel() into sModel
   --
   display_Tools sModel, "Federation Servers", "Federation | Server", "LCW", "lcw_Server"
end display_FederationServers

command display_FederationModels
   put transport_ListModelFiles() into shortFiles
   --
   display_Tools shortFiles, "Federation Models", "Federation | Model", "LCW", "lcw_Revigniter"
   put the result into displayView
   --
   return displayView
end display_FederationModels

command display_FederationBuilder
   put atopia_FetchRosterDomains() into atopiaDomains
   --
   display_Data atopiaDomains, "All", "Federation Builder"
   put the result into displayView
   display_SetInteractions displayView, "Federation | Build", "mDoubleUp_WikiDomain"
   return displayView
end display_FederationBuilder

command display_FedrayUpdate fedray, titleText
   put keys (fedray) into fedDomains
   url_SortDomainindex fedDomains
   --
   put display_FindView ("Federation", titleText) into indexView
   if exists (indexView) then
      set the displayed_Index of indexView to fedDomains
   else
      display_Lines fedDomains, titleText, "mDoubleUp_Test", "Federation"
      put the result into indexView
      set the title_Menu of indexView to "Global | Federation | Build | Menu"
   end if
   return indexView
end display_FedrayUpdate


--> Display | Fedray | Atopia
-
command display_AtopiaFedray pDisplayView
   put atopia_FetchDomainArray() into fedray
   -- put keys (fedray) into fedDomains
   -- url_SortDomainindex fedDomains
   --
   display_Data fedray, "Atopia Domains", "Atopia Fedray", pDisplayView
   put the result into pDisplayView
   display_SetInteractions pDisplayView, "Atopia | Build", "mDoubleUp_WikiDomain"
   return pDisplayView
end display_AtopiaFedray

command display_Fedray
   put fedray_FetchModel() into fedray
   display_Data fedray, "Federation Model", "Federation"
   put the result into displayView
   display_SetInteractions displayView, "Federation", "mDoubleUp_WikiDomain"
   -- set the title_Menu of displayView to  "Global | Federation | Build | Menu"
end display_Fedray


--> Display | Update | Old
-
command display_UpdateBothFedrays indexView
   -- not too sure about this one (complex)
   -- updates both fedrays
   -- does not trash sites
   put federation_FetchRecentSites ("1 week", true)  into thisWeeksModifiedSites
   
   put digitalocean_FetchDropletIP ("Atopia") into atopiaIP
   --
   sort thisWeeksModifiedSites
   set the displayed_Index ["Updating Fedray"] of indexView to thisWeeksModifiedSites
   --
   put fedray_FetchModel() into fedray
   put atopia_FetchDomainArray() into atopiaFedray
   --
   repeat for each line wikiDomain in thisWeeksModifiedSites
      display_Spin wikiDomain, indexView
      put the result into lineNum
      --
      fedray_UpdateModified fedray, wikiDomain -- no trashing
      put the result into sitemapArray
      if sitemapArray is not an array then
         delete variable fedray [wikiDomain]
         delete variable atopiaFedray [wikiDomain]
         set the coloured_Line [lineNum] of indexView to "red"
         next repeat
      end if
      --
      put wikiDomain & CR after updatedSites
      put fedray [wikiDomain]["ipAddress"] into ipAddress
      --
      if ipAddress = atopiaIP then
         put fedray [wikiDomain]["last modified"] into lastModified
         put atopiaFedray [wikiDomain]["last modified"] into lastUpdated
         if lastModified > lastUpdated then
            -- let's update this Atopia Domain
            fedray_UpdateModified atopiaFedray, wikiDomain, sitemapArray   
         end if
      end if
   end repeat
   delete char -1 of updatedSites
   --
   atopia_StoreDomainArray atopiaFedray
   fedray_StoreModel fedray
   --
   -- now update rosters?
   put keys (atopiaFedray) into atopiaDomains
   url_SortDomainIndex atopiaDomains
   atopia_StoreRoster rosterText
   --
   url_SortDomainIndex thisWeeksModifiedSites
   set the displayed_Index ["Updated Sites"] of indexView to updatedSites
end display_UpdateBothFedrays

command display_RecentSites pSincePeriod, pDisplayView, pPalette
   if pSincePeriod is empty then put "1 week" into pSincePeriod
   --
   put fedray_FetchRecentSites (pSincePeriod, true) into modifiedSites
   --   
   put "Global | Federation | Tree | Menu" into mTitle
   put "Global | Federation | Line | Menu" into mLineTitle
   --
   display_Data modifiedSites, pSincePeriod, "Federation", pDisplayView, pPalette
   put the result into pDisplayView
   display_SetIndexMenus pDisplayView, mTitle, mLineTitle, mDoubleUp
   --
   return pDisplayView
end display_RecentSites

command display_RecentAtopiaSites pSincePeriod, pIndexView
   local mDoubleUp
   if pSincePeriod is empty then put "1 week" into pSincePeriod
   --
   put date_GetSinceSeconds (pSincePeriod) into sinceSeconds 
   put atopia_ListRecentDomains (sinceSeconds) into modifiedSites
   --
   put "Global | Atopia | Tree | Menu" into mTitle
   put "Global | Atopia | Line | Menu" into mLineTitle
   --
   display_Atopia pSincePeriod, modifiedSites, mTitle, mLineTitle, mDoubleUp, pIndexView
   put the result into indexView
   return indexView
end display_RecentAtopiaSites


--> Display | Fedray
-
command display_AtopiaFedrayDomains pIndexView
   local mDoubleUp
   --
   put atopia_ListDomainsFromFedray() into fedrayDomains
   --
   put "Global | Atopia | Tree | Menu" into mTitle
   put "Global | Atopia | Line | Menu" into mLineTitle
   --
   display_Atopia "Fedray Domains", fedrayDomains, mTitle, mLineTitle, mDoubleUp, pIndexView
   put the result into indexView
   return indexView
end display_AtopiaFedrayDomains


--> Display | Fedray
- 
command display_FederationServers
   put federation_FetchModel ("Server Model") into serverModel
   --
   put "Server Model,Federation" into stackTitle
   put display_FindView ("Federation", "Server Model") into arrayView
   if exists (arrayView) then -- let's refresh
      set the displayed_Data of arrayView to serverModel
   else
      display_Array serverModel, stackTitle
      put the result into displayView
      display_SetInteractions displayView, "Federation | Server", ""
      set the title_Menu of displayView to "Global | Federation | Menu"
   end if
   return displayView
end display_FederationServers

command display_LocalFedray
   local pMouseUpCommand
   put fedray_GetArray ("atopia.array") into atopiaArray
   put atopiaArray ["domain"] into domainArray
   put keys (domainArray) into domainNames
   url_SortDomainIndex domainNames
   display_Index domainNames, "Local Atopia Domains,Fedray", "Global | Atopia | Top | Menu", "Global | Atopia | Top | Line | Menu"
   put the result into displayView
   return displayView
end display_LocalFedray
