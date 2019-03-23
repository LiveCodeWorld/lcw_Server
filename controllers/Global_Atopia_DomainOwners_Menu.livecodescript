script "Global_Atopia_DomainOwners_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_DomainOwners_Menu
type: controller
version: 0.1


--> Global | Atopia | DomainOwners | Menu
-
on menu_DisplayDomainOwners
   display_FederationDomains
end menu_DisplayDomainOwners

on _
end _

on insert_Menu
   return "Global | Atopia | Tree | Menu"
end insert_Menu


--> Global | Atopia | DomainOwners | Menu | Props
-

--> Global | Atopia | DomainOwners | Menu | Disabled
-
