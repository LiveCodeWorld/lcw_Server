script "model_FedScrape"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_FedScrape
type: model
version: 0.1


--> Display
-
command display_RecentScrapePages pSincePeriod, pDisplayView, pPalette
   local mDoubleUp
   --
   -- put fedray_FetchRecentSites (pSincePeriod) into modifiedSites
   put ward_ListRecentDomains() into modifiedSites
   put fedwiki_FetchRecentDomainPageArray (modifiedSites, pSincePeriod) into domainPageArray
   --
   put "Global | Federation | Tree | Menu" into mTitle
   put "Global | Federation | Line | Menu" into mLineTitle
   --
   display_Data domainPageArray, "Recent Wiki Pages", "Federation", pDisplayView, pPalette
   put the result into pDisplayView
   display_SetIndexMenus pDisplayView, mTitle, mLineTitle, mDoubleUp
   --
   return pDisplayView
end display_RecentScrapePages

command display_WardsRecentDomains pDisplayView, pPalette
   put ward_ListRecentDomains() into recentFederationDomains
   --   
   put "Global | Federation | Tree | Menu" into mTitle
   put "Global | Federation | Line | Menu" into mLineTitle
   --
   display_Data recentFederationDomains, "Ward's 8 day Scrape", "Federation", pDisplayView, pPalette
   put the result into pDisplayView
   display_SetIndexMenus pDisplayView, mTitle, mLineTitle, mDoubleUp
   --
   return pDisplayView
end display_WardsRecentDomains

command display_AndAddNewFederationSites indexView
   -- no idea about this one (see also "display_UpdateBothFedrays")
   -- only updates indexes (no trashing) 
   -- uses "fedray_UpdateLastModified"
   -- see also
   
   put ward_ListNewSites() into recentFederationDomains
   sort recentFederationDomains
   set the displayed_Index ["Wards New Sites"] of indexView to recentFederationDomains
   --
   put fedray_FetchModel() into fedray
   repeat for each line wikiDomain in recentFederationDomains
      display_Spin wikiDomain, indexView
      put the result into lineNum
      --
      set the line_Colour [lineNum] of indexView to red
      atopia_ToggleIsIndexed wikiDomain, true, true
      --
      fedray_UpdateLastModified fedray, wikiDomain
      --
      get the result
      if it is empty then
         set the line_Colour [lineNum] of indexView to red
         set the deleted_Line of indexView to lineNum
      else
         put wikiDomain & CR after newSites
         set the line_Colour [lineNum] of indexView to green
      end if
   end repeat
   delete char -1 of newSites
   fedray_StoreModel fedray
   --
   put ward_ListNewSites (true) into newSites
   set the displayed_Index ["New Federation Sites"] of indexView to newSites
   return newSites
end display_AndAddNewFederationSites


--> Working on
-
function federation_FetchRecentFedray pSincePeriod
   -- combine recent Atopia folders, recent stored fedray, and wards 7 week scrape (no updating or checking for speed)
   put ward_FetchRecentRoster() into wardsRosterText
   if pSincePeriod is "1 day" then
      put ward_RecentDomainArray (wardsRosterText, "today") into recentFedray
   else
      put ward_RecentDomainArray (wardsRosterText) into recentFedray -- just 8 days worth
   end if
   
   put fedray_FetchModel() into fedray
   put fedray_FilterSince (fedray, pSincePeriod) into recentStoredFedray
   union recentFedray with recentStoredFedray
   --
   put atopia_FetchSinceDomainArray (pSincePeriod) into recentAtopiaFedray
   union recentFedray with recentAtopiaFedray
   --
   return recentFedray
end federation_FetchRecentFedray

function fedray_FetchUnion
   put fedray_FetchModel() into fedray
   put ward_FetchSiteModel() into wardsFedray
   union fedray with wardsFedray
   --
   put atopia_FetchDateArray() into atopiaDateArray
   union fedray with atopiaDateArray
   --
   return fedray
end fedray_FetchUnion


--> Fedray | Scrape | Update
-
command fedray_UpdateThisWeek pCheckWikiExists
   put ward_ListRecentDomains (empty, pCheckWikiExists) into wardSites
   fedray_Update wardSites
   put the result into fedray
   return fedray
end fedray_UpdateThisWeek

command fedray_UpdateToday pCheckWikiExists
   put ward_ListRecentDomains ("today", pCheckWikiExists) into wardSites
   fedray_Update wardSites
   put the result into fedray
   return fedray
end fedray_UpdateToday

command fedray_Update wikiDomains
   put fedray_FetchModel() into fedray
   repeat for each line wikiDomain in wikiDomains
      set the cursor to busy
      fedray_UpdateLastModified fedray, wikiDomain
   end repeat
   fedray_StoreModel fedray
   return fedray
end fedray_Update


--> Fedray | Scrape | Domains | Recent
-
function ward_ListNewSites pSincePeriod
   put ward_FetchRecentRoster() into wardsRosterText
   if pSincePeriod is "1 day" then
      put ward_RecentDomainArray (wardsRosterText, "1 day") into recentFedray
   else
      put ward_RecentDomainArray (wardsRosterText) into recentFedray -- just 8 days worth
   end if
   --
   put fedray_FetchModel() into fedray
   difference recentFedray with fedray
   put the keys of recentFedray into newSites
   --
   url_SortDomainIndex newSites
   return newSites
end ward_ListNewSites

function ward_ListRecentDomains pDayName, pCheckWikiExists
   put ward_FetchRecentDomainArray (pDayName) into wardsFedray
   put the keys of wardsFedray into domainNames
   --
   url_SortDomainIndex domainNames
   if pCheckWikiExists then
      federation_CheckDomainExists domainNames
   end if
   return domainNames
end ward_ListRecentDomains


--> Fedray | Scrape | Domains
-
function ward_ListTopDomains
   -- fetch all federation domains from wards scrape
   put ward_ListAllDomains() into federationDomains
   put url_ListTopDomains (federationDomains) into topFederationDomains
   return topFederationDomains
end ward_ListTopDomains

function ward_ListAllDomains pDayName, pCheckDomains
   put ward_FetchSiteModel() into siteArray
   put keys (siteArray) into domainNames
   --
   if pCheckDomains is true then
      line_SetUnique domainNames
      url_CheckDomainIndex domainNames -- quick syntax check
   end if
   --
   url_SortDomainIndex domainNames
   return domainNames
end ward_ListAllDomains


--> Ward | Scrape | Model
-
function ward_FetchRecentDomainArray pDayName
   put ward_FetchRecentRoster() into wardsRosterText
   put ward_RecentDomainArray (wardsRosterText, pDayName) into wardsFedray
   return wardsFedray
end ward_FetchRecentDomainArray

function ward_FetchSiteModel
   -- was "fedray_FetchWards"
   put ward_FetchSiteJSON() into siteJSON
   put json_ToArray (siteJSON) into siteArray
   return siteArray
end ward_FetchSiteModel

function ward_RecentDomainArray wardsRosterText, pDayName
   local domainArray
   if pDayName = "today" then
      put item 1 of the internet date into pDayName
   end if
   --
   set the itemdelimiter to "-"
   repeat for each line someLine in wardsRosterText      
      switch
         case word 1 to -1 of someLine is empty
            next repeat
         case someLine contains "." AND pDayName is empty
         case someLine contains "." AND pDayName = thisDay
            -- it's a domain 
            put empty into domainArray [someLine]
            break
         case someLine contains "."
            -- next repeat -- first and last days repeated a week apart
            if domainArray is an array then
               return domainArray
            else
               -- not found first day yet keep going
               next repeat
            end if
         default
            -- it's a date
            put item 1 of someLine into thisDay
      end switch
   end repeat
   return domainArray
end ward_RecentDomainArray


--> Fedray | Scrape | Model  | Text
-
function ward_FetchLogTable
   put url "http://search.fed.wiki.org:3030/logs" into folderHTML
   -- <a href="/logs/Thu-2000.txt">Thu-2000</a><br>
   put "<a href='/logs/(.+)'>.+</a><br>" into someReg
   replace "'" with quote in someReg
   get line 1 of folderHTML
   if matchText (it, someReg, shortFile) is false then
      return empty
   end if
   
   put "http://search.fed.wiki.org:3030/logs/" & shortFile into someURL
   put url someURL into someTable
   return someTable
end ward_FetchLogTable

function ward_FetchRecentRoster
   put pageArray_Fetch ("search.fed.wiki.org:3030", "recent-activity", true) into pageArray
   put pageArray_FindItemType ("roster", pageArray) into itemNum
   put pageArray ["story"][itemNum]["text"] into domainNames
   return domainNames
end ward_FetchRecentRoster

function ward_FetchSiteJSON
   -- was "fedray_FetchWardsJson"
   put url "http://search.fed.wiki.org:3030/site-web.json" into siteJSON
   return siteJSON
end ward_FetchSiteJSON
