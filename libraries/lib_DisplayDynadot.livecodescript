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


--> Working on
-
command display_Dynadot pIndexView
   put dynadot_ListDomainNames() into domainNames
   --   
   _DisplayDynadot domainNames, "Dynadot Domains", pIndexView
   return the result
end display_Dynadot

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


--> Dynadot | Display
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
