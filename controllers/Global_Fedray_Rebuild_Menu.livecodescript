script "Global | Fedray | Rebuild | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Fedray | Rebuild | Menu
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
   put federation_ListModels() into LocalArray ["modelTitles"]
   return displayView
end menu_Target

getprop launchModel_Params
   return LocalArray ["modelTitles"]
end launchModel_Params

getprop displayModelData_Params
   return LocalArray ["modelTitles"]
end displayModelData_Params


--> Global | Fedray | Rebuild | Menu
-
on menu_TestCreated displayView
   get the displayed_Data of displayView
   put it ["created"] into newFedrayDomainArray
   put the keys of newFedrayDomainArray into newFedrayDomains
   url_SortDomainIndex newFedrayDomains
   display_Data newFedrayDomains, "New Domains", "Fedray"
   --
   put fedray_FetchDomains() into fedrayDomains
   if fedrayDomains = newFedrayDomains is false then
      display_Data fedrayDomains, "Stored Domains", "Fedray"
   end if
end menu_TestCreated

on _
end _

on menu_AddToDeadFedray displayView
   put federation_FetchModel ("Dead Model") into deadModel
   --
   get the displayed_Data of displayView
   --
   put "no ip,no sitemapArray" into someKeys
   repeat for each item someKey in someKeys
      put it [someKey] into someArray
      repeat for each key someDomain in someArray
         set the cursor to busy
         put someKey into deadModel [someDomain]
      end repeat
   end repeat
   --
   display_Data deadModel, "New", "Dead Model"
   put the result into displayView
   lcw_Answer "Upload new dead model to server", displayView
   --
   federation_StoreModel "Dead Model", deadModel
end menu_AddToDeadFedray

on menu_CreateDeadModel displayView
   federation_CreateModelPage "Dead Model"
   --
   if item 1 of the result = "error" then
      lcw_Answer the result, displayView
   end if
   
   federation_Launch "Dead Model"
end menu_CreateDeadModel

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_EditMyCause
   menu_EditItem "Global | Atopia | Build | Menu", "menu_BuildWardsWithoutAtopia"
end menu_EditMyCause

on menu_DisplayModelData displayView, modelTitle
   put federation_FetchModel (modelTitle) into modelData
   display_Data modelData, modelTitle, "Model"
end menu_DisplayModelData

on menu_LaunchModel displayView, modelTitle
   federation_Launch modelTitle
end menu_LaunchModel



--> Deps
-
