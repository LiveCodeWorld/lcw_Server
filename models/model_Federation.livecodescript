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

--> Federation | Ward
-
function author_ListRecentSites authorName
   put author_FetchModelDomains (authorName) into authorDomains
   put ward_ListRecentDomains() into thisWeeksFederationDomains
   put line_GetCommon (thisWeeksFederationDomains, authorDomains) into thisWeeksAuthorDomains
   return thisWeeksAuthorDomains
end author_ListRecentSites

function federation_FetchWeekDomainArray
   -- all domains of the last week
   put ward_ListRecentDomains() into weekDomainArray
   put date_GetSinceSeconds ("1 week") into sinceSeconds 
   put atopia_ListRecentDomains (sinceSeconds) into recentAtopiaDomains
   split recentAtopiaDomains with CR as set
   split weekDomainArray with CR as set
   union weekDomainArray with recentAtopiaDomains
   return weekDomainArray
end federation_FetchWeekDomainArray


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

function federation_ListWeekDomains
   -- all domains of the last week
   put federation_FetchWeekDomainArray() into weekDomainArray
   put the keys of weekDomainArray into recentDomains
   url_SortDomainIndex recentDomains
   return recentDomains
end federation_ListWeekDomains


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
