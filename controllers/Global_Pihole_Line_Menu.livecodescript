script "Global | Pihole | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Pihole | Line | Menu
type: controller
version: 0.2

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into LocalArray ["dView"]
   put the displayed_Object of tObject into sObject
   return sObject
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget

on mDoubleUp_Pihole dView, wikiDomain
   display_WikiPiShortFolders "pi4.local", wikiDomain
   display_WikiPiShortFolders "pi5.local", wikiDomain
   --
   display_LocalWikiDomains wikiDomain
   --
   display_PiholeSubdomains wikiDomain
   --
   display_Wiki wikiDomain
end mDoubleUp_Pihole

private command _SetParams dView, @domainName, @ipAddress
   put the domain_Array of dView into indexArray
   --
   put the selected_Line of dView into domainName
   put indexArray_GetNamed (indexArray, domainName, 2, 1) into ipAddress
   --
   return indexArray
end _SetParams


--> Global | Pihole | Line | Menu
-
on menu_DisplayWiki dView
   _SetParams dView, wikiDomain, ipAddress
   --
   display_Wiki wikiDomain
end menu_DisplayWiki

on menu_DisplayWikiPages dView
   _SetParams dView, domainName, ipAddress
   --
   put wikiPi_ListShortFolders (localHostName, domainName) into domainNames
   breakpoint
   display_Tool domainNames, domainName, "Pi Domains", "lcw_Wiki"
   
   -- could set the rollover
   put the result into dView
   set the title_Rollover of dView to localHostName -- does not display (yet)
   return dView
end menu_DisplayWikiPages

private on _
end _

on menu_WikipiLocalData dView
   _SetParams dView, domainName, ipAddress
   put url_GetTld (domainName) into tldDomain
   --
   display_WikiPiLocalData tldDomain
end menu_WikipiLocalData

on menu_DisplayLocalGardens
   display_LocalWikis
end menu_DisplayLocalGardens

on menu_LocalSubdomains dView
   _SetParams dView, domainName, ipAddress
   --
   display_LocalSubdomains domainName
end menu_LocalSubdomains

on menu_PiholeSubdomains dView
   _SetParams dView, domainName, ipAddress
   --
   display_PiholeSubdomains domainName
end menu_PiholeSubdomains

private on __
end __

on menu_MoveDomain dView
   _SetParams dView, domainName, ipAddress
   --
   breakpoint
end menu_MoveDomain

getprop moveDomain_Param [dView]
   _SetParams dView, domainName, ipAddress
   return pihole_AddressToName(ipAddress)
end moveDomain_Param

getprop moveDomain_Params
   return pihole_ListNames()
end moveDomain_Params

on menu_RenameDomain dView
   _SetParams dView, domainName, ipAddress
   --
   breakpoint
end menu_RenameDomain

on menu_DeleteDomain dView
   _SetParams dView, domainName, ipAddress
   --
   pihole_DeleteCustomDomain domainName, ipAddress
   if the result is not empty then
      breakpoint
   else
      display_PiholeTools
   end if
end menu_DeleteDomain

private on __
end __

on menu_DisplayPiholeAdmin
   display_PiholeAdmin
end menu_DisplayPiholeAdmin

on menu_Refresh
   display_PiholeTools
end menu_Refresh

private on ___
end ___

on submenu_Dev
   return menu_DevTitle ("Global | Pihole | Line | Menu")
end submenu_Dev
