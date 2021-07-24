script "Global_Atopia_Config_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_Config_Line_Menu
type: controller
version: 0.1


--> Menu | Init
-
getprop setDomain_Params
   return "David,Carlos,-,wild card"
end setDomain_Params

getprop disabled_SetDomain [arrayView]
   put _ParentIsDomain (arrayView) into isDomain
   return isDomain is false
end disabled_SetDomain

getprop disabled_DeleteDomain [arrayView]
   put _ParentIsDomain (arrayView) into isDomain
   return isDomain is false
end disabled_DeleteDomain

private function _ParentIsDomain arrayView
   get the selected_Path of arrayView
   put item 1 of it = "wikiDomains" into isDomain
   return isDomain
end _ParentIsDomain

private function _GetOwnerName arrayView
   put _GetSelectDomainArray (arrayView) into domainArray
   put domainArray ["id"] into defaultOwnerJsonPath
   put atopia_FetchDefaultOwnerArray (defaultOwnerJsonPath) into ownerArray
   put ownerArray ["name"] into ownerName
   return ownerName
end _GetOwnerName


--> Global | Atopia | Config | Line | Menu
-
on menu_SetDomain arrayView, authorName
   put _GetSelectDomainArray (arrayView) into oldDomainArray
   --
   if authorName is "wild card" then
      put empty into authorName
   end if
   --
   put atopia_ConstructConfigDomainArray (authorName) into newDomainArray
   --
   if oldDomainArray = newDomainArray then
      lcw_AnswerWarning "Not changed!"
   else
      put the top_Line [2] of arrayView into domainName 
      put the displayed_Array of arrayView into configArray
      put newDomainArray into configArray ["wikiDomains"][domainName]
      set the displayed_Array of arrayView to configArray
   end if
end menu_SetDomain

on menu_DeleteDomain arrayView
   put the selected_Array of arrayView into domainArray
   --
   display_Array domainArray
end menu_DeleteDomain

on _
end _

on menu_StoreAuthorDefault arrayView
   put _GetSelectDomainArray (arrayView) into domainArray
   put domainArray ["id"] into defaultOwnerJsonPath
   --
   if defaultOwnerJsonPath is empty then
      -- no author set
      put the top_Line [2] of arrayView into domainName 
      put atopia_FetchOwnerArray (domainName) into ownerArray
      -- could add this to local pref array.
   else
      put atopia_FetchDefaultOwnerArray (defaultOwnerJsonPath) into ownerArray
      put ownerArray ["name"] into ownerName
      put keys (ownerArray) into authType -- "google"
      --
      put domainArray into ownerAuthArray
      put domainArray into ownerAuthArray ["ownerArray"]
      --
      put "Store default" && authType && "owner array for" && ownerName & "?" into someQuestion
      lcw_Answer someQuestion, pDisplayView
      --
      atopia_SetOwnerAuthArray ownerName, ownerAuthArray
      --
      menu_DisplayOwnerAuthArray arrayView
   end if
end menu_StoreAuthorDefault

on menu_DisplayOwnerAuthArray arrayView
   put _GetOwnerName (arrayView) into ownerName
   put atopia_GetOwnerAuthArray (ownerName) into ownerAuthArray
   --
   display_Data ownerAuthArray, " Owner Auth Array", "Atopia"
end menu_DisplayOwnerAuthArray

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Test arrayView
   put _GetSelectDomainArray (arrayView) into domainArray
   --
   display_Array domainArray
end menu_Test

private function _GetSelectDomainArray arrayView
   -- put the selected_Array of arrayView into domainArray
   --
   put the top_Line [2] of arrayView into domainName
   put the displayed_Array of arrayView into configArray
   --
   put configArray ["wikiDomains"][domainName] into domainArray
   --
   return domainArray
end _GetSelectDomainArray


