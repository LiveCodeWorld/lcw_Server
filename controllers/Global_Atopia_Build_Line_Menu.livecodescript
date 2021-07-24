script "Global | Atopia | Build | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Atopia | Build | Line | Menu
type: controller
version: 0.2

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into displayView
   put displayView into LocalArray ["displayView"]
   --
   put _GetWikiDomain (displayView) into wikiDomain
   -- put wikiDomain into LocalArray ["wikiDomain"]
   --
   put atopia_SiteIsIndexed (wikiDomain) into siteIsIndexed
   put siteIsIndexed into LocalArray ["siteIsIndexed"]
   --
   put atopia_IsInDomainArray (wikiDomain) into isInDomainArray
   put isInDomainArray into LocalArray ["isInDomainArray"]
   --
   put atopia_IsInRoster (wikiDomain) into isInRoster
   put isInRoster into LocalArray ["isInRoster"]
   --
   put fedray_IsIndexed (wikiDomain) into isInFederation
   put isInFederation into LocalArray ["isInFederation"]
   --
   put siteIsIndexed AND isInDomainArray AND isInRoster AND isInFederation into LocalArray ["isIndexed"]
   --
   return wikiDomain
end menu_Target

private function _GetWikiDomain displayView
   if the array_View of displayView is empty then
      put the top_Line of displayView into wikiDomain
   else
      get the selected_Path of displayView
      put item 2 of it into wikiDomain
   end if
   return wikiDomain
end _GetWikiDomain

function _GetAtopiaDomainArray
   put LocalArray ["displayView"] into displayView
   put the atopia_DomainArray of displayView into atopiaFedray
   return atopiaFedray
end _GetAtopiaDomainArray

function _GetFedray
   put LocalArray ["displayView"] into displayView
   put the federation_DomainArray of displayView into fedray
   return fedray
end _GetFedray

getprop checked_IsIndexed
   put LocalArray ["isIndexed"] into isIndexed
   return isIndexed
end checked_IsIndexed

getprop checked_IsInFederation
   put LocalArray ["isInFederation"] into isInRoster
   return isInRoster
end checked_IsInFederation

getprop checked_IsInSites
   put LocalArray ["siteIsIndexed"] into siteIsIndexed
   return siteIsIndexed
end checked_IsInSites

getprop checked_AtopiaDomainArray
   put LocalArray ["isInDomainArray"] into isInDomainArray
   return isInDomainArray
end checked_AtopiaDomainArray

getprop checked_AtopiaRoster
   put LocalArray ["isInRoster"] into isInRoster
   return isInRoster
end checked_AtopiaRoster

getprop addDomainFork_Params
   return atopia_ListHomeForkHows()
end addDomainFork_Params

function fedwiki_StandardHomeForks
   put "fedwiki.org,orientation.fedwiki.org" into standardForkDomains
   return standardForkDomains
end fedwiki_StandardHomeForks


--> Global | Atopia | Build | Line | Menu
-
on menu_LaunchWiki wikiDomain
   fedwiki_Launch wikiDomain
end menu_LaunchWiki

on submenu_Azure
   return "Global | Federation | Line | Menu"
end submenu_Azure

on _
end _

on menu_IsIndexed wikiDomain
   put menu_ToggleChecked (the params) into toggleBoolean
   atopia_ToggleIsIndexed wikiDomain, toggleBoolean
end menu_IsIndexed

on menu_AddDomainFork wikiDomain, addHow
   atopia_AddHomeForkHow wikiDomain, addHow
end menu_AddDomainFork

on _
end _

on menu_CheckDomainOwner wikiDomain
   put fedwiki_FetchOwnerName (wikiDomain) into fetchedOwner
   --
   put _GetFedray() into processedFedray
   put processedFedray [wikiDomain]["owner"] into processedOwner
   --
   put fedray_FetchModel() into fedray
   put fedray [wikiDomain]["owner"] into fedrayOwner
   --
   put "Fetched:" && fetchedOwner & CR after someInfo
   put "Processed:" && processedOwner & CR after someInfo
   put "Fedray:" && fedrayOwner & CR after someInfo
   --
   put someInfo
end menu_CheckDomainOwner

on menu_DisplayCreationArray wikiDomain
   put fedray_FetchCreateDomainArray (wikiDomain) into resultArray ["Newly created"]
   put atopia_FetchDomainArray() into atopiaFedray
   put atopiaFedray [wikiDomain] into resultArray ["Fetched from atopia model"]
   put fedray_FetchModel() into fedray
   put fedray [wikiDomain] into resultArray ["Fetched from fedray model"]
   --
   display_Data resultArray, wikiDomain,  "Creation Array"
end menu_DisplayCreationArray

on _
end _

on menu_IsInFederation wikiDomain
   put menu_ToggleChecked (the params) into toggleBoolean
   fedray_ToggleIsIndexed toggleBoolean
end menu_IsInFederation

on menu_IsInSites wikiDomain, someBoolean
   put menu_ToggleChecked (the params) into toggleBoolean
   atopia_ToggleIsInSites wikiDomain, toggleBoolean
end menu_IsInSites

on _
end _

on menu_AtopiaRoster wikiDomain
   put menu_ToggleChecked (the params) into toggleBoolean
   atopia_ToggleIsInRoster wikiDomain, toggleBoolean
end menu_AtopiaRoster

on menu_AtopiaDomainArray wikiDomain
   put menu_ToggleChecked (the params) into toggleBoolean
   atopia_ToggleIsInDomainArray wikiDomain, toggleBoolean
end menu_AtopiaDomainArray

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-

--> Deps
-
