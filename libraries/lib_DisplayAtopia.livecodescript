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


--> Display | Atopai
-
function atopia_ListDomains listHow
   switch listHow
      case "Atopia Roster"
         put atopia_FetchRoster() into displayLines
         break
      case "Domain Array"
         put atopia_FetchFedrayDomains() into displayLines
         break
      case "Atopia Folders"
         put atopia_FetchFolders() into displayLines         
         break
      case "Top Atopia Domains"
         put atopia_FetchTopDomains() into displayLines
         break
      case "Stored Federation"
         put atopia_FetchFederationDomains() into displayLines
         break
      case "Domain Owners"
         put atopia_ListLocalDomainOwners() into displayLines
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
         put atopia_FetchNewFolders() into displayLines
   end switch
   url_SortDomainIndex displayLines, true
   return displayLines
end atopia_ListDomains

command atopia_SetDisplay indexView, domainNames, displayTitle
   -- used by a lot of menu-items in "Global | Atopia | Tree | Menu" and "Global | Atopia | Check | Menu"
   lock screen
   set the atopia_ColouredLines of indexView to domainNames
   set the title_Text of indexView to displayTitle
   unlock screen
end atopia_SetDisplay

private command _SetAtopiaMenus listHow, @mTitle, @mLineTitle
   put "Global | Atopia | Tree | Menu" into mTitle
   put "Global | Atopia | Line | Menu" into mLineTitle
   --
   switch listHow
      case "Domain Owners"
         put "Global | Atopia | DomainOwners | Menu" into mTitle
         put "Global | Atopia | DomainOwners | Line | Menu" into mLineTitle
         break
      case "Top Domains"
         put "Global | Atopia | Top | Menu" into mTitle
         break
      default
         -- already set
   end switch
end _SetAtopiaMenus


--> Display | Events
-
command mDoubleUp_Domain indexView, wikiDomain
   if the optionKey is "down" then breakpoint
   put the stack_Title of indexView into stackTitle
   switch
      case stackTitle = "Domain Owners,Atopia"
         display_AtopiaOwnerDomains wikiDomain
         break
      default
         display_AtopiaWikiPages wikiDomain
   end switch
end mDoubleUp_Domain

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


--> Working on
-

--> Display | Azure
-
command display_AzurePhrases wikiDomain
   local someText
   if wikiDomain is empty then return empty
   put wikiDomain & ",Azure Phrases" into someTitle
   --
   put fedwiki_FetchAzureKeyPhrases (wikiDomain) into resultArray
   display_Array resultArray, someTitle, "Global | Azure | Tree | Menu"
   --
   put the result into displayView
   return displayView
end display_AzurePhrases

command display_AzureEntities wikiDomain
   local someText
   if wikiDomain is empty then return empty
   --
   put azure_FetchAndConvertSitemap (wikiDomain, "combine") into docArray
   if docArray is empty then return empty
   --
   put azure_FetchRelated (docArray) into resultArray
   put azure_ExtractUniqueEntities (resultArray) into wikipediaTitles
   --
   put wikiDomain & ",Azure Entities" into someTitle
   display_Array resultArray, someTitle, "Global | Azure | Tree | Menu"
   put the result into displayView
   return displayView
end display_AzureEntities


--> Display | Federation
-
command display_FederationServers
   rig_SetOveride true
   put federation_FetchServerData() into serverData
   --
   put "Server Model,Federation" into stackTitle
   put display_FindView ("Federation", "Server Model") into arrayView
   if exists (arrayView) then -- let's refresh
      set the displayed_Data of arrayView to serverData
   else
      display_Array serverData, stackTitle, "Global | Federation | Menu", "Global | Federation | Server | Line | Menu"
      put the result into displayView
   end if
   return displayView
end display_FederationServers

command display_FederationDomains domainNames, pIndexView, pDisplayTitle, pMenuTitle, pMenuLineTitle
   local mUpCommand
   rig_SetOveride true
   put "mDoubleUp_Domain" into mDoubleUpCommand
   --
   if exists (pIndexView) then
      -- atopia_SetDisplay pIndexView, displayLines, pDisplayTitle
      -- set the title_Text of pIndexView to displayTitle
      put item 1 of pDisplayTitle into titleText
      set the view_Index [titleText] of pIndexView to domainNames
   else
      display_Index domainNames, pDisplayTitle, pMenuTitle, pMenuLineTitle, mUpCommand, mDoubleUpCommand
      put the result into pIndexView
      set the field_Align of pIndexView to "right"
      set the field_Style of pIndexView to "click"
      -- set the event_Target of pIndexView to script_CallingObject()
   end if
   set the title_Menu of pIndexView to pMenuTitle
   set the line_Menu of pIndexView to pMenuLineTitle
   --
   return pIndexView
end display_FederationDomains


--> Display | Atopia
-
command display_AtopiaDomains pDisplayTitle
   put "Atopia" into displayStackLabel
   if pDisplayTitle is empty then put "New Folders" into pDisplayTitle
   --
   put display_FindView (displayStackLabel) into indexView
   if exists (indexView) and pDisplayTitle is empty then -- let's refresh
      put the title_Text of indexView into pDisplayTitle
   end if
   --
   _SetAtopiaMenus pDisplayTitle, mTitle, mLineTitle
   put atopia_ListDomains (pDisplayTitle) into domainNames
   --
   put "," & displayStackLabel after pDisplayTitle
   display_FederationDomains domainNames, indexView, pDisplayTitle, mTitle, mLineTitle
   --
   return indexView
end display_AtopiaDomains


--> Display | Atopia | Bits
-
command display_AtopiaWikiPages wikiDomain
   rig_SetOveride true
   set the cursor to watch
   put atopia_FetchWikiPageList (wikiDomain) into wikiPages
   --
   put wikiDomain & comma & "Wiki Pages" into displayTitle
   display_Lines wikiPages, displayTitle, "mDoubleUp_AtopiaWikiFiles"
   put the result into displayView
   --
   set the title_Menu of displayView to "Global | Atopia | Tree | Menu"
   set the line_Menu of displayView to "Global | Atopia | Line | Menu"
   --
   return displayView
end display_AtopiaWikiPages

command display_LocalFedray
   local pMouseUpCommand
   put fedray_GetArray ("atopia.array") into atopiaArray
   put atopiaArray ["domain"] into domainArray
   put keys (domainArray) into domainNames
   url_SortDomainIndex domainNames
   display_Index domainNames, "Local Atopia Domains,Fedray", "Global | Atopia | Top | Menu", "Global | Atopia | Top | Line | Menu"
   put the result into displayView
   return displayView
end display_LocalFedray

command display_AtopiaOwners
   display_AtopiaDomains "Domain Owners"
   return the result
end display_AtopiaOwners


--> Display | Atopia | Config
-
command display_AtopiaConfigArray
   put atopia_GetConfigArray() into configArray
   display_Array configArray, "Atopia config.json", "Global | Atopia | Config | Menu",  "Global | Atopia | Config | Line | Menu"
   return the result
end display_AtopiaConfigArray

command display_AtopiaOwnerDomains userEmail, pIndexView
   put atopia_GetDomainsFromEmail (userEmail) into domainNames
   url_SortDomainIndex domainNames
   --
   put "" into mUpCommand
   put userEmail & ",Owned Domains" into displayTitle
   --
   display_FederationDomains domainNames, displayTitle, mUpCommand, pIndexView
   put the result into indexView
   return indexView
end display_AtopiaOwnerDomains

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
   -- this will set a domain list of an index_View
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
