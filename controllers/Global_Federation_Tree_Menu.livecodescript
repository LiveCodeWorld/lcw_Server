script "Global | Federation | Tree | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Federation | Tree | Menu
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
getprop menu_Target [tObject]   
   put the display_View of tObject into displayView
   return displayView
end menu_Target


--> Global | Federation | Tree | Menu
-
on menu_DisplayLastModified displayView, dayNum
   put the displayed_Index of displayView into wikiDomains
   put fedwiki_CheckWithSitemapArray (wikiDomains, dayNum) into resultArray
   --
   put dayNum && "days" into dTitle
   display_Data resultArray, dTitle, "fedwiki_CheckWithSitemapArray"
end menu_DisplayLastModified

getprop displayLastModified_Params
   return "1,2,3,4,5,6,7"
end displayLastModified_Params

on menu_TrashAndUpdateFedray indexView
   display_UpdateWikiMetadata "1 day"
end menu_TrashAndUpdateFedray

on submenu_Display
   return "Global | Federation | Display | Menu"
end submenu_Display

on _
end _

on menu_AzureEntites
   put lcw_Ask ("Choose a domain to index..", "david.bovill.me") into wikiDomain
   display_AzureEntities wikiDomain
end menu_AzureEntites

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
