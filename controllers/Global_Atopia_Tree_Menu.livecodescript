script "Global_Atopia_Tree_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_Tree_Menu
type: controller
version: 0.4


--> Global | Atopia | Tree | Menu
-
on submenu_Display
   return "Global | Atopia | Display | Menu"
end submenu_Display

on _
end _

on submenu_AtopiaBuild
   return "Global | Atopia | Build | Menu"
end submenu_AtopiaBuild

on submenu_FederationBuild
   return "Global | Federation | Build | Menu"
end submenu_FederationBuild

on _
end _

on menu_DevTools indexView
   lcw_Answer "These tools are not active. There are a lot of them collected here for review. I think there is a recursion problem as they are sloooow.", indexView
   
   local mDoubleUpCommand
   put atopia_FetchDomains() into someIndex
   display_Lines someIndex, "Dev Tools", mDoubleUpCommand, "Atopia"
   put the result into indexView
   set the title_Menu of indexView to "Global | Atopia | Tree | Dev | Menu"
end menu_DevTools

on menu_Refresh indexView
   display_AtopiaDomains
end menu_Refresh


--> Global | Atopia | Tree | Menu | Props
-
