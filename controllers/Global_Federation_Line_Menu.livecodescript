script "Global_Federation_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_Federation_Line_Menu
type: controller
version: 0.1


--> Global | Federation | Line | Menu
-
on menu_DisplayDomainArray indexView
   put the selected_Line of indexView into fedwikiDomain
   --
   put fedwiki_GetFederationDomainArray (fedwikiDomain, "atopia.array") into domainArray
   display_Array domainArray
end menu_DisplayDomainArray

on menu_SetDomainArray indexView
   put the selected_Line of indexView into fedwikiDomain
   fedwiki_SetFederationDomainArray fedwikiDomain, "atopia.array"
   --
   put fedwiki_GetFederationDomainArray (fedwikiDomain, "atopia.array") into domainArray
   display_Array domainArray
end menu_SetDomainArray


--> Global | Federation | Line | Menu | Props
-

--> Global | Federation | Line | Menu | Disabled
-
