script "Global | Atopia | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Atopia | Line | Menu
type: controller
version: 0.1


--> Menu | Init
-
local LocalArray

getprop menu_Target [tObject]
   set the cursor to watch
   put the  display_View of tObject into displayView
   --
   put _GetWikiDomain (displayView) into subDomain
   put subDomain into LocalArray ["subDomain"]
   --
   put atopia_SiteIsIndexed (subDomain) into siteIsIndexed
   put siteIsIndexed into LocalArray ["siteIsIndexed"]
   --
   put atopia_IsInDomainArray (subDomain) into isInDomainArray
   put isInDomainArray into LocalArray ["isInDomainArray"]
   --
   put atopia_IsInRoster (subDomain) into isInRoster
   put isInRoster into LocalArray ["isInRoster"]
   --
   put fedray_IsIndexed (subDomain) into isInFederation
   put isInFederation into LocalArray ["isInFederation"]
   --
   put siteIsIndexed AND isInDomainArray AND isInRoster AND isInFederation into LocalArray ["isIndexed"]
   --
   _CheckAndColourDomain subDomain, displayView, true
   put the result into LocalArray ["DomainIsGood"]
   --
   return displayView
end menu_Target

private command _CheckAndColourDomain domainName, indexView, pDontAnswer
   put the line_Number [domainName] of indexView into lineNum
   --
   put atopia_WikiHasPages (domainName) into hasPages 
   if hasPages then
      put digitalocean_FetchDropletIP ("Atopia") into dropletIP
      --
      put dig_GetIP (domainName) into testIP
      put testIP = dropletIP into isHosted
      --
      if isHosted then
         set the line_Colour [lineNum] of indexView to green
         return true
      else
         set the line_Colour [lineNum] of indexView to blue
         if pDontAnswer is true then return false
         --
         put testIP & CR & dig_GetNS (domainName)
         lcw_AnswerWarning "Wiki is not hosted!", indexView
         return false
      end if
   else
      set the line_Colour [lineNum] of indexView to red
      if pDontAnswer is true then return false
      --
      lcw_AnswerWarning "Wiki has no pages", indexView
      return false
   end if
end _CheckAndColourDomain

getprop isIndexed_Param [indexView]
   put LocalArray ["isIndexed"] into isIndexed
   return isIndexed
end isIndexed_Param

getprop isIndexed_Params
   return "true,false"
end isIndexed_Params

getprop isInFederation_Param [indexView]
   put LocalArray ["isInFederation"] into isInRoster
   return isInRoster
end isInFederation_Param

getprop isInFederation_Params
   return "true,false"
end isInFederation_Params

getprop isInSites_Param [indexView]
   put LocalArray ["siteIsIndexed"] into siteIsIndexed
   return siteIsIndexed
end isInSites_Param

getprop isInSites_Params
   return "true,false"
end isInSites_Params

getprop isInDomainArray_Param [indexView]
   put LocalArray ["isInDomainArray"] into isInDomainArray
   return isInDomainArray
end isInDomainArray_Param

getprop isInDomainArray_Params
   return "true,false"
end isInDomainArray_Params

getprop isInRoster_Param [indexView]
   put LocalArray ["isInRoster"] into isInRoster
   return isInRoster
end isInRoster_Param

getprop isInRoster_Params
   return "true,false"
end isInRoster_Params

getprop disabled_SiteIsIndexed [indexView]
   if LocalArray ["DomainIsGood"] is true then
      return false
   else
      return true
   end if
end disabled_SiteIsIndexed

getprop disabled_IsInDomainArray [indexView]
   if LocalArray ["DomainIsGood"] is true then
      return false
   else
      return true
   end if
end disabled_IsInDomainArray

getprop disabled_IsInRoster [indexView]
   if LocalArray ["DomainIsGood"] is true then
      return false
   else
      return true
   end if
end disabled_IsInRoster

getprop disabled_DisplayDomainFolders [indexView]
   put LocalArray ["subDomain"] into subDomain
   --
   set the itemdelimiter to "."
   if the number of items of subDomain = 2 then
      return false
   else
      return "delete"
   end if
end disabled_DisplayDomainFolders

getprop disabled_DisplaySubDomainFolders [indexView]
   put LocalArray ["subDomain"] into subDomain
   --
   set the itemdelimiter to "."
   if the number of items of subDomain = 2 then
      return "delete"
   else
      return false
   end if
end disabled_DisplaySubDomainFolders

private function _GetWikiDomain displayView
   put the top_Line of displayView into subDomain
   -- put the selected_Line of displayView into subDomain
   return subDomain
end _GetWikiDomain

private command _SetInfo displayView, @wikiDomain, @pSlug
   put _GetWikiDomain (displayView) into wikiDomain
   -- put the selected_Line of displayView into pageTitle
   -- put the top_Array of displayView into domainArray
   put the selected_Array of displayView into pageInfoArray
   put pageInfoArray ["slug"] into pSlug
end _SetInfo


--> Global | Atopia | Line | Menu
-
on menu_DisplayPages indexView
   put _GetWikiDomain (indexView) into subDomain
   --
   display_WikiDomain subDomain
end menu_DisplayPages

on menu_DisplayRecentPages indexView
   put _GetWikiDomain (indexView) into subDomain
   --
   display_RecentDomainWikiPages subDomain
end menu_DisplayRecentPages

on _
end _

on insert_Menu
   return "Global | Atopia | Build | Line | Menu"
end insert_Menu

on _
end _

on menu_RenameWiki indexView
   put _GetWikiDomain (indexView) into oldDomainName
   --
   put lcw_Ask ("Change the name of this wiki folder...", oldDomainName) into newDomainName
   if newDomainName is oldDomainName then
      lcw_AnswerWarning "Not renamed. Choose a new name?", indexView
   end if
   --
   set the displayed_Line of indexView to newDomainName
   _CheckAndColourDomain newDomainName, indexView
end menu_RenameWiki

on _
end _

on menu_DisplayDomainFolders indexView
   put _GetWikiDomain (indexView) into subDomain
   url_DeconstructTopDomain subDomain, topDomainName, subDomainBit
   --
   display_AtopiaDomainFolders topDomainName
end menu_DisplayDomainFolders

on menu_DisplaySubDomainFolders indexView
   put _GetWikiDomain (indexView) into subDomain
   url_DeconstructTopDomain subDomain, topDomainName, subDomainBit
   --
   display_AtopiaSubDomainFolders topDomainName
end menu_DisplaySubDomainFolders

on _
end _

on subMenu_Dev
   return "Dev | Menu"
end subMenu_Dev


--> Dev | Menu
-
on menu_CheckDomain indexView
   set the cursor to watch
   put _GetWikiDomain (indexView) into subDomain
   --
   _CheckAndColourDomain subDomain, indexView
end menu_CheckDomain

on menu_TrashDomain displayView
   set the cursor to watch
   put _GetWikiDomain (displayView) into wikiDomain
   --
   if wikiDomain is empty then
      lcw_AnswerWarning "No domain selected!", displayView
   end if
   
   put atopia_CheckDomain (wikiDomain) into someError
   if someError is empty then
      lcw_AnswerWarning "Domain is not faulty!", displayView
   else
      atopia_TrashDomain wikiDomain
      --
      put the result into trashAction
      if trashAction is empty then
         lcw_AnswerWarning "Domain is good. Nothing changed", displayView
      else
         set the deleted_Line of displayView to wikiDomain
         put trashAction
      end if
   end if
end menu_TrashDomain
