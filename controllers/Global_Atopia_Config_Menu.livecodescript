script "Global_Atopia_Config_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_Config_Menu
type: controller
version: 0.1


--> Menu | Init
-
getprop addAuthorDomain_Params
   put atopia_ListDefaultOwners() into defaultOwnerNames
   return defaultOwnerNames
end addAuthorDomain_Params


--> Global | Atopia | Config | Menu
-
on menu_AddWildCardDomain arrayView
   put the displayed_Array of arrayView into configArray
   --
   put lcw_Ask ("What domain do you want to add?", "mediagarden.org") into newDoman
   --
   put atopia_ConstructConfigDomainArray() into domainArray
   put domainArray into configArray ["wikiDomains"][newDoman]
   --
   set the displayed_Array of arrayView to configArray
end menu_AddWildCardDomain

on menu_AddAuthorDomain arrayView, authorName
   put the displayed_Array of arrayView into configArray
   --
   put lcw_Ask ("What domain do you want to add?", "mediagarden.org") into newDoman
   --
   put atopia_ConstructConfigDomainArray (authorName) into domainArray
   put domainArray into configArray ["wikiDomains"][newDoman]
   --
   set the displayed_Array of arrayView to configArray
end menu_AddAuthorDomain
   
on _
end _

on menu_StoreConfigJson arrayView
   put the displayed_Array of arrayView into configArray
   --
   lcw_Answer "Store new config.json to Atopia server?"
   --
   atopia_StoreConfigArray configArray
   --
   put the result into shellResult
   if the result is empty then
      lcw_Notify "Updated config.json"
   else
      put shellResult
      lcw_AnswerWarning "Failed to update config.json!", arrayView
   end if
end menu_StoreConfigJson

on menu_RestartAtopiaServer
   atopia_DoRemoteShell "stop wiki"
   lcw_Notify the result
   --
   atopia_DoRemoteShell "start wiki"
   lcw_Notify the result
end menu_RestartAtopiaServer

on _
end _

on submenu_Google
   return "Global | Google | Console | Title | Line | Menu"
end submenu_Google

on menu_Refresh arrayView
   atopia_FetchConfigArray arrayView
end menu_Refresh

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_TestDisplayedConfigJson arrayView
   put the displayed_Array of arrayView into configArray
   --
   put json_FromArray (configArray, true, true) into configJSON
   --
   put configJSON
end menu_TestDisplayedConfigJson
