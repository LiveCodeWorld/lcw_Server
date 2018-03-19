script "Global_Atopia_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_Atopia_Line_Menu
type: controller
version: 0.1


--> Global | Atopia | Line | Menu
-
on menu_MoveOrUpdateAtopiaArray indexView
   put the selected_Line of indexView into wikiDomain
   --
   atopia_UpdateArrayAndMove wikiDomain
   put the result into resultArray
   --
   display_AtopiaUpdateResult resultArray, indexView
end menu_MoveOrUpdateAtopiaArray

on _
end _

on menu_MoveToTrash indexView
   put the selected_Line of indexView into wikiDomain
   --  
   put "Move" && kwote (wikiDomain) && "to the _trash folder?" into someQuestion
   lcw_AnswerSheet someQuestion
   --
   atopia_MoveToTrash wikiDomain
   put the result into domainErrorArray
   
   put atopia_ListLocalBadFolders() into domainNames
   _SetDisplayDomainNames indexView, domainNames, "Local Bad Folders"   
end menu_MoveToTrash

on menu_MoveToUnhosted indexView
   put the selected_Line of indexView into wikiDomain
   put "Move" && kwote (wikiDomain) && "to the _unhosted_sites folder?" into someQuestion
   lcw_AnswerSheet someQuestion
   --
   set the cursor to watch
   atopia_MoveToUnhosted wikiDomain
   put the result into domainErrorArray
   
   put atopia_ListLocalGoodFolders() into domainNames
   _SetDisplayDomainNames indexView, domainNames, "Local Good Folders"   
end menu_MoveToUnhosted

on _
end _

on menu_Dig indexView
   put the selected_Line of indexView into wikiDomain
   --
   put dig_GetIP (wikiDomain) into someIP
   put dig_GetNS (wikiDomain) into nameServers
   -- put dig_GetDomain (someIP) into rAddress
   --
   put someIP & CR & nameServers
end menu_Dig

on menu_FindAuthor indexView
   put the selected_Line of indexView into wikiDomain
   --
   put atopia_FetchConfigArray() into pConfigArray
   put atopia_FindEmail (wikiDomain, pConfigArray) into ownerEmail
   --
   put ownerEmail
   -- display_Array ownerArray
end menu_FindAuthor

on menu_FindOwnerArray indexView
   put the selected_Line of indexView into wikiDomain
   --
   put atopia_FindOwnerArray (wikiDomain) into ownerArray
   display_AtopiaOwnerArray ownerArray, wikiDomain
end menu_FindOwnerArray

on menu_FetchPersonaArray indexView
   put the selected_Line of indexView into wikiDomain
   --
   put atopia_FetchPersonaEmail (wikiDomain) into personaEmail
   put fedwiki_ConstructPersonaOwnerArray (personaEmail) into ownerArray
   --
   display_AtopiaOwnerArray ownerArray, wikiDomain
   put personaEmail
end menu_FetchPersonaArray

on _
end _

on menu_DisplayWikiPages indexView
   put the selected_Line of indexView into wikiDomain
   display_AtopiaWikiPages wikiDomain
end menu_DisplayWikiPages

on _
end _

on menu_LsArray indexView
   -- general ls file info for the folder
   put the selected_Line of indexView into wikiDomain
   put atopia_FetchDomainLsArray (wikiDomain) into lsArray
   display_Array lsArray
end menu_LsArray

on menu_WikiPageFileArray indexView
   -- general ls file infor for the folder
   put the selected_Line of indexView into wikiDomain
   put atopia_FetchWikiPageFileArray  (wikiDomain) into fileArray
   display_Array fileArray
end menu_WikiPageFileArray


--> Global | Atopia | Line | Menu | Props
-

--> Global | Atopia | Line | Menu | Disabled
-

--> Private
-
private command _SetDisplayDomainNames indexView, domainNames, whichFolders
   lock screen
   set the label of the stack_Object of indexView to "atopia_FetchNewFolderList()"
   set the atopia_ColouredLines of indexView to domainNames
   set the title_Text of indexView to whichFolders
   unlock screen
end _SetDisplayDomainNames
