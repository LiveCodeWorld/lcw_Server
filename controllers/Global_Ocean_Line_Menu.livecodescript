script "Global_Ocean_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_Ocean_Line_Menu
type: controller
version: 0.1


--> Global | Ocean | Line | Menu
-
on menu_SetParked indexView
   put the selected_Line of indexView into domainName
   --
   dynadot_SetParking domainName
   --
   display_DynadotDomainInfo domainName
end menu_SetParked

on _
end _

on menu_SetDynadotFolder indexView
   put the selected_Line of indexView into domainName
   --
   dynadot_SetFolder domainName, "Atopia"
   --
   display_DynadotDomainInfo domainName
end menu_SetDynadotFolder

on menu_SetOceanNameServers indexView
   put the selected_Line of indexView into domainName
   --
   dynadot_SetDigitalOceanNameServers domainName
   --
   display_DynadotDomainInfo domainName
end menu_SetOceanNameServers

on _
end _

on menu_DisplayDynadotInfo indexView
   put the selected_Line of indexView into domainName
   --
   display_DynadotDomainInfo domainName
end menu_DisplayDynadotInfo
