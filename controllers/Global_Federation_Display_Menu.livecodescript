script "Global | Federation | Display | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Federation | Display | Menu
type: controller
version: 0.1

/*
Important things to display fo examining the federation and Atopia servers
*/


--> Variables
-
local LocalArray


--> Menu | Props
-


--> Global | Federation | Display | Menu
-
on menu_FederationNeedingUpdate displayView
   put federation_FetchSitesNeedingUpdate() into updateSites
   set the displayed_Index ["Needing Update"] of displayView to updateSites
end menu_FederationNeedingUpdate

on _
end _

on menu_NewFederationSites displayView
   put federation_FetchNewSites() into newSites
   set the displayed_Index ["New Sites"] of displayView to newSites
end menu_NewFederationSites

on menu_TodaysFederationSites displayView
   display_RecentSites "1 day", displayView
end menu_TodaysFederationSites

on menu_ThisWeeksFederationSites displayView
   display_RecentSites "1 week", displayView
end menu_ThisWeeksFederationSites

on _
end _

on menu_TodaysPages
   put "1 day" into sincePeriod
   put fedray_FetchRecentSites (sincePeriod, true) into wikiDomains
   display_RecentWikiPages wikiDomains, sincePeriod
end menu_TodaysPages

on menu_ThisWeeksPages
   put "1 week" into sincePeriod
   put fedray_FetchRecentSites (sincePeriod, true) into wikiDomains
   display_RecentWikiPages wikiDomains, sincePeriod
end menu_ThisWeeksPages

on _
end _

on menu_WardsRecentDomains displayView
   display_WardsRecentDomains displayView
end menu_WardsRecentDomains

on _
end _

on menu_TodaysFederationSites arrayView
   display_RecentSites "1 day", arrayView
end menu_TodaysFederationSites

on _
end _

on menu_WardsRecentDomains arrayView
   display_WardsRecentDomains arrayView
end menu_WardsRecentDomains

on menu_ThisWeeksFederationSites arrayView
   display_RecentSites "1 week", arrayView
end menu_ThisWeeksFederationSites

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_ServerModel arrayView
   put fedserver_FetchModel() into someArray
   set the displayed_Array ["Server Model"] of arrayView to someArray
   set the line_Menu of arrayView to "Global | Federation | Server | Line | Menu"
end menu_ServerModel

on menu_FederationModel arrayView
   put fedray_FetchModel() into someArray
   set the displayed_Array ["Federation Model"] of arrayView to someArray
   set the line_Menu of arrayView to "Global | Federation | Line | Menu"
end menu_FederationModel

on menu_FederationAuthorModel arrayView
   put author_FetchModelArray() into someArray
   set the displayed_Array ["Federation Author Model"] of arrayView to someArray
   set the line_Menu of arrayView to "Global | Federation | Author | Line | Menu"
end menu_FederationAuthorModel

on _
end _

on menu_DeadModel arrayView
   put federation_FetchModel ("Dead Model") into someArray
   set the displayed_Array ["Dead Model"] of arrayView to someArray
   set the line_Menu of arrayView to "Global | Federation | Line | Menu"
end menu_DeadModel

on menu_LocalFedray arrayView
   display_LocalFedray
end menu_LocalFedray

