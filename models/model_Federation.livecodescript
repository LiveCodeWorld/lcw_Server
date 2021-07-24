script "model_Federation"
--> MetaData
-
license: GPLv3
name: model_Federation
type: model
version: 0.2

/*
See atopia_FetchDomains
*/

--> Working on
-
function federation_FetchRecentFedray pSincePeriod
   -- combine recent Atopia folders, recent stored fedray, and wards 7 week scrape (no updating or checking for speed)
   put fedray_FetchWardsRecentRoster() into wardsRosterText
   if pSincePeriod is "1 day" then
      put fedray_FetchWardsDomainArray (wardsRosterText, "today") into recentFedray
   else
      put fedray_FetchWardsDomainArray (wardsRosterText) into recentFedray -- just 8 days worth
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


--> Federation | List
-
function federation_ListRecentDomains pSincePeriod
   put federation_FetchRecentFedray (pSincePeriod) into recentFedray
   put the keys of recentFedray into wikiDomains
   url_SortDomainIndex wikiDomains
   return wikiDomains
end federation_ListRecentDomains

function fedray_FetchRecentSites pSincePeriod
   put fedray_FetchModel() into fedray
   put fedray_ListLastModified (fedray, pSincePeriod) into modifiedSites
   return modifiedSites   
end fedray_FetchRecentSites

function author_ListRecentSites authorName
   -- put author_FetchRosterSites (authorName, "(recent sites)")
   -- put author_FetchRosterSites (authorName, "(sites)") into authorDomains
   put author_FetchModelDomains (authorName) into authorDomains
   put fedray_FetchWardsRecentDomains() into thisWeeksFederationDomains
   put line_GetCommon (thisWeeksFederationDomains, authorDomains) into thisWeeksAuthorDomains
   return thisWeeksAuthorDomains
end author_ListRecentSites


--> Fedray | Model | Union
-
function federation_ListDomains pWikiDomain
   -- slower than fedray_FetchDomains() (but thorough)
   put fedray_FetchUnion() into fedray
   put keys (fedray) into fedrayDomains
   url_SortDomainIndex fedrayDomains
   --
   if pWikiDomain is not empty then
      filter fedrayDomains with ("*." & pWikiDomain)
      put pWikiDomain & CR before fedrayDomains
   end if
   return fedrayDomains
end federation_ListDomains

function fedray_FetchUnion
   put fedray_FetchModel() into fedray
   put fedray_FetchWards() into wardsFedray
   union fedray with wardsFedray
   --
   put atopia_FetchDateArray() into atopiaDateArray
   union fedray with atopiaDateArray
   --
   return fedray
end fedray_FetchUnion

function federation_ListWeekDomains
   -- all domains of the last week
   put federation_FetchWeekDomainArray() into weekDomainArray
   put the keys of weekDomainArray into recentDomains
   url_SortDomainIndex recentDomains
   return recentDomains
end federation_ListWeekDomains

function federation_FetchWeekDomainArray
   -- all domains of the last week
   put fedray_FetchWardsRecentDomains() into weekDomainArray
   put date_GetSinceSeconds ("1 week") into sinceSeconds 
   put atopia_ListRecentDomains (sinceSeconds) into recentAtopiaDomains
   split recentAtopiaDomains with CR as set
   split weekDomainArray with CR as set
   union weekDomainArray with recentAtopiaDomains
   return weekDomainArray
end federation_FetchWeekDomainArray


--> Fedray | Filter
-
function fedray_FilterSince fedray, pSincePeriod
   if pSincePeriod is empty then put "1 week" into pSincePeriod
   
   put 1000 * date_GetSinceSeconds (pSincePeriod) into sinceMilliSeconds
   repeat for each key wikiDomain in fedray
      set the cursor to busy 
      put fedray [wikiDomain] ["last modified"] into lastModified
      if lastModified <= sinceMilliSeconds then
         delete variable fedray [wikiDomain]
      end if
   end repeat
   return fedray
end fedray_FilterSince

function fedray_ListLastModified fedray, pSincePeriod
   if pSincePeriod is empty then put "1 week" into pSincePeriod
   
   put 1000 * date_GetSinceSeconds (pSincePeriod) into sinceMilliSeconds
   repeat for each key wikiDomain in fedray
      set the cursor to busy
      put fedray [wikiDomain]["last modified"] into lastModified
      --
      if lastModified > sinceMilliSeconds then
         put wikiDomain & CR after sinceDomains
      end if
   end repeat
   delete char -1 of sinceDomains
   url_SortDomainIndex sinceDomains
   return sinceDomains
end fedray_ListLastModified


--> Federation | Domains | Recent
-
function federation_TodaysSites pCheckSites
   return federation_FetchRecentSites ("1 day", pCheckSites)
end federation_TodaysSites

function federation_FetchRecentSites pSincePeriod
   put federation_FetchRecentFedray (pSincePeriod) into recentFedray
   --
   put the keys of recentFedray into recentSites
   url_SortDomainIndex recentSites
   return recentSites
end federation_FetchRecentSites

function federation_FetchNewSites pSincePeriod
   put federation_FetchRecentFedray (pSincePeriod) into recentFedray
   put fedray_FetchModel() into fedray
   --
   difference recentFedray with fedray
   put the keys of recentFederationDomains into newSites
   --
   url_SortDomainIndex newSites
   return newSites
end federation_FetchNewSites

function fedray_ListNewWardSites pSincePeriod
   put fedray_FetchWardsRecentRoster() into wardsRosterText
   if pSincePeriod is "1 day" then
      put fedray_FetchWardsDomainArray (wardsRosterText, "1 day") into recentFedray
   else
      put fedray_FetchWardsDomainArray (wardsRosterText) into recentFedray -- just 8 days worth
   end if
   put fedray_FetchModel() into fedray
   --
   difference recentFedray with fedray
   put the keys of recentFedray into newSites
   --
   url_SortDomainIndex newSites
   return newSites
end fedray_ListNewWardSites


--> Fedray | Update
-
command fedray_UpdateThisWeek pCheckWikiExists
   put fedray_FetchWardsRecentDomains (empty, pCheckWikiExists) into wardSites
   fedray_Update wardSites
   put the result into fedray
   return fedray
end fedray_UpdateThisWeek

command fedray_UpdateToday pCheckWikiExists
   put fedray_FetchWardsRecentDomains ("today", pCheckWikiExists) into wardSites
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


--> Federation | Sites | New
-
function federation_FetchRootDomains pHow
   put federation_ListDomains (pHow) into fedDomains
   put url_ListTopDomains (fedDomains) into routeDomains
   return routeDomains
end federation_FetchRootDomains

command federation_CheckDomainExists @wikiDomains
   -- see also "atopia_CheckGoodFolders"
   repeat for each line wikiDomain in wikiDomains
      set the cursor to busy
      if fedwiki_WikiExists (wikiDomain) is true then
         put wikiDomain & CR after goodDomains
      else
         put wikiDomain & CR after badDomains
      end if
   end repeat
   delete char -1 of goodDomains
   delete char -1 of badDomains
   put goodDomains into wikiDomains
   return badDomains
end federation_CheckDomainExists

function federation_FetchSiteMetadata wikiDomain
   put fedwiki_FetchSitemapArray (wikiDomain) into sitemapArray
   --
   put keys (sitemapArray) into pageSlugs
   put the number of lines of pageSlugs into pageNum
   put pageNum into siteMetaData ["pages"]
   --
   put fedwiki_SitemapLastModified (pSitemapArray) into fedray [wikiDomain]["last modified"]
   --
   put fedwiki_FetchSiteCreationDate (wikiDomain) into siteMetaData ["created"] -- fetch from welcome-visitors
   put fedwiki_FetchOwnerName (wikiDomain) into ownerName
   put ownerName into siteMetaData ["owner"]
   --
   put dig_GetIP (wikiDomain) into someIP
   put someIP into siteMetaData ["ipAddress"]
   --
   return siteMetaData
end federation_FetchSiteMetadata


--> Fedray
-
function fedray_FetchPageTotal wikiDomains, pFedray
   if pFedray is empty then put fedray_FetchModel() into pFedray
   --
   put 0 into pageTotal
   repeat for each line wikiDomain in wikiDomains
      put pFedray [wikiDomain]["pages"] into pageNum
      add pageNum to pageTotal
   end repeat
   return pageTotal
end fedray_FetchPageTotal

command fedray_CalculatePageTotal @fedray, wikiDomains, pUpdate
   -- use "fedray_FetchPageTotal()" instead
   put fedray_FetchModel() into fedray
   --
   if pUpdate is true then
      put _FetchSitemapData (wikiDomains) into sitemapData
      _UpdateSitemaps fedray, wikiDomains, sitemapData
      put the result into pageTotal
      fedray_StoreModel fedray
   else
      put fedray_FetchPageTotal (wikiDomains, fedray) into pageTotal
   end if
   --
   return pageTotal
end fedray_CalculatePageTotal

function fedray_FetchSiteCreationDate wikiDomain, pFedray
   if pFedray is empty then put fedray_FetchModel() into pFedray
   put pFedray [wikiDomain]["created"] into siteCreationDate
   return siteCreationDate
end fedray_FetchSiteCreationDate

command fedray_StoreSiteCreationDate wikiDomain, siteCreationDate, pFedray
   if pFedray is empty then put fedray_FetchModel() into pFedray
   put siteCreationDate into pFedray [wikiDomain]["created"]
   fedray_StoreModel pFedray
end fedray_StoreSiteCreationDate


--> Fedray | Model | Ward | Recent
-
function fedray_FetchWardsRecentDomains pDayName, pCheckWikiExists
   put fedray_FetchWardsRecentFedray (pDayName) into wardsFedray
   put the keys of wardsFedray into domainNames
   --
   -- url_CheckDomainIndex domainNames
   url_SortDomainIndex domainNames
   --
   if pCheckWikiExists then
      -- see also "atopia_CheckGoodFolders"
      federation_CheckDomainExists domainNames
   end if
   return domainNames
end fedray_FetchWardsRecentDomains

function fedray_FetchWardsRecentFedray pDayName
   put fedray_FetchWardsRecentRoster() into wardsRosterText
   put fedray_FetchWardsDomainArray (wardsRosterText, pDayName) into wardsFedray
   return wardsFedray
end fedray_FetchWardsRecentFedray

function fedray_FetchWardsDomainArray wardsRosterText, pDayName
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
end fedray_FetchWardsDomainArray

function fedray_FetchWardsRecentRoster
   put pageArray_Fetch ("search.fed.wiki.org:3030", "recent-activity", true) into pageArray
   put pageArray_FindItemType ("roster", pageArray) into itemNum
   put pageArray ["story"][itemNum]["text"] into domainNames
   return domainNames
end fedray_FetchWardsRecentRoster


--> Fedray | Model | Ward
-
function fedray_FetchWardsLogTable
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
end fedray_FetchWardsLogTable

function fedray_FetchWardsTopDomains
   -- fetch all federation domains from wards scrape
   put fedray_FetchWardsDomains() into federationDomains
   put url_ListTopDomains (federationDomains) into topFederationDomains
   return topFederationDomains
end fedray_FetchWardsTopDomains

function fedray_FetchWardsDomains pDayName, pCheckDomains
   put fedray_FetchWards() into siteArray
   put keys (siteArray) into domainNames
   --
   if pCheckDomains is true then
      line_SetUnique domainNames
      url_CheckDomainIndex domainNames -- quick syntax check
   end if
   --
   url_SortDomainIndex domainNames
   return domainNames
end fedray_FetchWardsDomains

function fedray_FetchWards
   put fedray_FetchWardsJson() into siteJSON
   put json_ToArray (siteJSON) into siteArray
   return siteArray
end fedray_FetchWards

function fedray_FetchWardsJson
   put url "http://search.fed.wiki.org:3030/site-web.json" into siteJSON
   return siteJSON
end fedray_FetchWardsJson
