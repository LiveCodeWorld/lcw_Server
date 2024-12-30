script "Global | Local | Subdomains | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Local | Subdomains | Menu
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


--> Global | Local | Subdomains | Menu
-
on menu_LocalDomains dView
   put wikiDomain_List() into allLocalomains
   set the displayed_Index ["All Local Domains"] of dView to allLocalomains
end menu_LocalDomains

private on _
end _

on menu_LocalTopFarmDomains dView
   ecoData_ConstructLoadAndStore
   put the result into ecoData
   --
   put wikiFarm_ListTopDomains() into topLocalDomains
   set the displayed_Index ["Top Farm Folders"] of dView to topLocalDomains
end menu_LocalTopFarmDomains

on menu_LocalFarmFolders dView
   ecoData_ConstructLoadAndStore
   put the result into ecoData
   --
   put wikiFarm_ListDomains() into localDomains
   set the displayed_Index ["Farm Folders"] of dView to localDomains
end menu_LocalFarmFolders

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Local | Subdomains | Menu")
end submenu_Dev
