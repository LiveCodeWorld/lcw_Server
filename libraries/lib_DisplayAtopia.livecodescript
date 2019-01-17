script "lib_DisplayAtopia"
--> MetaData
-
license: GPLv3
name: lib_DisplayAtopia
type: library
version: 0.1


--> Working on
-
function array_ToMarkdown markDownArray
   repeat for each key someTitle in markDownArray
      put "#" && someTitle & CR after mdText
      put markDownArray [someTitle] into mdBody
      put mdBody & CR & CR after mdText
   end repeat
   return word 1 to -1 of mdText
end array_ToMarkdown


--> Display | Events
-
on mDoubleUp_AtopiaWikiFiles indexView, pageSlug
   if the optionKey is "down" then breakpoint
   --
   put the title_Text of indexView into wikiDomain
   --
   put fedwiki_PageUrl (wikiDomain, pageSlug) into pageURL
   launch url pageURL
   
   put atopia_FetchAndFindOwnerArray (wikiDomain) into ownerArray
   display_AtopiaOwnerArray ownerArray, wikiDomain
end mDoubleUp_AtopiaWikiFiles

command mDoubleUp_AtopiaFolder indexView, wikiDomain
   if the optionKey is "down" then breakpoint
   put the title_Text of indexView into titleText
   switch titleText
      case "Domain Owners"
         display_AtopiaOwnerDomains wikiDomain
         break
      default
         display_AtopiaWikiPages wikiDomain
   end switch
end mDoubleUp_AtopiaFolder


--> Atopia | Display
-
command atopia_DisplayConfigArray
   put atopia_GetConfigArray() into configArray
   display_Array configArray, "Atopia config.json", "Global | Atopia | Config | Menu",  "Global | Atopia | Config | Line | Menu"
   return the result
end atopia_DisplayConfigArray

command display_AtopiaOwnerDomains userEmail, pIndexView
   put atopia_GetDomainsFromEmail (userEmail) into domainNames
   url_SortDomainIndex domainNames
   --
   put "" into mUpCommand
   put userEmail & ",Owned Domains" into displayTitle
   --
   display_AtopiaDomains domainNames, displayTitle, mUpCommand, pIndexView
   put the result into indexView
   return indexView
end display_AtopiaOwnerDomains

command display_AtopiaDomains domainNames, displayTitle, mUpCommand, pIndexView
   put "mDoubleUp_AtopiaFolder" into mDoubleUpCommand
   put "Global | Atopia | Owner | Menu" into mTitle
   put "Global | Atopia | Owner | Line | Menu" into mLineTitle
   --
   if exists (pIndexView) then
      atopia_SetDisplay pIndexView, domainNames, displayTitle
   else
      display_Index domainNames, displayTitle, mTitle, mLineTitle, mUpCommand, mDoubleUpCommand
      put the result into pIndexView
      set the field_Style of pIndexView to "click"
      set the event_Target of pIndexView to script_CallingObject()
   end if
   return pIndexView
end display_AtopiaDomains

command display_AtopiaOwners
   put "Global | Atopia | DomainOwners | Menu" into mTitle
   put "Global | Atopia | DomainOwners | Line | Menu" into mLineTitle
   --
   put "" into mUpCommand
   put "mDoubleUp_AtopiaFolder" into mDoubleUpCommand
   --
   put atopia_ListLocalDomainOwners() into displayLines
   --
   put "Domain Owners,Atopia" into displayTitle
   display_Index displayLines, displayTitle, mTitle, mLineTitle, mUpCommand, mDoubleUpCommand
   put the result into indexView
   set the field_Style of indexView to "click"
   set the event_Target of indexView to script_CallingObject()
   return indexView
end display_AtopiaOwners

command display_AtopiaFolders pDisplayTitle, pMouseUpCommand
   put "Atopia" into displayStackLabel
   put display_FindView (displayStackLabel) into indexView
   if exists (indexView) and pDisplayTitle is empty then
      -- let's refresh
      put the title_Text of indexView into pDisplayTitle
   end if
   
   put "Global | Atopia | Tree | Menu" into mTitle
   put "Global | Atopia | Line | Menu" into mLineTitle
   
   switch pDisplayTitle
      -- case "Wiki Page List"
      -- put atopia_FetchWikiPageList (wikiDomain) into wikiFolders
      -- break
      case "Top Domains"
         put "Global | Atopia | Top | Menu" into mTitle
         put atopia_FetchTopDomains() into displayLines
         -- put atopia_GetTopDomains() into displayLines
         break
      case "Domain Owners"
         -- put atopia_ListLocalDomainOwners() into displayLines
         display_AtopiaOwners
         return the result
         break
      case "Local Good Folders"
         put atopia_ListLocalGoodFolders() into displayLines         
         break
      case "Local Bad Folders"
         put atopia_ListLocalBadFolders() into displayLines
         break
      case "All Local Wiki Folders"
         put atopia_ListLocalWikiFolders() into displayLines
         break
      case "Remote Wiki Folders"
         put atopia_FetchAllFolderList() into displayLines         
         break
      case "Remote Unhosted Sites"
         put atopia_FetchRawFolderList ("_unhosted_sites") into displayLines
         break
      case "Remote Trash"
         put atopia_FetchRawFolderList ("_trash") into displayLines
         break
      case "Remote Old Sites"
         put atopia_FetchRawFolderList ("_old_sites") into displayLines
         break
      case "Reserved Folders"
         put atopia_FetchReservedFoldersList() into displayLines
         break
      default
         put "New Folders" into pDisplayTitle
         put atopia_FetchNewFolderList() into displayLines
   end switch
   url_SortDomainIndex displayLines, true
   
   if exists (indexView) then
      atopia_SetDisplay indexView, displayLines, pDisplayTitle
      --
      set the title_Menu of indexView to mTitle
      set the line_Menu of indexView to mLineTitle
   else
      put pDisplayTitle & comma & displayStackLabel into displayTitle
      display_Index displayLines, displayTitle, mTitle, mLineTitle, pMouseUpCommand, "mDoubleUp_AtopiaFolder"
      put the result into indexView
      set the field_Style of indexView to "click"
      set the event_Target of indexView to script_CallingObject()
   end if
   return indexView
end display_AtopiaFolders

command display_AtopiaUpdateResult resultArray, pIndexView
   display_Array resultArray
   --
   put array_ToMarkdown (resultArray) into mdText
   if exists (pIndexView) is false then
      put mdText
      return pIndexView
   end if
   --
   
   lock screen
   set the atopia_ColouredLines of pIndexView to mdText
   set the label of the stack_Object of pIndexView to "atopia_UpdateArrayAndMove"
   set the title_Text of pIndexView to "Update Result"
   unlock screen
   return mdText
end display_AtopiaUpdateResult

command display_AtopiaWikiPages wikiDomain
   set the cursor to watch
   put atopia_FetchWikiPageList (wikiDomain) into wikiPages
   
   put wikiDomain & comma & "atopia_FetchWikiPageList()" into displayTitle
   display_Lines wikiPages, displayTitle, "mDoubleUp_AtopiaWikiFiles"
   put the result into displayView
   --
   set the title_Menu of displayView to "Global | Atopia | Tree | Menu"
   set the line_Menu of displayView to "Global | Atopia | Line | Menu"
   --
   return displayView
end display_AtopiaWikiPages

command display_AtopiaDomainErrorArray
   put atopia_GetData() into atopiaData
   --
   display_Array atopiaData, "Domain Error Array,atopia_GetData()"
end display_AtopiaDomainErrorArray

command display_AtopiaOwnerArray ownerArray, wikiDomain
   display_Array ownerArray, (wikiDomain & ",atopia_FetchAndFindOwnerArray()")
   put atopia_GetOwnerEmail (ownerArray)
end display_AtopiaOwnerArray


--> Deps
-
setprop atopia_ColouredLines allFolderNames
   -- this will set a domain list fo an index_View
   -- and check and colour any domains red that are marked bad in the local atopiaData
   
   put atopia_GetData() into atopiaData
   url_SortDomainIndex allFolderNames, true
   --
   repeat with lineNum = 1 to the number of lines of allFolderNames
      put line lineNum of allFolderNames into folderName
      if atopia_DomainIsBadInDomainArray (folderName, atopiaData) is true then
         put empty into colourArray ["red"][lineNum]
         put lineNum & comma after badNums
      else
         put empty into colourArray ["none"][lineNum]
         put lineNum & comma after goodNums
      end if
   end repeat
   delete char -1 of goodNums
   delete char -1 of badNums
   --
   lock screen
   set the field_Align of the target to "right"
   set the view_Index of the target to allFolderNames
   set the line_Colours of the target to colourArray
   unlock screen
end atopia_ColouredLines

command atopia_SetDisplay indexView, domainNames, displayTitle
   lock screen
   set the atopia_ColouredLines of indexView to domainNames
   set the title_Text of indexView to displayTitle
   unlock screen
end atopia_SetDisplay

