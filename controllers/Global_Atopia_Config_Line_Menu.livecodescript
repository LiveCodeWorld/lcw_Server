script "Global_Atopia_Config_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_Config_Line_Menu
type: controller
version: 0.1


--> Global | Atopia | Config | Line | Menu
-
on menu_SetDomain mTarget
   get the selected_Array of mTarget
   display_Array it
end menu_SetDomain

on menu_DeleteDomain mTarget
end menu_DeleteDomain


--> Global | Atopia | Config | Line | Menu | Props
-

--> Global | Atopia | Config | Line | Menu | Disabled
-
getprop disabled_SetDomain [mTarget]
   put _ParentIsDomain (mTarget) into isDomain
   return isDomain is false
end disabled_SetDomain

getprop disabled_DeleteDomain [mTarget]
   put _ParentIsDomain (mTarget) into isDomain
   return isDomain is false
end disabled_DeleteDomain

function _ParentIsDomain mTarget
   get the selected_Path of mTarget
   put item 1 of it = "wikiDomains" into isDomain
   return isDomain
end _ParentIsDomain
