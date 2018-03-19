script "Global_Ocean_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_Ocean_Line_Menu
type: controller
version: 0.1


--> Global | Ocean | Line | Menu
-
on menu_SetDynadotFolder indexView
   put the selected_Line of indexView into domainName
   put "Atopia" into folderName
   
   dynadot_SetFolder domainName, folderName
   put the result
   display_DynadotDomainInfo domainName
end menu_SetDynadotFolder

on menu_SetDynadotParking indexView, someBoolean
   put the selected_Line of indexView into domainName
   dynadot_SetParking domainName, someBoolean
   put the result
   display_DynadotDomainInfo domainName
end menu_SetDynadotParking

on menu_SetOceanNameServers indexView
   put the selected_Line of indexView into domainName
   put dns_HostNameServers ("Digital Ocean") into nameServers
   dynadot_SetNameServers domainName, nameServers
   put the result into someXML
   put someXML
   display_DynadotDomainInfo domainName
end menu_SetOceanNameServers

on _
end _

on menu_DisplayDynadotInfo indexView
   put the selected_Line of indexView into domainName
   display_DynadotDomainInfo domainName
end menu_DisplayDynadotInfo


--> Global | Ocean | Line | Menu | Props
-
getprop set_DynadotParking [indexView]
   put the selected_Line of indexView into domainName
   put dynadot_GetDomainInfoArray (domainName) into domainInfoArray
   put domainInfoArray ["NameServerSettings"]["Type"] = "Dynadot Parking" into isParked
   return isParked
end set_DynadotParking


--> Global | Ocean | Line | Menu | Disabled
-
