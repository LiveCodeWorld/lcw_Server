script "lib_DisplayAtopia"
--> MetaData
-
license: GPLv3
name: lib_DisplayAtopia
type: library
version: 0.3


--> Working on
-
function federation_FetchLastReportDate
   put fedwiki_FetchSitemap ("history.fedwiki.org") into sitemapArray
   display_Data sitemapArray, "history.fedwiki.org"
end federation_FetchLastReportDate

function atopia_CheckDomain domainName
   -- see "atopia_CheckGoodFolders"
   put atopia_IsHosted (domainName) into isHosted
   if isHosted is false then return "Wiki is not hosted!"
   
   put atopia_WikiHasPages (domainName) into hasPages 
   if hasPages then
      return empty
   else
      return "Wiki has no pages"
   end if
end atopia_CheckDomain

function atopia_IsHosted domainName
   put digitalocean_FetchDropletIP ("Atopia") into dropletIP
   put dig_GetIP (domainName) into testIP
   return testIP = dropletIP
end atopia_IsHosted

function fedray_IsAtopia wikiDomain, pFedray, pAtopiaIP
   if pAtopiaIP is empty then
      put digitalocean_FetchDropletIP ("Atopia") into pAtopiaIP
   end if
   if pFedray is an array then
      put pFedray [wikiDomain]["ipAddress"] into testIP
   else
      put dig_GetIP (wikiDomain) into testIP
   end if
   return testIP = pAtopiaIP
end fedray_IsAtopia


--> Display | Federation
-
command display_FederationDomains pDomainFilter
   put fedray_FetchDomains() into wikiDomains
   --
   if pDomainFilter is empty then
      put "All Known Domains" into displayTitle
   else
      -- set the itemdelimiter to "."
      -- put word 1 of pDomainFilter && "Domains" into displayTitle
      put pDomainFilter into displayTitle
      filter wikiDomains with ("*." & pDomainFilter)
   end if
   url_SortDomainIndex wikiDomains
   
   put "mDoubleUp_Domain" into mDoubleClick
   put "Global | Server | Roster | Menu" into mTitle
   put "Global | Atopia | Line | Menu" into mLineTitle
   --
   _DisplayAtopiaDomain "Fedray Domains", wikiDomains, displayTitle, mTitle, mLineTitle, mDoubleClick
   return the result
end display_FederationDomains

command display_AtopiaDomainFolders wikiDomain
   set the cursor to watch
   --
   put atopia_FetchFolders (wikiDomain) into atopiaDomains
   --
   put "mDoubleUp_Domain" into mDoubleClick
   put "Global | Server | Roster | Menu" into mTitle
   put "Global | Atopia | Line | Menu" into mLineTitle
   --
   _DisplayAtopiaDomain wikiDomain, atopiaDomains, "Domain Folders", mTitle, mLineTitle, mDoubleClick
   return the result
end display_AtopiaDomainFolders


--> Display | Atopia | Index
-
command display_Atopia aTitle, domainNames, pTitleMenu, pLineMenu, pDoubleUp, pDisplayView
   _DisplayAtopia domainNames, aTitle, pTitleMenu, pLineMenu, pDoubleUp, pDisplayView
   put the result into indexView
   --
   return indexView
end display_Atopia

private command _DisplayAtopia domainNames, aTitle, pTitleMenu, pLineMenu, pDoubleUp, pDisplayView
   if pTitleMenu is empty then put "Global | Atopia | Menu" into pTitleMenu
   if pLineMenu is empty then put "Global | Atopia | Line | Menu" into pLineMenu
   if pDoubleUp is empty then put "mDoubleUp_Domain" into pDoubleUp
   --
   display_Data domainNames, aTitle, "Atopia", pDisplayView
   put the result into indexView
   display_SetIndexMenus indexView, pTitleMenu, pLineMenu, pDoubleUp
   --
   return indexView
end _DisplayAtopia

private command _DisplayAtopiaDomain wikiDomain, atopiaDomains, indexTitle, mTitle, mLineTitle, mDoubleClick
   put display_FindView (wikiDomain) into indexView
   --
   if pAddTopDomain is true then
      put wikiDomain & CR before atopiaDomains
      put char 1 to -1 of atopiaDomains into atopiaDomains
   end if
   --
   if exists (indexView) is false then
      display_Lines atopiaDomains, indexTitle, mDoubleClick, wikiDomain
      put the result into indexView
   else
      set the displayed_Index [indexTitle] of indexView to atopiaDomains
   end if
   set the title_Menu of indexView to mTitle
   set the line_Menu of indexView to mLineTitle
   return indexView
end _DisplayAtopiaDomain


--> Display | Events
-
command mDoubleUp_Domain indexView, wikiDomain
   display_AtopiaDomainFolders wikiDomain
   --
   launch url ("http://" & wikiDomain)
end mDoubleUp_Domain

command mDoubleUp_ConfigArray arrayView, wikiDomain
   put arrayView
end mDoubleUp_ConfigArray

command mDoubleUp_Authors displayView, clickedValue
   put the selected_Path of displayView into somePath
   if somePath is empty then
      breakpoint
      return false
   end if
   
   put item 1 of somePath into authorName
   put item 3 of somePath into wikiDomain
   --
   launch url ("http://" & wikiDomain)
end mDoubleUp_Authors

command mDoubleUp_ListOwnerDomains indexView, wikiDomain
   -- not used
   display_AtopiaOwnerDomains wikiDomain
end mDoubleUp_ListOwnerDomains

command mDoubleUp_ListWikiPages indexView, wikiDomain
   -- not used
   display_AtopiaWikiPages wikiDomain
end mDoubleUp_ListWikiPages

on mDoubleUp_AtopiaWikiFiles indexView, pageSlug
   if the optionKey is "down" then breakpoint
   --
   put the title_Text of indexView into wikiDomain
   --
   put fedwiki_PageUrl (wikiDomain, pageSlug) into pageURL
   launch url pageURL
end mDoubleUp_AtopiaWikiFiles


--> Display | Atopia | Config
-
command display_AtopiaConfigJson pConfigArray
   -- allow editing of config.json file on Atopia Server
   local mInspect, mDoubleClick
   
   if pConfigArray is empty then
      put atopia_FetchConfigArray() into pConfigArray
   end if
   --
   put "config.json" into aTitle
   --
   put "Global | Atopia | Config | Menu" into titleMenu
   put "Global | Atopia | Config | Line | Menu" into lineMenu
   put "mDoubleUp_ConfigArray" into mDoubleUp
   --
   display_Atopia aTitle, pConfigArray, titleMenu, lineMenu, mDoubleUp
   --
   return the result
   
   --
   put display_FindView ("Domain Info", domainName) into displayView
   if exists (displayView) is true then
      set the displayed_Array of displayView to domainInfoArray
   else
      display_Array configArray, "config.json", "Atopia Config"
      put the result into dispplayVieew
      display_SetInteractions displayView, "Atopia | Config", "mDoubleUp_ConfigArray"
   end if
   --
   put the stack_Name of displayView into stackName
   go to stack stackName
   --
   return displayView
end display_AtopiaConfigJson

command display_AtopiaNewFolders
   put "Showing new domain folders not in atopia fedray!" into someInfo
   --
   -- put atopia_ListNewRosterFolders() into atopiaDomains
   put atopia_ListNewCatFolders () into atopiaDomains
   --
   put "Global | Atopia | Tree | Menu" into mTitle
   put "Global | Atopia | Line | Menu" into mLineTitle
   --
   display_Atopia "New Domains", atopiaDomains, mTitle, mLineTitle
   --
   lcw_AnswerWarning someInfo
   return the result
end display_AtopiaNewFolders


--> Display | Atopia
-
command display_AtopiaRoster rosterDomains, rosterName
   put rosterName && "Roster" into aTitle
   display_Atopia aTitle, rosterDomains
   put the result into indexView
   return indexView
end display_AtopiaRoster


--> Display | AtopiaDomain | Roster
-
/*
Display a roster from the atopia server.
*/

command display_AtopiaDomainIndexRoster wikiDomain
   set the cursor to watch
   --
   put atopia_FetchRosterDomains (wikiDomain) into rosterDomains
   --
   put "mDoubleUp_Domain" into mDoubleClick
   put "Global | Server | Roster | Menu" into mTitle
   put "Global | Atopia | Line | Menu" into mLineTitle
   --
   _DisplayAtopiaDomain wikiDomain, rosterDomains, "Domain Roster", mTitle, mLineTitle, mDoubleClick
   return the result
end display_AtopiaDomainIndexRoster

command display_AtopiaSubDomainFolders wikiDomain
   set the cursor to watch
   --
   put atopia_FetchSubDomainFolders (wikiDomain) into subDomains
   --
   put "mDoubleUp_Domain" into mDoubleClick
   put "Global | Server | Roster | Menu" into mTitle
   put "Global | Atopia | Line | Menu" into mLineTitle
   --
   _DisplayAtopiaDomain wikiDomain, subDomains, "Subdomain Folders", mTitle, mLineTitle, mDoubleClick
   return the result
end display_AtopiaSubDomainFolders


--> Display | Atopia
-
command display_AtopiaUpdater
   put "Atopia Updater" into titleText
   put "Atopia" into stackLabel
   
   put atopia_FetchRosterDomains() into atopiaDomains
   --
   put display_FindView (stackLabel, titleText) into indexView
   if exists (indexView) then
      set the displayed_Index of indexView to atopiaDomains
   else
      display_Lines atopiaDomains, titleText, "mDoubleUp_Test", stackLabel
      put the result into indexView
      set the title_Menu of indexView to "Global | Federation | Build | Menu"
   end if
   return indexView
end display_AtopiaUpdater


--> Display | Atopia
-
command display_AtopiaTopDomains
   put atopia_ListTopFolders() into atopiaDomains
   --
   put "Top Domains" into aTitle
   put "Global | Atopia | Top | Menu" into mTitle
   put "Global | Atopia | Line | Menu" into mLineTitle
   --
   display_Atopia aTitle, atopiaDomains, mTitle, mLineTitle
   --
   return the result
end display_AtopiaTopDomains

command display_AtopiaRoster
   put atopia_FetchRosterDomains() into atopiaDomains
   --
   put "Domain Index Roster" into aTitle
   put "Global | Atopia | Tree | Menu" into mTitle
   put "Global | Atopia | Line | Menu" into mLineTitle
   --
   display_Atopia aTitle, atopiaDomains, mTitle, mLineTitle
   --
   return the result
end display_AtopiaRoster

command display_AtopiaUpdate fedray, titleText
   put keys (fedray) into fedDomains
   url_SortDomainindex fedDomains
   --
   put display_FindView ("Federation", titleText) into indexView
   if exists (indexView) then
      set the displayed_Index of indexView to fedDomains
   else
      display_Lines fedDomains, titleText, "mDoubleUp_Test", "Federation"
      put the result into indexView
      set the title_Menu of indexView to "Global | Federation | Build | Menu"
   end if
   return indexView
end display_AtopiaUpdate


--> Display | Atopia | Bits
-
command display_AtopiaWikiPages wikiDomain
   rig_SetOveride sObject, true
   --
   set the cursor to watch
   put atopia_ListWikiPages (wikiDomain) into wikiPages
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

command display_AtopiaDomainErrorArray
   put atopia_GetData() into atopiaData
   --
   display_Array atopiaData, "Domain Error Array,atopia_GetData()"
end display_AtopiaDomainErrorArray

command display_StoredAtopiaArray
   put atopia_FetchDomainArray() into atopiaDomainArray
   --
   display_Array atopiaDomainArray, "Stored Atopia Domains"
   put the result into displayView
   display_SetInteractions displayView, "Server | Atopia | Tree", ""
   return the result
end display_StoredAtopiaArray

private function _ArrayToMarkdown markDownArray
   repeat for each key someTitle in markDownArray
      put "#" && someTitle & CR after mdText
      put markDownArray [someTitle] into mdBody
      put mdBody & CR & CR after mdText
   end repeat
   return word 1 to -1 of mdText
end _ArrayToMarkdown


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
   set the coloured_Array of the target to colourArray
   unlock screen
end atopia_ColouredLines
