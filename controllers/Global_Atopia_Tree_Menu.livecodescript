script "Global | Atopia | Tree | Menu"
--> MetaData
-
license: GPLv3
name: Global | Atopia | Tree | Menu
type: controller
version: 0.4


--> Global | Atopia | Tree | Menu
-
on menu_TrashUpdateAtopiaDomains indexView
   put the displayed_Index of indexView into atopiaDomains
   lcw_Answer "Are you sure you want to trash and update metadata for all these Atopia domains?", indexView
   --
   display_TrashUpdateAtopiaDomains indexView, atopiaDomains
end menu_TrashUpdateAtopiaDomains

on _
end _

on submenu_Atopia
   return "Global | Atopia | Display | Menu"
end submenu_Atopia

on submenu_Home
   return "Global | Atopia | Home | Menu"
end submenu_Home

on _
end _

on submenu_Federation
   return "Global | Federation | Display | Menu"
end submenu_Federation

on submenu_Build
   return "Global | Atopia | Build | Menu"
end submenu_Build

on _
end _

on menu_DisplayTransportLibs
   display_TransporterLibs
end menu_DisplayTransportLibs

on menu_DisplayFederationServers
   display_FederationServers
end menu_DisplayFederationServers

on menu_FederationBuilder
   display_FederationBuilder
end menu_FederationBuilder

on menu_WardsFedrayUpdater
   put fedray_FetchWards() into fedray
   display_FedrayUpdate fedray, "Federation Fedray"
end menu_WardsFedrayUpdater

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_MyUpdatedPageArray
   put author_FetchUpdatedPageArray ("David Bovill", "1 day") into pageArray
   display_PageArray pageArray
end menu_MyUpdatedPageArray

on _
end _

on menu_UnloadSitemaps
   fedwiki_UnloadSitemaps
end menu_UnloadSitemaps

on _
end _

on menu_DisplayAtopiaFedray
   display_AtopiaFedray
end menu_DisplayAtopiaFedray

on menu_AtopiaFedrayUpdater
   put atopia_FetchDomainArray() into fedray
   display_FedrayUpdate fedray, "Atopia Fedray"
end menu_AtopiaFedrayUpdater

on menu_LaunchAtopiaFedrayPage   
   fedwiki_Launch "server.fedwiki.org", "atopia-domain-index"
end menu_LaunchAtopiaFedrayPage

on _
end _

-- on menu_DisplayLocalAuthorNameData
display_LocalAuthorNameData
end menu_DisplayLocalAuthorNameData

on menu_TestTokenArray
   put atopia_FetchTokensArray ("roster.fedwiki.org") into tokenArray
   display_Array tokenArray
end menu_TestTokenArray

on _
end _

on menu_CheckGoogled indexView
   put atopia_FetchFolders() into allDomains
   set the displayed_Index ["Googled Folders"] of indexView to allDomains
   lcw_Answer "Check all Atopia Folders for CSE status, and display coloured line result?", indexView
   --
   put cse_FetchConsoleDomains() into consoleDomainNames
   if consoleDomainNames is empty then
      breakpoint
      exit to top
   end if
   --
   set the wholematches to true
   repeat for each line domainName in allDomains
      display_Spin domainName, indexView
      put the result into lineNum
      --
      if domainName is among the lines of consoleDomainNames then
         put cse_ListSitemaps (domainName) into siteMaps
         if siteMaps is empty then
            set the line_Colour [lineNum] of indexView to orange
            put true into resultArray ["missing sitemap"][domainName]
         else
            set the line_Colour [lineNum] of indexView to green
            put true into resultArray ["good sitemap"][domainName]
         end if
      else
         put true into resultArray ["missing domain"][domainName]
         set the line_Colour [lineNum] of indexView to red
      end if
   end repeat
   set the displayed_Array of indexView to resultArray
   --
   put resultArray ["missing domain"] into missingDomainArray
   put keys (missingDomainArray) into missingDomains
   url_SortDomainIndex missingDomains
   set the displayed_Index ["Missing CSE Domains"] of indexView to missingDomains
   --
   display_Array resultArray, "Atopia,Google CSE Status"
end menu_CheckGoogled


--> Atopia | Tokens
-
command atopia_StoreTokensJson wikiDomain
   -- need to create nested forlder paths
   breakpoint
   put atopia_WikiDomainFolder ("server.fedwiki.org") into wikiFolderPath
   put wikiFolderPath & "/status/plugin/json/tokens.json" into jsonPath
   --
   atopia_StoreData wikiPagePath, pageJSON
   
end atopia_StoreTokensJson

function atopia_ConstructPluginTokensArray
   put "atopia" into tokenArray ["*"]["eced0677c98e04d2"]["id"] 
   put "david, experimental use only" into tokenArray ["*"]["eced0677c98e04d2"]["nb"] 
   return tokenArray
end atopia_ConstructPluginTokensArray

function atopia_FetchTokensArray wikiDomain
   put "server.fedwiki.org" into wikiDomain
   put atopia_FetchTokensJson (wikiDomain) into tokenJSON
   put json_ToArray (tokenJSON) into tokenArray
   return tokenArray
end atopia_FetchTokensArray

function atopia_FetchTokensJson wikiDomain
   put atopia_WikiDomainFolder (wikiDomain) into wikiFolderPath
   put wikiFolderPath & "/status/plugin/json/tokens.json" into jsonPath
   --
   put atopia_FetchData (jsonPath) into tokenJSON
   return tokenJSON
end atopia_FetchTokensJson
