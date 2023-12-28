script "Global | Dynadot | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Dynadot | Dev | Menu
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

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget


--> Global | Dynadot | Dev | Menu
-
on menu_UpdateCachedDynadotData
   dynadot_UpdateCachedIndexDomainArray
   put the result into dynadotData
   --
   display_Data dynadotData, "Dynadot Data", "Cached"
end menu_UpdateCachedDynadotData

on menu_FetchDynadotData
   put dynadot_FetchIndexedDomainArray() into dynadotData
   --
   display_Data dynadotData, "Dynadot Data", "Fetched"
end menu_FetchDynadotData

on _
end _

on menu_UpdateOceanInfoArray
   digitalocean_UpdateDomainInfoArray
   put the result into oceanInfoArray
   display_Array oceanInfoArray, "Ocean Info Array,digitalocean_FetchDomainInfoArray()"
end menu_UpdateOceanInfoArray
