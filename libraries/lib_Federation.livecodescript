script "lib_Federation"
--> MetaData
-
license: GPLv3
name: lib_Federation
type: library
version: 0.2
deps: lib_Fedwiki,lib_FedwikiRoster,lib_FedwikiCreate,lib_GoogleCustomSearch,model_Fedray,lib_AtopiaFetch,lib_URL

/*
This library is for manipulating data about the entire federation.
*/


--> Working on
-
command federation_StoreAuthorDomains
   
end federation_StoreAuthorDomains

function federation_FetchAuthorDomains authorName, pAuthorArray
   if pAuthorArray is not an array then
      put federation_FetchAuthorData() into pAuthorArray
   end if
   get pAuthorArray [authorName]
   put keys (it) into domainNames
   url_SortDomainIndex domainNames
   return domainNames
end federation_FetchAuthorDomains

command federation_AuthorCreate authorName, pAuthorDomains, pScriptHelp
   put "author.fedwiki.org" into wikiDomain
   put "fedwiki.org,server.fedwiki.org" into forkDomains
   --
   put fedwiki_ConstructSlug (authorName) into pageSlug
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   if pageArray is empty then
      put federation_FetchTemplateArray (wikiDomain) into pageArray
      pageArray_Rename pageArray, authorName
      if pScriptHelp is not empty then
         put pScriptHelp into pageArray ["story"][1]["text"]
      end if
      pageArray_StripJournal pageArray
      pageArray_AddFork pageArray, forkDomains
   end if
   --
   put _AuthorCurlyData (authorName, pAuthorDomains) into curlyData
   curly_MergePageArray pageArray, curlyData
   --
   pageArray_Store wikiDomain, pageSlug, pageArray
   put the result into shellResult
   if shellResult is empty then
      return pageArray
   else
      return shellResult
   end if
end federation_AuthorCreate


--> Federation | Recent
-
function federation_FetchMyRecentOther pCheckWikiSite
   -- put federation_FetchMyRecentOther (false) into domainNames
   -- put federation_FetchMyRecentOther (true) into rosterDomains
   put atopia_FetchRoster (empty, false) into minusDomains
   --
   put fedray_FetchWardsRecentDomains (pCheckWikiSite, minusDomains) into domainNames
   return domainNames
end federation_FetchMyRecentOther

function federation_RecentWithoutAtopiaDomains pCheckWikiSite
   put federation_FetchRecentFiltered ("server.fedwiki.org", "atopia-domain-index", "741a0fcdd3ff76b2", pCheckWikiSite) into fedWithoutAtopiaDomains
   return fedWithoutAtopiaDomains
end federation_RecentWithoutAtopiaDomains

function federation_FetchRecentFiltered wikiDomain, pageSlug, minusID, pCheckWikiSite
   put roster_Fetch (wikiDomain, pageSlug, minusID) into domainsToStrip
   delete line 1 to 2 of domainsToStrip
   put fedray_FetchWardsRecentDomains (pCheckWikiSite, domainsToStrip) into domainNames
   return domainNames
end federation_FetchRecentFiltered

function federation_FetchRecentAtopia
   put fedray_FetchWardsRecentDomains() into recentFedDomains
   put atopia_FetchRoster() into atopiaDomains
   put line_GetCommon (recentFedDomains, atopiaDomains) into recentAtopiaDomains
   url_SortDomainIndex recentAtopiaDomains
   return recentAtopiaDomains
end federation_FetchRecentAtopia

function federation_RecentStripped
   put federation_RecentWithoutAtopiaDomains() into domainNames
   fedwiki_FilterCheck domainNames
   put the result into badNames
   return badNames
end federation_RecentStripped


--> Atopia | SitePages
-
function atopia_SitePagesToCreate pHow
   put atopia_ListSites() into atopiaSites
   put atopia_FetchDomains (pHow) into atopiaDomains
   line_DeleteIndex atopiaDomains, atopiaSites
   return atopiaDomains
end atopia_SitePagesToCreate

function atopia_ListSites
   -- at the moment this is only atopia sites
   return federation_ListSites()
end atopia_ListSites

function federation_SitePagesToCreate pHow
   put federation_ListSites() into fedSites
   put federation_FetchDomains (pHow) into fedDomains
   line_DeleteIndex fedDomains, fedSites
   return fedDomains
end federation_SitePagesToCreate

function federation_ListSites
   -- at the moment this is only atopia sites
   put fedwiki_ListSitemapPages ("sites.fedwiki.org") into sitemapPages
   line_Delete "Welcome Visitors", sitemapPages
   sort sitemapPages
   return sitemapPages
end federation_ListSites


--> Federation | Wikidomains
-
function federation_GetLastModified wikiDomains, fedray
   put 0 into maxUpdate
   repeat for each line wikiDomain in wikiDomains
      put fedray [wikiDomain]["last modified"] into lastUpdate
      if lastUpdate > maxUpdate then
         put lastUpdate into maxUpdate
      end if
   end repeat
   return maxUpdate
end federation_GetLastModified

function federation_FetchFirstDate wikiDomains, fedray
   -- for a quick hack we get the creation dates of welcome-visitors
   put the milliseconds into firstDate
   repeat for each line wikiDomain in wikiDomains
      put fedray [wikiDomain]["created"] into creationDate
      if creationDate < firstDate then
         put creationDate into firstDate
      end if
   end repeat
   return firstDate
end federation_FetchFirstDate


--> Federation | ServerArray
-
command federation_UpdateServerPage serverName, pServerData
   if pServerData is empty then put federation_FetchServerData() into pServerData
   put _ConstructServerCurlyData (serverName, pServerData) into curlyData
   put "sites.fedwiki.org,roster.fedwiki.org,author.fedwiki.org" into forkDomains
   put serverName && "Server" into pageTitle
   federation_UpdateTemplate pageTitle, "server.fedwiki.org", curlyData, forkDomains
   put the result into pageArray
   --
   put pServerData [serverName] into serverArray
   federation_StoreServerArray serverName, serverArray
   --
   return pageArray
end federation_UpdateServerPage

function _ConstructServerCurlyData serverName, serverData
   -- just in case let's update
   serverData_UpdateServerInfo serverData, serverName
   put the result into summaryText
   --
   serverData_Deconstruct serverData, serverName, serverDomains, domainNum, serverPageNum, createdDate, ipAddress
   put the result into rosterText
   put serverData_GetAuthorNames (serverName, serverData) into authorNames
   --
   put serverName into curlyData ["all"]["serverName"]
   put _ServerMeta (domainNum, serverPageNum, ipAddress, createdDate) into curlyData ["id"]["da8cf69872f38050"] -- meta
   put rosterText into curlyData ["id"]["741a0fcdd3ff76b2"] -- roster
   put fedwiki_MarkdownIndex (serverDomains) into curlyData ["id"]["0458144c09a51968"] -- index
   put fedwiki_MarkdownIndex (authorNames) into curlyData ["id"]["3b90e7841cc695fa"] -- authors
   --
   return curlyData
end _ConstructServerCurlyData

function _ServerMeta domainNum, pageNum, ipAddress, pCreatedDate
   if pCreatedDate is empty then put "not known" into pCreatedDate
   put "Domains:" && domainNum into serverMeta
   put CR & "Pages:" && pageNum after serverMeta
   put CR & "Created:" && pCreatedDate after serverMeta
   put CR & "IP Address:" && ipAddress after serverMeta
   return serverMeta
end _ServerMeta


--> DomainArray
-
function domainLinkArray_FetchFromSitemaps domainArray, pCacheSitemaps
   -- from sitemaps
   put domainArray ["domain"] into fromDomain
   put domainArray ["pageArray"] into pageSlugArray
   repeat for each key fromSlug in pageSlugArray
      set the cursor to busy
      put fromDomain & slash & fromSlug into fromPage
      --
      put pageSlugArray [fromSlug] into pageArray
      put pageArray ["title"] into fromTitle
      put pageArray_ExtractLinkArray (pageArray) into pageLinkArray
      put pageLinkArray ["fork"] into forkArray
      put pageLinkArray ["reference"] into referenceArray
      put pageLinkArray ["internal"] into internalArray
      put pageLinkArray ["external"] into externalArray
      --
      put fromTitle into toTitle
      put fromSlug into toSlug
      repeat for each key itemNum in forkArray
         put forkArray [itemNum]["site"] into toDomain
         if cachedSitemapArray [toDomain] is not an array then
            -- load all sitemaps into cache so next time "domainLinkArray_FetchFromSitemaps()" is faster
            put fedwiki_FetchSitemapArray (toDomain, pCacheSitemaps) into forkSitemapArray
            put forkSitemapArray into cachedSitemapArray [toDomain]
         end if
         --
         _SetFromToArray domainLinkArray, fromDomain, fromTitle, fromSlug, toDomain, toTitle, toSlug, "fork"
      end repeat
      --
      repeat for each key indexNum in referenceArray
         put referenceArray [indexNum]["slug"] into toSlug
         put referenceArray [indexNum]["site"] into toDomain
         put referenceArray [indexNum]["title"] into toTitle
         --
         _SetFromToArray domainLinkArray, fromDomain, fromTitle, fromSlug, toDomain, toTitle, toSlug, "reference"
      end repeat
      --
      repeat for each key toTitle in internalArray
         put fedwiki_ConstructSlug (toTitle) into toSlug
         put pageSlugArray [toSlug] into toArray
         if toArray is an array then
            -- there is a local page
            put fromDomain into toDomain
         else
            -- find external page in fork domains
            put _FindInternalForkLink (toSlug, forkArray, cachedSitemapArray) into externalDomain
            if externalDomain is empty then
               put "neighborhood" into linkType
               put "neighborhood" into toDomain
            else
               put "internal" into linkType
               put externalDomain into toDomain
            end if
         end if
         _SetFromToArray domainLinkArray, fromDomain, fromTitle, fromSlug, toDomain, toTitle, toSlug, linkType
      end repeat
      --
      put "www" into toDomain
      repeat for each key indexNum in externalArray
         put externalArray [indexNum]["url"] into externalURL
         set the itemdelimiter to slash
         put item 3 of externalURL into toSlug
         set the itemdelimiter to "."
         if item 1 of toSlug = "www" then delete item 1 of toSlug
         
         put toSlug into toTitle
         _SetFromToArray domainLinkArray, fromDomain, fromTitle, fromSlug, toDomain, toTitle, toSlug, "external", externalURL
      end repeat
   end repeat
   return domainLinkArray
end domainLinkArray_FetchFromSitemaps

function domainArray_Construct wikiDomain, pCacheSitemaps
   set the cursor to watch
   put wikiDomain into domainArray ["domain"]
   --
   put fedwiki_FetchSitemapArray (wikiDomain, pCacheSitemaps) into sitemapArray
   if sitemapArray is empty then return empty
   repeat for each key indexNum in sitemapArray
      set the cursor to busy
      put sitemapArray [indexNum] into itemArray
      fedwiki_DeconstructSitemapArray itemArray, pageTitle, firstPara, pageSlug, mDate
      --
      put pageArray_Fetch (wikiDomain, pageSlug) into domainArray ["pageArray"][pageSlug]
      put pageSlug into domainArray ["pageTitle"][pageTitle]
   end repeat
   set the cursor to hand
   return domainArray
end domainArray_Construct


--> Working on
-
function federation_ConstructServerURL serverName
   put serverName && "Server" into pageTitle
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   put merge ("http://server.fedwiki.org/view/welcome-visitors/view/[[pageSlug]]") into serverURL
   return serverURL
end federation_ConstructServerURL

function _AuthorCurlyData authorName, pAuthorDomains
   -- put the script_ExternalCalls of sObject into externalCalls
   -- put fedwiki_HkeyMarkdownIndex (externalCalls) into curlyData ["id"]["46fefa6edbe8111f"]
   if pAuthorDomains is empty then
      put federation_FetchAuthorDomains (authorName) into pAuthorDomains
   end if
   
   -- fetch and update fedray
   put fedray_Fetch() into fedray
   put _FetchSitemapData (pAuthorDomains) into sitemapData
   _UpdateSitemaps fedray, pAuthorDomains, sitemapData
   put the result into pageTotal
   fedray_Store fedray
   
   -- set author domain roster
   put authorName & CR & CR & pAuthorDomains into rosterText
   put rosterText into curlyData ["id"]["46fefa6edbe8111f"]
   
   -- set author metadata
   put _AuthorStatText (authorName, pAuthorDomains, pageTotal, fedray) into curlyData ["id"]["988ad6e34d9ba4c8"]
   return curlyData
end _AuthorCurlyData

private function _FetchSitemapData wikiDomains
   -- probably more useful to simply use "load" and cache them
   repeat for each line wikiDomain in wikiDomains
      set the cursor to busy
      put fedwiki_FetchSitemapArray (wikiDomain, false) into sitemapData [wikiDomain]
   end repeat
   return sitemapData
end _FetchSitemapData

private command _UpdateSitemaps @fedray, wikiDomains, pSitemapData
   put 0 into pageTotal
   if pSitemapData is not an array then
      put _FetchSitemapData (wikiDomains) into pSitemapData
   end if
   --
   repeat for each line wikiDomain in wikiDomains
      put pSitemapData [wikiDomain] into sitemapArray
      fedray_UpdateDomain fedray, wikiDomain, false, sitemapArray
      put the result into pageNum
      add pageNum to pageTotal
   end repeat
   return pageTotal
end _UpdateSitemaps

function _AuthorStatText authorName, authorDomains, pageTotal, fedray
   put the number of lines of authorDomains into siteNum
   if siteNum = 1 then
      put "one site" into siteText
   else
      put siteNum && "sites" into siteText
   end if
   put federation_GetLastModified (authorDomains, fedray) into lastActive
   date_ConvertMilliseconds lastActive
   put federation_FetchFirstDate (authorDomains, fedray) into fedStartDate
   date_ConvertMilliseconds fedStartDate
   --
   put "[[authorName]] has [[siteText]], and has been writing in the federation since [[fedStartDate]].  He has created a total of [[pageTotal]] wiki-pages," into mTemplate
   put space & "and was last active in the federation on [[lastActive]]" after mTemplate
   -- put ", and created [[lastMonthNum]] new pages in [[lastMonth]]" after mTemplate
   put "." after mTemplate
   put merge (mTemplate) into authorStatText
   return authorStatText
end _AuthorStatText

private command _SetFromToArray @fromToArray, fromDomain, fromTitle, fromSlug, toDomain, toTitle, toSlug, linkType, externalURL  
   /*
   -- put toDomain & slash & toSlug into toPage
   put externalURL into domainLinkArray [fromDomain]["link"][fromSlug][toDomain]["link"][toSlug][linkType]
   put fromTitle into domainLinkArray [fromDomain]["title"]
   put toTitle into domainLinkArray [fromDomain]["link"][fromSlug][toDomain]["title"]
   */
   -- put externalURL into fromToArray ["nested"][fromDomain][fromSlug][toDomain][toSlug][linkType]
   if fromDomain is empty or toDomain is empty then breakpoint
   
   -- make node ids
   put kwote (fromDomain & slash & fromSlug) into fromNode
   put kwote (toDomain & slash & toSlug) into toNode
   
   -- make node clusters
   put fromTitle into fromToArray ["node"][fromDomain][fromSlug]["title"]
   put toTitle into fromToArray ["node"][toDomain][toSlug]["title"]
   if externalURL is not empty then
      put externalURL into fromToArray ["node"][toDomain][toSlug]["externalURL"]
   end if
   
   -- create link-type clusters
   put toNode into fromToArray ["link"][linkType][fromNode]
end _SetFromToArray

private command _SetDomainLinkArray @domainLinkArray, fromPage, toPage, linkType, externalURL  
   if toPage is empty then breakpoint
   set the itemdelimiter to slash
   put item 1 of fromPage into fromDomain
   put item 2 of fromPage into fromSlug
   put item 1 of toPage into toDomain
   put item 2 of toPage into toSlug
   --
   put externalURL into domainLinkArray ["links"][fromDomain][fromSlug][toDomain][toSlug][linkType]
   -- put toPage into domainLinkArray ["simple"][fromPage]
end _SetDomainLinkArray

private function _FindInternalForkLink pageSlug, forkArray, cachedSitemapArray
   repeat for each key itemNum in forkArray
      put forkArray [itemNum]["site"] into forkDomain
      put cachedSitemapArray [forkDomain] into forkSitemapArray
      --
      put fedwiki_SearchSitemapArray (pageSlug, forkSitemapArray) into indexNum      
      if indexNum > 0 then
         return forkDomain
      end if
   end repeat
   return empty
end _FindInternalForkLink


--> Dep
-
private function line_GetCommon index1, index2
   -- could use arrays
   set the wholematches to true
   put empty into commonIndex
   repeat for each line someLine in index1
      if someLine is among the lines of index2 then
         put someLine & return after commonIndex
      end if
   end repeat
   delete last char of commonIndex
   return commonIndex
end line_GetCommon
