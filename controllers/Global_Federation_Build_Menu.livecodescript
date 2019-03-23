script "Global_Federation_Build_Menu"
--> MetaData
-
license: GPLv3
name: Global_Federation_Build_Menu
type: controller
version: 0.1


--> Menu | Init
-
local LocalArray

on menu_Init tObject, mTarget
   put display_FindView ("Federation") into newFolderView
   put exists (newFolderView) into newFolderViewExists
   put newFolderViewExists into LocalArray ["newFolderViewExists"]
   if newFolderViewExists then
      put the displayed_Index of newFolderView into newFolderIndex
      put newFolderIndex into LocalArray ["newFolderIndex"]
   else
      put empty into LocalArray ["newFolderIndex"]
   end if
end menu_Init

getprop disabled_StoreAtopiaFedray
   if LocalArray ["newFolderViewExists"] then
      return false
   else
      return true
   end if
end disabled_StoreAtopiaFedray


--> Global | Federation | Build | Menu
-
on menu_UpdateAgain indexView
   put the fedray_Data of indexView into fedray
   put the title_Text of indexView into titleText
   --
   display_FedrayUpdate fedray, titleText
end menu_UpdateAgain

on menu_Store indexView
   put the fedray_Data of indexView into fedray
   put the title_Text of indexView into titleText
   put word 1 of titleText into modelName
   --
   lcw_Answer merge ("Store '[[modelName]] Model'?"), indexView
   --
   fedray_Store fedray, modelName
end menu_Store

on menu_Fetch indexView
   put the fedray_Data of indexView into fedray
   put the title_Text of indexView into titleText
   put word 1 of titleText into modelName
   --
   put fedray_Fetch (modelName) into fedray
   display_Array fedray, titleText
end menu_Fetch

on _
end _

on menu_DisplayAtopiaUpdater
   put atopia_FetchFedray() into fedray
   display_FedrayUpdate fedray, "Atopia Fedray"
   put the result into indexView
end menu_DisplayAtopiaUpdater

on menu_UpdateWardsFedray
   put fedray_FetchWards() into fedray
   display_FedrayUpdate fedray, "Federation Fedray"
end menu_UpdateWardsFedray

on _
end _

on menu_StoreUpdatedFedray indexView
   -- put display_FindView ("Federation", "Wards Fedray") into indexView
   --
   put the fedray_Data of indexView into fedray
   if fedray is not an array then
      lcw_AnswerWarning "Array is empty!", indexView
      exit to top
   end if
   
   switch the title_Text of indexView
      case "Atopia Fedray"
         lcw_Answer "Do you want to save the updated Atopia fedray to wiki?", indexView
         --
         break
      case "Wards Fedray"
         lcw_Answer "Do you want to save the updated federation array to wiki?", indexView
         --
         fedray_Store fedray
         put fedray_Fetch() into fetchedFedray
         display_Array fetchedFedray, "fedray_Fetch()"
      default
         breakpoint
   end switch
end menu_StoreUpdatedFedray

on menu_CreateFedrayModels displayView
   -- put display_FindView ("Federation") into displayView
   lcw_Answer "Fetch fedray and construct server and author data - storing these to wiki", displayView
   --
   put fedray_Fetch() into fedray
   if fedray is not an array then
      lcw_AnswerWarning "Fetching the federation array from wiki returned empty!", displayView
   end if
   --
   put false into pUpdateFedray -- set to true to update info using sitemaps
   federation_CreateAuthorAndServerModels fedray, pUpdateFedray
   --  
   display_FederationServers
   display_Array federation_FetchAuthorData(), "federation_FetchAuthorData()"
end menu_CreateFedrayModels

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_DisplayArray indexView
   put the fedray_Data of indexView into fedray
   put the title_Text of indexView into titleText
   --
   display_Array fedray, titleText
end menu_DisplayArray


--> Global | Federation | Build | Menu | Props
-
