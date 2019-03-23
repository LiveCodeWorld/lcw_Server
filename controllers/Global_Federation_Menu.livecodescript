script "Global_Federation_Menu"
--> MetaData
-
license: GPLv3
name: Global_Federation_Menu
type: controller
version: 0.1


--> Working on
-
on mDoubleUp_Test indexView, wikiDomain
   
end mDoubleUp_Test


--> Global | Federation | Menu
-
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

on menu_PublishServerDetails arrayView
   put the displayed_Data of arrayView into serverData
   serverData_SetSummary serverData
   put the result into serverIndex
   --
   fedwiki_UpdatePageItem serverIndex, "0a8b96e99434a34d", "welcome-visitors", "server.fedwiki.org"
   --
   repeat for each key serverName in serverData
      set the cursor to busy
      federation_UpdateServerPage serverName, serverData
   end repeat
   --
   launch url "http://server.fedwiki.org"
end menu_PublishServerDetails

on _
end _


on menu_AzureEntites
   put lcw_Ask ("Choose a domain to index..", "david.bovill.me") into wikiDomain
   display_AzureEntities wikiDomain
end menu_AzureEntites

on submenu_Build
   return "Global | Federation | Build | Menu"
end submenu_Build

on menu_Display arrayView, displayWhat
   switch displayWhat
      case "Local Fedray"
         display_LocalFedray
         exit to top
         break
      case "-"
      case "Federation Model"
         put fedray_Fetch() into someArray
         set the line_Menu of arrayView to "Global | Federation | Line | Menu"
         break
      case "Server Model"
         put federation_FetchServerData() into someArray
         set the line_Menu of arrayView to "Global | Federation | Server | Line | Menu"
         break
      case "Author Model"
         put federation_FetchAuthorData() into someArray
         set the line_Menu of arrayView to "Global | Federation | Author | Line | Menu"
         break
   end switch
   set the displayed_Array [displayWhat] of arrayView to someArray
end menu_Display

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Federation | Menu | Props
-

--> Global | Federation | Menu | Disabled
-

--> Dev | Menu
-
on menu_StoreAuthorArray
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
end menu_StoreAuthorArray
