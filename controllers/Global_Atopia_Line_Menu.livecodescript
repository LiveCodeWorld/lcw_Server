script "Global_Atopia_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_Line_Menu
type: controller
version: 0.1


--> Global | Atopia | Line | Menu
-
on submenu_Google
   return "Global | Google | Console | Title | Line | Menu"
end submenu_Google

on _
end _

on menu_SetFarm indexView
   put the selected_Line of indexView into domainName
   --
   put atopia_FetchNameServerType (domainName) into nsType
   put atopia_FetchFarmStatus (nsType)
end menu_SetFarm

on menu_GetConfigInfo indexView
   put the selected_Line of indexView into domainName
   --
   put atopia_GetDomainConfigArray (domainName) into domainConfigArray
   put atopia_GetDomainOwnerIdPath (domainName)
   --
   display_Array domainConfigArray
end menu_GetConfigInfo

on menu_DisplayDomainInfo indexView
   put the selected_Line of indexView into domainName
   put dig_GetNS (domainName) into nameServers
   switch
      case line 1 of nameServers ends with ".digitalocean.com."
         put digitalocean_GetDomainArray (domainName) into domainArray
         break
      case line 1 of nameServers ends with ".dynadot.com." 
         break
      default
         put nameServers
         breakpoint
   end switch
   --
   display_Array domainArray
end menu_DisplayDomainInfo

on menu_LaunchDomain indexView
   put the selected_Line of indexView into wikiDomain
   put "http://" & wikiDomain into someURL
   --
   launch url someURL
end menu_LaunchDomain

on menu_DisplayWikiPages indexView
   put the selected_Line of indexView into wikiDomain
   display_AtopiaWikiPages wikiDomain
end menu_DisplayWikiPages

on _
end _

on menu_FindAuthor indexView
   put the selected_Line of indexView into wikiDomain
   --
   put atopia_FetchEmail (wikiDomain) into ownerEmail
   put ownerEmail
end menu_FindAuthor

on menu_AddToOwnership indexView
   put the selected_Line of indexView into wikiFolder
   atopia_AddDomainToOwnershipArray wikiFolder
end menu_AddToOwnership

on menu_DeleteFromOwnership indexView
   put the selected_Line of indexView into wikiFolder
   atopia_DeleteFromOwnershipArray wikiFolder
end menu_DeleteFromOwnership

getprop disabled_AddToOwnership
   return true
end disabled_AddToOwnership

getprop disabled_DeleteFromOwnership
   return true
end disabled_DeleteFromOwnership

on _
end _

on menu_CheckDomain indexView
   set the cursor to watch
   put the selected_Line of indexView into domainName
   put the line_Number [domainName] of indexView into lineNum
   --
   if atopia_WikiHasPages (domainName) then
      if atopia_WikiIsHosted (domainName) then
         set the line_Colour [lineNum] of indexView to green
      else
         set the line_Colour [lineNum] of indexView to blue
      end if
   else
      set the line_Colour [lineNum] of indexView to red
   end if
end menu_CheckDomain

on menu_MoveOrUpdateAtopiaArray indexView
   put the selected_Line of indexView into wikiDomain
   --
   atopia_UpdateArrayAndMove wikiDomain
   put the result into resultArray
   --
   display_AtopiaUpdateResult resultArray, indexView
end menu_MoveOrUpdateAtopiaArray

on menu_MoveToTrash indexView
   put the selected_Line of indexView into wikiDomain
   --  
   put "Move" && kwote (wikiDomain) && "to the _trash folder?" into someQuestion
   lcw_AnswerSheet someQuestion
   --
   set the cursor to watch
   --
   atopia_MoveToTrash wikiDomain
   put the result into atopiaArray
   --
   set the deleted_Line of indexView to wikiDomain
end menu_MoveToTrash

on menu_MoveToUnhosted indexView
   put the selected_Line of indexView into wikiDomain
   put "Move" && kwote (wikiDomain) && "to the _unhosted_sites folder?" into someQuestion
   lcw_AnswerSheet someQuestion
   --
   set the cursor to watch
   atopia_MoveToUnhosted wikiDomain
   put the result into atopiaArray
   
   set the deleted_Line of indexView to wikiDomain
end menu_MoveToUnhosted

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Atopia | Line | Menu | Props
-

--> Global | Atopia | Line | Menu | Disabled
-


--> Dev | Menu
-
on menu_Dig indexView
   put the selected_Line of indexView into wikiDomain
   --
   put dig_GetIP (wikiDomain) into someIP
   put dig_GetNS (wikiDomain) into nameServers
   -- put dig_GetDomain (someIP) into rAddress
   --
   put someIP & CR & nameServers
end menu_Dig

on menu_LsArray indexView
   -- general ls file info for the folder
   put the selected_Line of indexView into wikiDomain
   put atopia_FetchDomainLsArray (wikiDomain) into lsArray
   --
   put wikiDomain & ",LS Files" into displayTitle
   display_Array lsArray, displayTitle
end menu_LsArray

on menu_WikiPageFileArray indexView
   -- general ls file info for the folder
   put the selected_Line of indexView into wikiDomain
   put atopia_FetchWikiPageFileArray (wikiDomain) into fileArray
   --
   put wikiDomain & ",atopia_FetchWikiPageFileArray()" into displayTitle
   display_Array fileArray, displayTitle
end menu_WikiPageFileArray

on _
end _

on menu_FindOwnerArray indexView
   put the selected_Line of indexView into wikiDomain
   --
   put atopia_FetchAndFindOwnerArray (wikiDomain) into ownerArray
   display_AtopiaOwnerArray ownerArray, wikiDomain
end menu_FindOwnerArray

on menu_FetchPersonaArray indexView
   put the selected_Line of indexView into wikiDomain
   --
   put atopia_FetchPersonaEmail (wikiDomain) into personaEmail
   put atopia_ConstructPersonaOwnerArray (personaEmail) into ownerArray
   --
   display_AtopiaOwnerArray ownerArray, wikiDomain
   put personaEmail
end menu_FetchPersonaArray


--> Private
-
private command _SetDisplayDomainNames indexView, domainNames, whichFolders
   lock screen
   set the label of the stack_Object of indexView to "atopia_FetchNewFolderList()"
   set the atopia_ColouredLines of indexView to domainNames
   set the title_Text of indexView to whichFolders
   unlock screen
end _SetDisplayDomainNames
