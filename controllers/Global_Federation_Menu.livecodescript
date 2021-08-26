script "Global | Federation | Menu"
--> MetaData
-
license: GPLv3
name: Global | Federation | Menu
type: controller
version: 0.2


--> Menu | Init
-
on mDoubleUp_Federation displayView, someLine
   breakpoint
   put the title_Text of displayView into someTitle
end mDoubleUp_Federation

getprop modelDocumentation_Params
   return "Federation Model,Author Model,Server Model,-,All"
end modelDocumentation_Params

command serverData_SetSummary serverModel, pListHow
   put the keys of serverModel into serverNames
   sort serverNames
   repeat for each line serverName in serverNames
      put word 1 to -1 of serverName into serverName
      if serverName is empty then next repeat
      --
      fedserver_UpdateServerModel serverModel, serverName
      put the result into summaryText
      put word -2 of summaryText into domainNum
      put word 1 of summaryText into serverPageNum
      --
      switch pListHow
         case "Extended"
            put "1. [[" & serverName && "Server" & "]] (" & summaryText & ")" into indexLine
            break
         case "Simple"
            put "- [[" & serverName && "Server" & "]]" into indexLine
            break
         default
            put "1. [[" & serverName && "Server" & "]] (" & domainNum && "domains)" into indexLine
      end switch
      put indexLine & CR after markdownList
   end repeat
   delete char -1 of markdownList
   
   switch pListHow
      case "Simple"
         -- don't sort again
         break
      case "Extended"
         -- don't sort again
         sort numeric descending markdownList by word -2 of each
         break
      default
         sort numeric descending markdownList by token -3 of each
   end switch
   return markdownList
end serverData_SetSummary


--> Global | Federation | Menu
-
on menu_FederationBuilder
   display_FederationBuilder
end menu_FederationBuilder

on menu_WardsFedrayUpdater
   put ward_FetchSiteModel() into fedray
   display_FedrayUpdate fedray, "Federation Fedray"
end menu_WardsFedrayUpdater

on submenu_Display
   return "Global | Federation | Display | Menu"
end submenu_Display

on menu_ModelDocumentation arrayView, modelName
   switch modelName
      case "All"
         put "http://roster.fedwiki.org/view/welcome-visitors/view/federation-model/view/server-model/view/author-model/view/federation-domain-index" into launchURL
         break
      case "-"
      case "Federation Model"
      case "Author Model"
      case "Server Model"
         put federation_ModelDocUrl (modelName) into launchURL
         break
   end switch
   launch url launchURL
end menu_ModelDocumentation

on submenu_Build
   return "Global | Federation | Build | Menu"
end submenu_Build

on submenu_Federation
   return "Global | Federation | Display | Menu"
end submenu_Federation

on menu_DisplayFederationServers
   display_FederationServers
end menu_DisplayFederationServers

on menu_FederationBuilder
   display_FederationBuilder
end menu_FederationBuilder

on menu_WardsFedrayUpdater
   put ward_FetchSiteModel() into fedray
   display_FedrayUpdate fedray, "Federation Fedray"
end menu_WardsFedrayUpdater

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _FedrayLoadUpdate displayView
   put the displayed_Index of displayView into atopiaFolders
   fedray_LoadUpdateTests atopiaFolders, displayView
end _FedrayLoadUpdate

on _BuildWardsWithoutAtopia displayView
   set the cursor to watch
   --
   put atopia_FetchDomainArray() into fedray
   put fedray_FetchUnion() into fedrayWithoutAtopia
   --
   difference fedrayWithoutAtopia with fedray
   put the keys of fedrayWithoutAtopia into withoutAtopiaDomains
   -- 
   _BuildWithoutAtopia fedray, withoutAtopiaDomains, displayView
   put the result into resultArray
   --
   -- lcw_Answer "Store fedray?", displayView
   fedray_StoreModel fedray
   --
   display_Data resultArray, "WithoutAtopia", "Build Wards"
   put the result into displayView
   set the title_Menu of displayView to "Global | Fedray | Rebuild | Menu" 
   --
   return resultArray
end _BuildWardsWithoutAtopia

on _CheckAtopiaDomainArray displayView
   put the displayed_Array of displayView into atopiaDomainArray
   put the keys of atopiaDomainArray into atopiaDomains
   repeat for each line wikiDomain in atopiaDomains
      put fedwiki_JsonSiteMapUrl (wikiDomain) into sitemapURL
      load url sitemapURL with "atopia_CheckDomainAndUpdateMetadata"
      exit repeat
   end repeat
end _CheckAtopiaDomainArray

on _UpdateFederation
   display_UpdateFederation
end _UpdateFederation

on _UpdateFederation indexView
   display_UpdateFederation
end _UpdateFederation

on _UpdateBothFedrays indexView
   display_UpdateBothFedrays indexView
end _UpdateBothFedrays

on _AddNewFederationSites indexView
   -- only updates indexes (no trashing) - uses "fedray_UpdateLastModified"
   display_AndAddNewFederationSites indexView
end _AddNewFederationSites

on _AddOwnedToFedray indexView
   put atopia_GetLocalEmailOwnerData() into ownershipArray
   fedray_AddOwnershipArray ownershipArray, "atopia.array"
end _AddOwnedToFedray

on _
end _

on _DisplayFederationServers
   display_FederationServers
end _DisplayFederationServers

on _PublishAllServerDetails arrayView
   put the displayed_Data of arrayView into serverData
   serverData_SetSummary serverData
   put the result into serverIndex
   --
   fedwiki_UpdatePageItem serverIndex, "0a8b96e99434a34d", "welcome-visitors", "server.fedwiki.org"
   --
   put federation_ConstructServerModel() into federationServerModel
   repeat for each key serverName in serverData
      set the cursor to busy
      federation_UpdateServerPage serverName, federationServerModel
   end repeat
   --
   launch url "http://server.fedwiki.org"
end _PublishAllServerDetails

on _AzureEntites
   put lcw_Ask ("Choose a domain to index..", "david.bovill.me") into wikiDomain
   display_AzureEntities wikiDomain
end _AzureEntites

on _StoreAuthorArray
   breakpoint
   put "david.bovill@gmail.com" into ownerEmail
   --
   put atopia_GetOwnershipArray() into ownershipArray
   put atopia_GetGoodDomainArray() into atopiaGoodArray
   put ownershipArray [ownerEmail]["domains"] into authorDomainArray
   repeat with itemNum =1 to item 2 of the extents of authorDomainArray
      set the cursor to busy
      put authorDomainArray [itemNum]["domain"] into domainName
      put atopiaGoodArray [domainName] into pageSlugs
      put the number of lines of pageSlugs into numOfPages
      put numOfPages into wDomainArray [domainName]["pages"]
   end repeat
   --
   atopia_StorePersonArray "people-template", wDomainArray
   -- atopia_StorePersonArray "david-bovill", wDomainArray
   put atopia_FetchPersonJSON ("david-bovill")
end _StoreAuthorArray

