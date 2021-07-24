script "Global | Server | Roster | Menu"
--> MetaData
-
license: GPLv3
name: Global | Server | Roster | Menu
type: controller
version: 0.2


--> Menu | Props
-
private function _GetWikiDomain displayView
   put the stack_Label of displayView into wikiDomain
   return wikiDomain
end _GetWikiDomain

getprop siteIsIndexed_Param [displayView]
   -- was "site_IsIndexed"
   put the stack_Label of displayView into wikiDomain
   return atopia_SiteIsIndexed (wikiDomain)
end siteIsIndexed_Param

getprop isInRoster_Param [displayView]
   -- was "is_InRoster"
   put the stack_Label of displayView into wikiDomain
   put atopia_IsInRoster (wikiDomain) into someBoolean
   return someBoolean
end isInRoster_Param

getprop isInDomainArray_Param [displayView]
   put the stack_Label of displayView into wikiDomain
   put atopia_IsInDomainArray (wikiDomain) into someBoolean
   return someBoolean
end isInDomainArray_Param

getprop isInRoster_Params
   return "true,false"
end isInRoster_Params

getprop siteIsIndexed_Params
   return "true,false"
end siteIsIndexed_Params

getprop isInDomainArray_Params
   return "true,false"
end isInDomainArray_Params

getprop addHomeForks_Param [displayView]
   put _GetWikiDomain (displayView) into wikiDomain
   --
   return forkDomains
end addHomeForks_Param

function fedwiki_FetchHomeForks wikiDomain
   put atopia_FetchHomePageArray (wikiDomain) into pageArray
   put pageArray_ExtractForkDomains (pageArray) into forkDomains
   return forkDomains
end fedwiki_FetchHomeForks

getprop addHomeForks_Params [displayView]
   put _GetWikiDomain (displayView) into wikiDomain
   --
   put atopia_ListHomeForkHows (wikiDomain) into forkParams
   return forkParams
end addHomeForks_Params


--> Global | Server | Roster | Menu
-
on menu_LaunchWiki displayView
   put _GetWikiDomain (displayView) into wikiDomain
   --
   fedwiki_Launch wikiDomain
end menu_LaunchWiki

on _
end _

on menu_AddHomeForks displayView, forkDomain
   put menu_GetChecked (the params) into someBoolean
   put _GetWikiDomain (displayView) into wikiDomain
   --
   if someBoolean is true then
      breakpoint
   else
      atopia_AddHomeForkHow wikiDomain, forkDomain
   end if
end menu_AddHomeForks

on menu_SetDefaultFederationHome displayView
   put _GetWikiDomain (displayView) into wikiDomain
   lcw_Answer "Set the default welcome-visitors page for all new sites to this sites welcome-visitors page?"
   --
   atopia_SetDefaultHome wikiDomain
end menu_SetDefaultFederationHome

on _
end _

on menu_IsInRoster displayView, someBoolean
   put _GetWikiDomain (displayView) into wikiDomain
   --
   breakpoint
   if someBoolean is true then
      atopia_AddToRoster wikiDomain
   else
      atopia_DeleteFromRoster wikiDomain
   end if
end menu_IsInRoster

on menu_IsInDomainArray displayView, someBoolean
   put _GetWikiDomain (displayView) into wikiDomain
   --
   put atopia_FetchFedray() into fedray
   if someBoolean is true then
      fedray_UpdateDomain fedray, wikiDomain, false
   else
      delete variable fedray [wikiDomain]
   end if
   atopia_StoreFedray fedray
end menu_IsInDomainArray

on menu_SiteIsIndexed displayView, someBoolean
   put _GetWikiDomain (displayView) into wikiDomain
   --
   if someBoolean is true then
      atopia_CreateFederationSitePage subDomain
   else
      atopia_DeleteFederationSitePage subDomain
   end if
   --
   display_LaunchAtopiaSitePage subDomain
end menu_SiteIsIndexed

on _
end _

on menu_DisplayDomainFolders displayView
   put _GetWikiDomain (displayView) into wikiDomain
   --
   display_AtopiaDomainFolders wikiDomain
end menu_DisplayDomainFolders

on menu_DisplaySubdomainFolders displayView
   put _GetWikiDomain (displayView) into wikiDomain
   --
   display_AtopiaSubDomainFolders wikiDomain
end menu_DisplaySubdomainFolders

on _
end _

on menu_DisplayDomainRoster displayView
   put _GetWikiDomain (displayView) into wikiDomain
   --
   display_AtopiaDomainIndexRoster wikiDomain
end menu_DisplayDomainRoster

on _
end _

on menu_DisplayARecords displayView
   put _GetWikiDomain (displayView) into wikiDomain
   --
   put digitalocean_FetchArecordNames (wikiDomain) into aRecordNames
   --
   set the displayed_Index of displayView to aRecordNames
   set the title_Text of displayView to "A Records"
end menu_DisplayARecords

on menu_AddARecord displayView
   put _GetWikiDomain (displayView) into wikiDomain
   --
   put lcw_Ask ("What subdomain would you like to create?", "aName") into aName
   --
   put digitalOcean_FindDropletIP ("fedwiki.org") into someIP
   digitalocean_CreateARecord wikiDomain, aName, someIP
   --
   menu_DisplayARecords displayView
end menu_AddARecord

on _
end _

on menu_MakeFarm displayView  
   put _GetWikiDomain (displayView) into wikiDomain
   --
   put digitalocean_FetchArecordNames (wikiDomain) into aRecordNames
   set the wholematches to true
   if "*" is among the lines of aRecordNames then
      lcw_AnswerWarning "This domain is already a farm!", displayView
   end if
   --
   atopia_CreateFarm wikiDomain
   --
   menu_DisplayARecords displayView
end menu_MakeFarm

on menu_BurnSubdomains displayView
   put _GetWikiDomain (displayView) into wikiDomain
   --
   menu_DisplaySubDomainFolders displayView
   lcw_Answer "Burn the following subdomains and remove wild card DNS?", displayView
   --
   atopia_BurnFarmDomains wikiDomain
   --
   menu_DisplayARecords displayView
end menu_BurnSubdomains

on _
end _

on menu_Refresh displayView
   put _GetWikiDomain (displayView) into wikiDomain
   --
   display_AtopiaDomainFolders wikiDomain
end menu_Refresh

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on submenu_Subdomain
   return "Global | Subdomain | Tools | Menu"
end submenu_Subdomain

on menu_DisplaySitesNotIndexed displayView
   put the displayed_Index of displayView into allDomains
   --
   put atopia_ListFederationSitePages() into wikiPages
   line_DeleteIndex allDomains, wikiPages
   --
   set the displayed_Index of displayView to allDomains
   set the title_Text of displayView to "Sites Not Indexed"
end menu_DisplaySitesNotIndexed

on menu_CheckDisplayedDomains displayView
   put _GetWikiDomain (displayView) into wikiDomain
   --
   display_AtopiaSubDomainFolders wikiDomain
   put the displayed_Index of displayView into subDomains
   --
   lcw_Answer "Check if displayed folders are bad. Move to trash, or unhosted...", displayView
   --
   put the title_Text of displayView into oTitle
   set the title_Text of displayView to "Checking sites..."
   -- 
   repeat for each line domainName in subDomains
      display_Spin domainName, displayView
      put the result into lineNum
      --
      if atopia_WikiHasPages (domainName) then
         if atopia_WikiIsHosted (domainName) then
            set the line_Colour [lineNum] of displayView to green
         else
            set the cursor to watch
            set the line_Colour [lineNum] of displayView to red
            atopia_MoveToUnhosted domainName
            put the result into atopiaArray
            set the deleted_Line of displayView to domainName
         end if
      else
         set the line_Colour [lineNum] of displayView to red
         set the cursor to watch
         atopia_MoveToTrash domainName
         put the result into atopiaArray
         --
         set the deleted_Line of displayView to domainName
      end if
   end repeat
   set the title_Text of displayView to oTitle
end menu_CheckDisplayedDomains

on menu_DomainRecordArray displayView
   put _GetWikiDomain (displayView) into wikiDomain
   --
   -- put digitalocean_FetchArecordArray (wikiDomain) into aRecordArray
   put digitalocean_FetchDomainRecordArray (wikiDomain) into domainRecordArray
   --
   display_Array domainRecordArray, wikiDomain
end menu_DomainRecordArray
