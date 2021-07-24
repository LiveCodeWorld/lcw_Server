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


--> Menu | Init
-
on menu_Init tObject   
   -- do something when the menu first loads
end menu_Init


--> Global | Dynadot | Tree | Line | Menu
-
on menu_DisplayDomainInfo indexView
   put the selected_Line of indexView into domainName
   --
   display_DynadotDomainInfo domainName
end menu_DisplayDomainInfo

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment mTarget
   put mTarget
end menu_Experiment


--> Deps
-
