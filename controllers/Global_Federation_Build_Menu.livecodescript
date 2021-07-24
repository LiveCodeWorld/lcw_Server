script "Global | Federation | Build | Menu"
--> MetaData
-
license: GPLv3
name: Global | Federation | Build | Menu
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

command federation_CreateAuthorAndServerModels fedray, pUpdateFedray
   -- careful this stores data to wiki
   put fedserver_BuildServerModel (fedray, pUpdateFedray) into serverModel -- fetch from json-plugin
   put fedray_ConstructAuthorData (fedray) into authorArray -- from fedray
   
   -- now store them online
   federation_StoreModel "Server", serverModel
   author_StoreModelArray authorArray
end federation_CreateAuthorAndServerModels


--> Global | Federation | Build | Menu
-
on menu_ListRecentFederationDomains indexView
   put federation_ListRecentDomains() into wikiDomains
   set the displayed_Index ["Recent Domains"] of indexView to wikiDomains
end menu_ListRecentFederationDomains

on menu_ListStoredFederationDomains indexView
   set the cursor to watch
   put fedray_FetchDomains() into federationDomains
   put the number of lines of federationDomains into domainNum
   put "Federation Domains (" & domainNum & ")" into someTitle
   set the displayed_Index [someTitle] of indexView to federationDomains
end menu_ListStoredFederationDomains

on _
end _

on menu_FetchAndCheckFederationDomains indexView
   put federation_ListDomains() into federationDomains
   set the displayed_Index ["Federation Domains"] of indexView to federationDomains
   --
   lcw_Answer "Create new Federation array from these domains? This is slow due to timeouts.", indexView
   --
   -- put fedray_Construct (federationDomains) into fedray
   local fedray
   set the socketTimeoutInterval to 100
   repeat for each line wikiDomain in federationDomains
      display_Spin wikiDomain, indexView
      put the result into lineNum
      --
      fedray_UpdateDomain fedray, wikiDomain
      --
      if the result is empty then
         set the deleted_Line of indexView to wikiDomain
      else
         set the line_Colour [lineNum] of indexView to green 
      end if
   end repeat
   set the socketTimeoutInterval to 10000
   --
   lcw_Answer "Store newly created Atopia Fedray?", indexView
   fedray_StoreModel fedray
end menu_FetchAndCheckFederationDomains

on menu_FixCreationDates indexView
   put federation_ListDomains() into federationDomains
   set the displayed_Index ["Federation Domains"] of indexView to federationDomains
   --
   lcw_Answer "Reset creation dates for all these sites? This is slow due to timeouts.", indexView
   --
   local fedray
   set the socketTimeoutInterval to 100
   repeat for each line wikiDomain in federationDomains
      display_Spin wikiDomain, indexView
      put the result into lineNum
      --
      put fedwiki_FetchSiteCreationDate (wikiDomain) into siteCreationDate
      fedray_StoreSiteCreationDate wikiDomain, siteCreationDate
   end repeat
   set the socketTimeoutInterval to 10000
   --
   lcw_Answer "Store newly created Atopia Fedray?", indexView
   fedray_StoreModel fedray
end menu_FixCreationDates

on menu_FixWww displayView
   put fedray_FetchModel() into fedray
   put keys (fedray) into fedrayDomains
   sort fedrayDomains
   filter fedrayDomains with "www."
   --
   if fedrayDomains is empty then
      lcw_AnswerWarning "There are no domains beginning with www to fix!", displayView
   end if
   set the displayed_Index ["Federation Domains"] of displayView to fedrayDomains
   --
   set the itemdelimiter to "."
   repeat for each line wikiDomain in fedrayDomains
      display_Spin wikiDomain, displayView
      put the result into lineNum
      --
      if item 1 of wikiDomain = "www" then
         delete variable fedray [wikiDomain]
      end if
   end repeat
   --
   lcw_Answer "Store newly fixed Fedray?", displayView
   fedray_StoreModel fedray
   set the displayed_Array ["Federation Model"] of displayView to fedray
end menu_FixWww

on menu_FixDeadDomains displayView
   put fedray_FetchModel() into fedray
   put keys (fedray) into fedrayDomains
   sort fedrayDomains
   --
   set the displayed_Index ["Federation Domains"] of displayView to fedrayDomains
   --
   lcw_Answer "Fix dead domains for all these sites? This is slow due to timeouts.", displayView
   --
   repeat for each line wikiDomain in fedrayDomains
      display_Spin wikiDomain, displayView
      put the result into lineNum
      --
      put fedray [wikiDomain] into domainArray
      put domainArray ["pages"] into pageNum
      if pageNum is empty then
         set the line_Colour [lineNum] of displayView to red 
         delete variable fedray [wikiDomain]
         put domainArray into deadData [wikiDomain]
      else
         set the line_Colour [lineNum] of displayView to green 
      end if
   end repeat
   --
   set the displayed_Array ["Federation Model"] of displayView to fedray
   set the line_Menu of displayView to "Global | Federation | Line | Menu"
   fedray_StoreModel deadData, "Dead"
   --
   lcw_Answer "Store newly created Federation Model?", displayView
   fedray_StoreModel fedray
end menu_FixDeadDomains

on _
end _

on menu_DisplayAuthorModelFromFedray displayView
   put author_ConstructFromFedray() into authorArray
   --
   display_Data authorArray, "Author Array", "Fedray"
end menu_DisplayAuthorModelFromFedray
   
on menu_CreateAuthorModelFromFedray arrayView
   author_CreateModelFromFedray
   put the result into authorArray
   --
   set the line_Menu of arrayView to "Global | Federation | Author | Line | Menu"
   set the displayed_Array ["Federation Author Model"] of arrayView to authorArray
end menu_CreateAuthorModelFromFedray

on menu_CreateFederationAuthorAndServerModels displayView
   -- put display_FindView ("Federation") into displayView
   lcw_Answer "Fetch fedray and construct server and author data - storing these to wiki", displayView
   --
   put fedray_FetchModel() into fedray -- from json-plugin
   if fedray is not an array then
      lcw_AnswerWarning "Fetching the federation array from wiki returned empty!", displayView
   end if
   --
   put false into pUpdateFedray -- set to true to update info using sitemaps
   federation_CreateAuthorAndServerModels fedray, pUpdateFedray
   --  
   display_FederationServers
end menu_CreateFederationAuthorAndServerModels

on _
end _

on menu_AtopiaFedrayUpdater
   put atopia_FetchDomainArray() into fedray
   display_FedrayUpdate fedray, "Atopia Fedray"
   put the result into indexView
end menu_AtopiaFedrayUpdater

on menu_WardsFedrayUpdater
   put fedray_FetchWards() into fedray
   display_FedrayUpdate fedray, "Federation Fedray"
end menu_WardsFedrayUpdater

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
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
         fedray_StoreModel fedray
         put fedray_FetchModel() into fetchedFedray
         display_Array fetchedFedray, "fedray_FetchModel()"
      default
         breakpoint
   end switch
end menu_StoreUpdatedFedray
