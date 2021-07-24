script "Global | Author | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Author | Line | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   -- called first
   put the display_View of tObject into displayView
   put the dispayed_Data of displayView into LocalArray ["dataArray"]
   --
   return displayView
end menu_Target


--> Global | Author | Line | Menu
-
on menu_LaunchDomain displayView
   put _GetSelectedDomain (displayView) into wikiDomain
   -- 
   fedwiki_Launch wikiDomain
end menu_LaunchDomain

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment displayView
   put displayView
end menu_Experiment


--> Deps
-
