script "Global | Subdomain | Tools | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | subDomain | Tools | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Working on
-
getprop menu_Target [tObject]
   set the cursor to watch
   put the display_View of tObject into displayView
   put displayView into LocalArray ["displayView"]
   --
   put word 1 of tObject into whichMenu
   put whichMenu into LocalArray ["whichMenu"]
   if whichMenu = "field" then
      put the selected_Line of displayView into LocalArray ["subDomain"]
   else
      put the stack_Label of displayView into LocalArray ["subDomain"]
   end if
   --
   put _GetSubDomain() into subDomain
   put atopia_WikiHasPages (subDomain) into hasPages
   --
   if hasPages then
      put digitalocean_FetchDropletIP ("Atopia") into dropletIP
      put dig_GetIP (subDomain) into testIP
      put testIP = dropletIP into isHosted
      --
      if isHosted then
         put true into LocalArray ["DomainIsGood"]
      else
         -- put testIP & CR & dig_GetNS (domainName)
         put "Wiki is not hosted!" into LocalArray ["DomainIsGood"]
      end if
   else
      put "Wiki has no pages!" into LocalArray ["DomainIsGood"]
   end if
   return subDomain
end menu_Target

private function _GetSubDomain
   return LocalArray ["subDomain"]
end _GetSubDomain

getprop disabled_BurnDomains [subDomain]
   put atopia_FetchFarmStatus (subDomain) into isFarm
   return isFarm
end disabled_BurnDomains

getprop disabled_AddHomeForkEvents [subDomain]
   if LocalArray ["DomainIsGood"] is true then
      return false
   else
      return true
   end if
end disabled_AddHomeForkEvents

getprop disabled_AddToOwnership
   return false
end disabled_AddToOwnership

getprop disabled_DeleteFromOwnership
   return true
end disabled_DeleteFromOwnership

getprop addHomeForkEvents_Param [subDomain]
   put atopia_FetchHomePageArray (subDomain) into pageArray
   put pageArray_ExtractForkDomains (pageArray) into forkDomains
   return forkDomains
end addHomeForkEvents_Param

getprop addHomeForkEvents_Params [subDomain]
   put url_ListTopDomains (subDomain) into subDomain
   --
   put atopia_FetchFolders (subDomain) into forkEvents
   replace CR with comma in forkEvents
   --
   put ",proto.institute,-,fedwiki.org,orientation.fedwiki.org" after forkEvents
   return forkEvents
end addHomeForkEvents_Params

getprop addAuthorDomain_Params
   put atopia_ListDefaultOwners() into defaultOwnerNames
   return defaultOwnerNames
end addAuthorDomain_Params

private command _AnswerQuestion someQuestion, pQVar, pQVar2, pQVar3
   put LocalArray["displayView"] into displayView
   lcw_Answer someQuestion, displayView, pQVar, pQVar2, pQVar3
end _AnswerQuestion


--> Global | Subdomain | Tools | Menu
-
on menu_AddARecord subDomain
   set the itemdelimiter to "."
   put item -2 to -1 of subDomain into subDomain
   put item 1 to -3 of subDomain into aName
   --
   put merge ("Burn the A record '[[aName]]' for the domain '[[subDomain]]'?") into someQuestion
   _AnswerQuestion someQuestion
   --
   put digitalOcean_FindDropletIP ("fedwiki.org") into someIP
   digitalocean_CreateARecord subDomain, aName, someIP
   put the result
end menu_AddARecord

on menu_BurnDomains subDomain
   atopia_BurnFarmDomains subDomain
   --
   put atopia_FetchOceanFarms() into atopiaFarms
   set the displayed_Index ["Atopia Ocean Farms"] of indexView to atopiaFarms
end menu_BurnDomains

on menu_AddHomeForkEvents subDomain, forkDomain
   put forkDomain is among the lines of the addHomeForkEvents_Param [indexView] of me into someBoolean
   put menu_GetChecked (the params) into someBoolean
   if someBoolean is true then
      breakpoint
   else
      -- atopia_SetHomeJournalForkDomains subDomain, forkDomain
      atopia_AddHomeJournalForkDomains subDomain, forkDomain
   end if
end menu_AddHomeForkEvents

on _
end _

on menu_AddToAuthorArray subDomain
   atopia_AddToOwnershipArray subDomain
   --
   display_LocalAuthorNameData
end menu_AddToAuthorArray

on menu_AddAuthorDomain subDomain, authorName
   put atopia_FetchConfigArray() into configArray
   put atopia_ConstructConfigDomainArray (authorName) into domainArray
   put domainArray into configArray ["wikiDomains"][subDomain]
   --
   display_AtopiaConfigJson configArray
end menu_AddAuthorDomain

on menu_UpdateDomainOwnership subDomain
   atopia_UpdateOwnershipArray subDomain
   --
   display_AtopiaOwnerDomains "No Email"
   display_AtopiaOwnerDomains "david.bovill@gmail.com"
   display_AtopiaOwnerDomains "david@mediagarden.org"
end menu_UpdateDomainOwnership

on menu_DeleteFromOwnership subDomain
   atopia_DeleteDomainFromOwnershipArray subDomain
end menu_DeleteFromOwnership

on _
end _

on menu_MoveOrUpdateAtopiaArray subDomain
   atopia_UpdateArrayAndMove subDomain
   put the result into resultArray
   --
   display_AtopiaUpdateResult resultArray, indexView
end menu_MoveOrUpdateAtopiaArray

on menu_MoveToTrash subDomain
   put "Move" && kwote (subDomain) && "to the _trash folder?" into someQuestion
   _AnswerQuestion someQuestion
   --
   set the cursor to watch
   --
   atopia_MoveToTrash subDomain
   put the result into atopiaArray
   --
   set the deleted_Line of indexView to subDomain
end menu_MoveToTrash

on menu_MoveToUnhosted subDomain
   put "Move" && kwote (subDomain) && "to the _unhosted_sites folder?" into someQuestion
   _AnswerQuestion someQuestion
   --
   set the cursor to watch
   atopia_MoveToUnhosted subDomain
   put the result into atopiaArray
   
   set the deleted_Line of indexView to subDomain
end menu_MoveToUnhosted

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_DisplayWikiPages subDomain
   display_AtopiaWikiPages subDomain
end menu_DisplayWikiPages

on menu_GetConfigInfo subDomain
   put atopia_GetDomainConfigArray (subDomain) into domainConfigArray
   put atopia_GetDomainOwnerIdPath (subDomain)
   --
   display_Array domainConfigArray
end menu_GetConfigInfo

on menu_DisplayDomainInfo subDomain
   put dig_GetNS (subDomain) into nameServers
   switch
      case line 1 of nameServers ends with ".digitalocean.com."
         put digitalocean_GetDomainArray (subDomain) into domainArray
         display_Array domainArray, "digitalocean_GetDomainArray"
         break
      case line 1 of nameServers ends with ".dynadot.com."
         _AnswerQuestion "Nameservers are Dyanadot Hosted"
         break
      default
         put nameServers
         _AnswerQuestion "Nameservers are from someone else!"
   end switch
end menu_DisplayDomainInfo

on menu_FindAuthor subDomain
   put atopia_FetchEmail (subDomain) into ownerEmail
   put ownerEmail
end menu_FindAuthor

on _
end _

on menu_Dig subDomain
   put dig_GetIP (subDomain) into someIP
   put dig_GetNS (subDomain) into nameServers
   -- put dig_GetDomain (someIP) into rAddress
   --
   put someIP & CR & nameServers
end menu_Dig

on menu_LsArray subDomain
   put atopia_FetchDomainLsArray (subDomain) into lsArray
   --
   put subDomain & ",LS Files" into displayTitle
   display_Array lsArray, displayTitle
end menu_LsArray

on menu_WikiPageFileArray subDomain
   put atopia_FetchWikiPageFileArray (subDomain) into fileArray
   --
   put subDomain & ",atopia_FetchWikiPageFileArray()" into displayTitle
   display_Array fileArray, displayTitle
end menu_WikiPageFileArray
