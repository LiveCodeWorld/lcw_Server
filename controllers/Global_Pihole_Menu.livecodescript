script "Global | Pihole | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Pihole | Menu
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
   put the display_View of tObject into LocalArray ["dView"]
   put the displayed_Object of tObject into sObject
   return sObject
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Pihole | Menu
-
on menu_ListPiDomains dView, piName
   display_PiDomains piName
end menu_ListPiDomains

getprop listPiDomains_Params
   return pihole_ListNames()
end listPiDomains_Params

private on _
end _

on menu_AddTopLevelDomain dView, piName
   put lcw_Ask ("What top-level domain would you like to add?", "livecode.wiki", dView) into domainName
   --
   pihole_AddDomaintoNamedPi domainName, piName
end menu_AddTopLevelDomain

getprop addTopLevelDomain_Params
   return pihole_ListNames()
end addTopLevelDomain_Params

private on __
end __

on menu_DisplayPiholeAdmin
   display_PiholeAdmin
end menu_DisplayPiholeAdmin

on menu_DisplayPiholeLocalData
   put pihole_LocalData() into piLocalData
   array_MakeExpandable piLocalData
   display_Data piLocalData, "pihole_LocalData()", "Pihole"
end menu_DisplayPiholeLocalData

on menu_Refresh dView
   display_PiholeTools dView
end menu_Refresh

on submenu_Dev
   return menu_DevTitle ("Global | Pihole | Menu")
end submenu_Dev
