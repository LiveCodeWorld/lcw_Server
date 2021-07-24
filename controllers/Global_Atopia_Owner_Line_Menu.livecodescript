script "Global | Atopia | Owner | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Atopia | Owner | Line | Menu
type: controller
version: 0.1


--> Global | Atopia | Owner | Line | Menu
-
on menu_CheckOwnedDomain indexView
   put the selected_Line of indexView into wikiDomain
   --
   put atopia_FindFarmEmail (wikiDomain)
end menu_CheckOwnedDomain

on _
end _

on insert_Menu
   return "Global | Atopia | Line | Menu"
end insert_Menu


--> Global | Atopia | Owner | Line | Menu | Props
-

--> Global | Atopia | Owner | Line | Menu | Disabled
-
