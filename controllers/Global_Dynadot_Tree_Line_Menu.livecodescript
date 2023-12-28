script "Global | Dynadot | Tree | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Dynadot | Tree | Line | Menu
type: controller
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget

getprop disabled_CreateLocalWiki [dView]
   put the selected_Line of dView into wikiDomain
   --
   put wiki_GetFolder (wikiDomain) into wikiFolder
   return wikiFolder is not empty
end disabled_CreateLocalWiki


--> Global | Dynadot | Tree | Line | Menu
-
on menu_DisplayWiki dView
   put the selected_Line of dView into wikiDomain
   --
   put wiki_Browser() into browserView
   display_Wiki wikiDomain, browserView
end menu_DisplayWiki

on menu_CreateLocalWiki  dView
   put the selected_Line of dView into wikiDomain
   --
   put wiki_ConstructFolder (wikiDomain) into wikiFolder
   put system_GetAdminPassword() into systemPassword
   hosts_Add wikiDomain, systemPassword
   --
   put wiki_Browser() into browserView
   display_Wiki wikiDomain, browserView
end menu_CreateLocalWiki

private on _
end _

on menu_DisplayDomainInfo dView
   put the selected_Line of dView into domainName
   --
   display_DynadotDomainInfo domainName
end menu_DisplayDomainInfo

on menu_DisplayDns indexView
   put the selected_Line of indexView into domainName
   --
   put dynadot_GetDns (domainName) into dnsData
   --
   display_Data dnsData, "dynadot_GetDns()", domainName
end menu_DisplayDns

on submenu_Dev
   return menu_DevTitle ("Global | Dynadot | Tree | Line | Menu")
end submenu_Dev
