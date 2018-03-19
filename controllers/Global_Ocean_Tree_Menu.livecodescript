script "Global_Ocean_Tree_Menu"
--> MetaData
-
license: GPLv3
name: Global_Ocean_Tree_Menu
type: controller
version: 0.1


--> Global | Ocean | Tree | Menu
-
on menu_DynadotManagedDomains indexView
   put dynadot_ListManagedDomainNames (true) into domainNames
   --
   _DisplayDomains domainNames, "Managed Domains", "dynadot_ListManagedDomainNames()", indexView
end menu_DynadotManagedDomains

on menu_DynadotOceanDomains indexView
   put dynadot_ListOceanDomainNames() into domainNames
   --
   _DisplayDomains domainNames, "Ocean Domains", "dynadot_ListOceanDomainNames()", indexView
end menu_DynadotOceanDomains

on menu_DynadotParkedDomains indexView
   put dynadot_ListParkedDomainNames() into domainNames
   --
   _DisplayDomains domainNames, "Parked Domains", "dynadot_ListParkedDomainNames()", indexView
end menu_DynadotParkedDomains

on menu_DynadotDomains indexView
   put dynadot_ListDomainNames() into domainNames
   --
   _DisplayDomains domainNames, "Dynadot Domains", "dynadot_ListDomainNames()", indexView
end menu_DynadotDomains

on _
end _

on submenu_Dynadot
   return "Global | Dynadot | Menu"
end submenu_Dynadot


--> Global | Ocean | Tree | Menu | Props
-

--> Global | Ocean | Tree | Menu | Disabled
-

--> Private
-
private command _DisplayDomains domainNames, displayTitle, stackLabel, indexView
   -- display_Lines domainNames, displayTitle
   set the displayed_Index of indexView to domainNames
   --
   set the title_Text of indexView to displayTitle
   set the stack_Label of indexView to stackLabel
   --
   -- set the title_Menu of indexView to "Global | Ocean | Tree | Menu"
   -- set the line_Menu of indexView to "Global | Ocean | Line | Menu"
   --
   -- set the event_Target of indexView to callingObject
end _DisplayDomains
