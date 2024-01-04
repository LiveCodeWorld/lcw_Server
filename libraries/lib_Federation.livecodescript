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

--> Federation | Ward
-
function federation_RecentWithoutAtopiaDomains
   put atopia_FetchTreeWelcomeInfoArray() into atopiaFedray
   put ward_FetchRecentDomainArray() into wardsFedray
   difference wardsFedray with atopiaFedray
   put the keys of wardsFedray into recentWithoutAtopiaDomains
   --
   return recentWithoutAtopiaDomains
end federation_RecentWithoutAtopiaDomains

function federation_FetchMyRecentOther
   put atopia_FetchRosterDomains() into minusDomains
   put ward_ListRecentDomains() into domainNames
   line_DeleteIndex domainNames, minusDomains
   return domainNames
end federation_FetchMyRecentOther


--> Federation
-
function fedwiki_FetchRecentDomainPageArray authorDomains, pSincePeriod
   if pSincePeriod is empty then put "1 week" into pSincePeriod
   --
   put federation_LastModifiedDomains (authorDomains, pSincePeriod) into recentAuthorDomains
   --
   put 1000 * date_GetSinceSeconds (pSincePeriod) into sinceSeconds
   repeat for each line wikiDomain in recentAuthorDomains
      set the cursor to busy
      put fedwiki_FetchModifiedPageArray (wikiDomain, sinceSeconds) into modifiedPageArray
      put modifiedPageArray into editedPageArray [wikiDomain]
   end repeat
   return editedPageArray
end fedwiki_FetchRecentDomainPageArray

function federation_RecentStripped
   put federation_RecentWithoutAtopiaDomains() into domainNames
   federation_CheckDomainExists domainNames
   put the result into badNames
   return badNames
end federation_RecentStripped


--> Fedwiki | Sitemap | Recent
-
function fedwiki_FetchModifiedPageArray wikiDomain, pSincePeriod
   put fedwiki_FetchSitemapArray (wikiDomain) into sitemapArray
   put fedwiki_FilteredSitePageArray (sitemapArray, pSincePeriod) into sitePageArray
   return sitePageArray
end fedwiki_FetchModifiedPageArray

function fedwiki_FilteredSitePageArray sitemapArray, pSincePeriod
   switch
      case pSincePeriod is empty
         put fedwiki_ConstructSitePageArray (sitemapArray) into mPageArray
         break
      case pSincePeriod is a number
         put pSincePeriod into sinceSeconds
         put fedwiki_GetModifiedArray (sitemapArray, sinceSeconds) into mSitemapArray
         put fedwiki_ConstructSitePageArray (mSitemapArray) into mPageArray
         break
      case pSincePeriod is not a number
         put 1000 * date_GetSinceSeconds (pSincePeriod) into sinceSeconds
         put fedwiki_GetModifiedArray (sitemapArray, sinceSeconds) into mSitemapArray
         put fedwiki_ConstructSitePageArray (mSitemapArray) into mPageArray
         break
   end switch
   return mPageArray
end fedwiki_FilteredSitePageArray

function fedwiki_ConstructSitePageArray sitemapArray
   repeat for each key indexNum in sitemapArray
      put sitemapArray [indexNum] into indexArray
      put indexArray ["title"] into pageTitle
      delete variable indexArray ["title"]
      put indexArray into sitePageArray [pageTitle]
   end repeat
   return sitePageArray
end fedwiki_ConstructSitePageArray

function fedwiki_GetModifiedArray sitemapArray, sinceSeconds
   local modifiedArray
   put item 2 of the extents of sitemapArray into maxNum
   repeat with indexNum = 1 to maxNum
      put sitemapArray [indexNum] into sitemapPageArray
      put sitemapPageArray ["slug"] into pageSlug
      put sitemapPageArray ["date"] into lastUpdate
      if lastUpdate > sinceSeconds then
         put sitemapPageArray into modifiedArray [pageSlug]
      end if
   end repeat
   return modifiedArray
end fedwiki_GetModifiedArray

function federation_ConstructServerURL serverName
   put serverName && "Server" into pageTitle
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   put merge ("http://server.fedwiki.org/view/welcome-visitors/view/[[pageSlug]]") into serverURL
   return serverURL
end federation_ConstructServerURL


--> Federation | Time
-
function federation_LastModifiedDomains wikiDomains, sincePeriod
   local fedray
   if sincePeriod is empty then return wikiDomains
   
   put 1000 * date_GetSinceSeconds (sincePeriod) into sinceSeconds
   repeat for each line wikiDomain in wikiDomains
      set the cursor to busy
      put fedwiki_GetlastModified (wikiDomain) into lastModified
      if lastModified > sinceSeconds then
         put wikiDomain & CR after sinceDomains
      end if
   end repeat
   delete char -1 of sinceDomains
   url_SortDomainIndex sinceDomains
   return sinceDomains
end federation_LastModifiedDomains

function federation_SiteFirstDate wikiDomains, pFedray
   if pFedray is empty then put fedray_FetchModel() into pFedray
   put the milliseconds into firstDate
   repeat for each line wikiDomain in wikiDomains
      -- put fedwiki_FetchSiteCreationDate (wikiDomain) into creationDate
      put fedray_FetchSiteCreationDate (wikiDomain, pFedray) into creationDate
      --
      if creationDate < firstDate then
         put creationDate into firstDate
      end if
   end repeat
   return firstDate
end federation_SiteFirstDate

function federation_SiteTotalPageNum wikiDomains, fedray
   local totalPageNum
   repeat for each line wikiDomain in wikiDomains
      put fedray [wikiDomain]["pages"] into pageNum
      add pageNum to totalPageNum
   end repeat
   return totalPageNum
end federation_SiteTotalPageNum


--> Federation
-
function federation_GoodBadDomainArray fedDomains
   repeat for each line someDomain in fedDomains
      set the cursor to busy
      if fedwiki_WikiExists (someDomain) then
         put empty into domainArray ["good"][someDomain]
      else
         put empty into domainArray ["bad"][someDomain]
      end if
   end repeat
   return domainArray
end federation_GoodBadDomainArray


--> DomainArray
-
function domainLinkArray_FetchFromSitemaps domainArray
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
            put fedwiki_FetchSitemapArray (toDomain) into forkSitemapArray
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

function domainArray_Construct wikiDomain
   set the cursor to watch
   put wikiDomain into domainArray ["domain"]
   --
   put fedwiki_FetchSitemapArray (wikiDomain) into sitemapArray
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


--> Private
-
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
