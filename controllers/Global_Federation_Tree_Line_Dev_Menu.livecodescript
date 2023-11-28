script "Global | Federation | Tree | Line | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Federation | Tree | Line | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Federation | Tree | Line | Dev | Menu
-
on menu_AzureDocArray displayView
   _SetInfo displayView, wikiDomain, pSlug
   --
   put pageArray_Fetch (wikiDomain, pSlug) into pageArray
   put azure_ConstructDocArray (pageArray) into docArray
   --
   display_Data docArray, pSlug, wikiDomain
end menu_AzureDocArray

on _
end _

on menu_DisplayAzureEntities displayView
   put _GetDomain (displayView) into wikiDomain
   --
   display_AzureEntities wikiDomain
end menu_DisplayAzureEntities

on menu_DisplayAzurePhrases displayView
   put _GetDomain (displayView) into wikiDomain
   --
   display_AzurePhrases wikiDomain
end menu_DisplayAzurePhrases

on _
end _

on menu_FixCreationDate displayView
   put _GetDomain (displayView) into wikiDomain
   --
   put fedwiki_FetchSiteCreationDate (wikiDomain) into siteCreationDate
   fedray_StoreSiteCreationDate wikiDomain, siteCreationDate
   --
   set the displayed_Data of displayView to fedray
end menu_FixCreationDate

on menu_ReindexDomain displayView
   put item 1 of the selected_Path of displayView into wikiDomain
   --
   put fedray_FetchModel() into fedray
   fedray_UpdateDomain fedray, wikiDomain, false
   --
   lcw_Answer "Store newly updated Federation Fedray?", displayView
   fedray_Store fedray
   --
   set the displayed_Array of displayView to fedray
end menu_ReindexDomain

