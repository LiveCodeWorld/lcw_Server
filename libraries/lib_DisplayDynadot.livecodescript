script "lib_DisplayDynadot"
--> MetaData
-
license: GPLv3
name: lib_DisplayDynadot
type: library
version: 0.1

/*
A library for displaying Dynadot interfaces and tools.
*/


--> Events
-
on mDouble_Dynadot indexView, domainName
   display_DynadotDomainInfo domainName
end mDouble_Dynadot

on mDoubleUp_DynadotDomain displayView, wikiDomain
   -- put the title_Text of displayView into someTitle
   launch url ("http://" & wikiDomain)
end mDoubleUp_DynadotDomain


--> Working on
-
command display_AstralDynadotWikis pDisplayView
   put dynadot_ListAstralDomains() into astralDomains
   url_SortDomainIndex astralDomains
   --
   display_WikiFolders astralDomains, "Wiki | Dynadot", pDisplayView, "", "Astral", "Dynadot Wikis"
   put the result into dView
   return dView
end display_AstralDynadotWikis

command display_DynadotWikis domainName, pDisplayView, pFilter
   if exists (pDisplayView) is false then
      put display_FindIndexView ("Dynadot", "Earth Wikis") into pDisplayView
   end if
   --
   put dynadot_ListAllSubDomain (domainName) into wikiDomains
   --
   if pFilter is not empty then
      filter wikiDomains with pFilter
   end if
   --
   display_Data wikiDomains, domainName, "Dynadot", pDisplayView
   put the result into dView
   display_SetToolMenus "Wiki | Earth", dView, "lcw_Wiki"
   return dView
end display_DynadotWikis


--> Display | Dynadot
-
command display_DynadotDomain domainName
   put dynadot_ListAllSubDomain (domainName) into domainNames
   -- 
   display_Data domainNames, domainName, "Dynadot"
   put the result into dView
   display_SetToolMenus "Dynadot | Domain", dView, "lcw_Server"
   return domainName
end display_DynadotDomain

command display_Dynadot pIndexView, pFilter
   put dynadot_ListDomainNames() into domainNames
   --
   if pFilter is not empty then
      filter domainNames with pFilter
      put pFilter into sTitle
   else
      put "Dynadot Domains" into sTitle
   end if
   --   
   _DisplayDynadot domainNames, sTitle, pIndexView
   return the result
end display_Dynadot


--> Display | Dynadot | Ocean
-
command display_DynadotOcean pIndexView
   put dynadot_ListOceanDomainNames() into domainNames
   --
   _DisplayDynadot domainNames, "Ocean Domains", pIndexView
   return the result
end display_DynadotOcean

command display_DynadotManaged pIndexView
   put dynadot_ListManagedDomainNames (true) into domainNames
   --
   _DisplayDynadot domainNames, "Managed Domains", pIndexView
   return the result
end display_DynadotManaged

command display_DynadotParked pIndexView
   put dynadot_ListParkedDomainNames() into domainNames
   --
   _DisplayDynadot domainNames, "Parked Domains", pIndexView
   return the result
end display_DynadotParked

command display_DynadotDomainInfo domainName
   local pInspect, pDoubleUp, pCommandObject
   
   set the cursor to watch
   put dynadot_GetDomainInfoArray (domainName, true) into domainInfoArray
   --
   put display_FindView ("Domain Info", domainName) into displayView
   if exists (displayView) is true then
      set the displayed_Array of displayView to domainInfoArray
   else
      display_Array domainInfoArray, domainName, "Domain Info"
      put the result into displayView
      display_SetInteractions displayView, "Dynadot | DomainInfo", ""
   end if
   --
   put the stack_Name of displayView into stackName
   go to stack stackName
   --
   return displayView
end display_DynadotDomainInfo

--> Private
-
private command _DisplayDynadot domainNames, titleText, pDisplayView  
   put "Dynadot" into stackLabel
   --
   if pDisplayView is empty then
      put display_FindView (stackLabel) into pIndexView
   end if
   
   if exists (pDisplayView) then
      set the displayed_Index [titleText] of pDisplayView to domainNames
   else
      put "mDouble_Dynadot" into mDoubleClick
      --
      display_Data domainNames, titleText, stackLabel
      -- display_Lines domainNames, titleText, mDoubleClick, stackLabel
      put the result into pDisplayView
      --
      put "Global | Dynadot | Menu" into titleMenu
      put "Global | Dynadot | Tree | Line | Menu" into lineMenu
      --
      set the title_Menu of pDisplayView to titleMenu
      set the line_Menu of pDisplayView to lineMenu
      set the mouse_DoubleUp of pDisplayView to mDoubleClick
   end if
   return pDisplayView
end _DisplayDynadot

private command _DisplayDynadot domainNames, displayTitle, pIndexView
   display_Lines domainNames, displayTitle, "mDouble_Dynadot", "Dynadot", true
   put the result into displayView
   --
   set the title_Menu of displayView to "Global | Dynadot | Menu"
   set the line_Menu of displayView to "Global | Dynadot | Tree | Line | Menu"
   --
   return displayView
end _DisplayDynadot
