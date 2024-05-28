script "lib_AtopiaAuthorCreate"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_AtopiaAuthorCreate
type: library
version: 0.1

/*Some help*/


--> Working on
-
function author_FetchUpdatedPageArray authorName, pSincePeriod, pAuthorTemplate
   if pAuthorTemplate is empty then
      put federation_FetchTemplatePageArray ("author.fedwiki.org") into pageArray
      pageArray_Rename pageArray, authorName
      pageArray_StripJournal pageArray
      pageArray_AddFork pageArray, "fedwiki.org,server.fedwiki.org"
   else
      set the itemdelimiter to slash
      put item 1 of pAuthorTemplate into wikiDomain
      put item 2 of pAuthorTemplate into pageSlug
      set the itemdelimiter to comma
      if pageSlug is empty then put fedwiki_ConstructSlug (authorName) into pageSlug
      put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   end if
   
   put author_ListFedrayDomains (authorName, pSincePeriod) into authorDomains
   --
   put pageArray_FindItemType ("reference", pageArray) into itemNum
   if itemNum > 0 then
      put author_ConstructQuickPara (authorName, authorDomains, fedray) into statParagraph
      put itemArray_ConstructReference (pageSlug, "author.fedwiki.org", statParagraph, authorName, "988ad6e34d9ba4c8") into refItemArray
      put refItemArray into pageArray ["story"][itemNum]
   end if
   --
   put authorName into curlyData ["all"]["AuthorName"]
   put word 1 of authorName into curlyData ["all"]["FirstName"]
   curly_MergeAll pageArray, curlyData
   --
   put authorName & CR & CR & authorDomains into rosterText
   pageArray_SetFirstItem pageArray, "roster", rosterText
   --  
   return pageArray
end author_FetchUpdatedPageArray

command author_UpdatePageArray @pageArray, authorName, authorDomains, sincePeriod
   set the cursor to watch
   --
   put fedwiki_FetchRecentDomainPageArray (authorDomains, sincePeriod) into editedPageArray
   put author_ConstructStatText (authorName, authorDomains, editedPageArray, sincePeriod) into authorStatText
   pageArray_SetItemText pageArray, "988ad6e34d9ba4c8", authorStatText
   --
   author_UpdateRoster pageArray, authorName, authorDomains
   author_UpdateActivity pageArray, authorName
   --
   return pageArray
end author_UpdatePageArray

function author_ConstructQuickPara authorName, authorDomains, fedray, pWhich
   put fedray_FetchPageTotal (authorDomains, fedray) into pageTotal
   put fedray_GetLastModified (authorDomains, fedray) into lastActive
   date_ConvertMilliseconds lastActive
   --
   switch pWhich
      case "para"
         put "[[{{AuthorName}}]] has __{{siteText}}__ and has created a total of __{{pageTotal}} wiki-pages__. {{FirstName}} was last active in [[the federation]] on {{lastActive}}." into statParagraph
         break
      default
         put "has {{siteText}} and has created a total of {{pageTotal}} wiki-pages. {{FirstName}} was last active in [[the federation]] on {{lastActive}}." into statParagraph
   end switch
   put _FetchAuthorStatParagraph (statParagraph, curlyArray, authorName, pageTotal, lastActive, authorDomains) into statParagraph
   --
   return statParagraph
end author_ConstructQuickPara

function _FetchAuthorStatParagraph statParagraph, curlyArray, authorName, pageTotal, lastActive, authorDomains, fedStartDate
   put the number of lines of authorDomains into siteNum
   if siteNum = 1 then
      put "one site" into siteText
   else
      put siteNum && "sites" into siteText
   end if
   --
   put authorName into curlyArray ["AuthorName"]
   put word 1 of authorName into curlyArray ["FirstName"]
   put pageTotal into curlyArray ["pageTotal"]
   put siteText into curlyArray ["siteText"]
   put lastActive into curlyArray ["lastActive"]
   put fedStartDate into curlyArray ["fedStartDate"]
   --
   curly_Merge statParagraph, curlyArray
   return statParagraph
end _FetchAuthorStatParagraph

function author_CurlyData authorName, pAuthorDomains, pSincePeriod
   -- slow
   put authorName into curlyData ["all"]["AuthorName"]
   --
   if pAuthorDomains is empty then
      put author_FetchModelDomains (authorName) into pAuthorDomains -- fedray model
   end if
   
   -- set author domain roster
   put authorName & CR & CR & pAuthorDomains into rosterText
   put rosterText into curlyData ["id"]["46fefa6edbe8111f"]
   
   -- set author metadata
   put fedwiki_FetchRecentDomainPageArray (pAuthorDomains, pSincePeriod) into editedPageArray
   put author_ConstructStatText (authorName, pAuthorDomains, editedPageArray, pSincePeriod) into statText -- very slow
   put statText into curlyData ["id"]["988ad6e34d9ba4c8"]
   return curlyData
end author_CurlyData

function author_ConstructStatText authorName, authorDomains, editedPageArray, pSincePeriod, pPageTotal
   local fedray
   set the cursor to watch
   if pPageTotal is empty then put fedray_FetchPageTotal (authorDomains) into pPageTotal
   
   switch
      case pSincePeriod is "1 weeks"
      case pSincePeriod is "1 week"
      case pSincePeriod is empty
         put "week" into curlyArray ["LastPeriod"]
         break
      default
         put pSincePeriod into curlyArray ["LastPeriod"]
   end switch
   
   put atopia_FetchEditedPageNum (editedPageArray) into periodPageNum
   put periodPageNum into curlyArray ["PeriodPageNum"]
   --
   --
   put fedray_GetLastModified (authorDomains, fedray) into lastActive
   date_ConvertMilliseconds lastActive
   put federation_SiteFirstDate (authorDomains, fedray) into fedStartDate
   date_ConvertMilliseconds fedStartDate
   --
   put atopia_FetchAuthorTemplateStatText () into statParagraph
   put _FetchAuthorStatParagraph (statParagraph, curlyArray, authorName, pageTotal, lastActive, authorDomains, fedStartDate) into statParagraph
   --
   return statParagraph
end author_ConstructStatText


--> Author | Create
-
command author_Create authorName, authorDomains, pSincePeriod
   put "author.fedwiki.org" into wikiDomain
   put fedwiki_ConstructSlug (authorName) into pageSlug
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   --
   if pageArray is empty then
      put federation_FetchTemplatePageArray (wikiDomain) into pageArray
      pageArray_Rename pageArray, authorName
      pageArray_StripJournal pageArray
      pageArray_AddFork pageArray, "fedwiki.org,server.fedwiki.org"
   end if
   
   put author_CurlyData (authorName, authorDomains, pSincePeriod) into curlyData
   curly_MergePageArray pageArray, curlyData
   --
   pageArray_Set wikiDomain, pageSlug, pageArray
   put the result into shellResult
   if shellResult is empty then
      return pageArray
   else
      return shellResult
   end if
end author_Create

command author_UpdateActivity @pageArray, authorName
   put "ROSTER" && authorName into activityText
   put CR&CR & "CONVERSATION" after activityText
   put CR & "SINCE 1 week" after activityText
   --
   pageArray_SetFirstItem pageArray, "activity", activityText
   put the result into itemNum
   return itemNum
end author_UpdateActivity

command author_UpdateRoster @pageArray, authorName, authorDomains
   put authorName & CR & CR & authorDomains into rosterText
   pageArray_SetFirstItem pageArray, "roster", rosterText
   put the result into itemNum
   return itemNum
end author_UpdateRoster

function atopia_FetchPodActivity rosterName, authorNames, authorNameData, pSincePeriod, pForkDomains
   
   if pSincePeriod is empty then put "1 week" into pSincePeriod
   if pForkDomains is empty then put "fedwiki.org,server.fedwiki.org,author.fedwiki.org" into pForkDomains
   put rosterName && "Activity" into newName
   
   put pageArray_GetTemplate ("author.fedwiki.org", "Pod Activity Template", newName, pForkDomains) into pageArray
   put atopia_FetchPodDomains (authorNames, authorNameData, pSincePeriod) into wikiDomains
   --
   replace comma with CR in authorNames
   repeat for each line authorName in authorNames
      put "- [[" & authorName & "]]" & CR after authorMarkdownList
   end repeat
   delete char -1 of authorMarkdownList
   --
   put pSincePeriod into curlyData ["all"]["SincePeriod"]
   put authorMarkdownList into curlyData ["all"]["AuthorList"]
   put rosterName into curlyData ["all"]["RosterName"]
   put wikiDomains into curlyData ["all"]["WikiDomains"]
   --
   -- put _ConstructActivityText (rosterName, pSincePeriod) into activityText
   put "ROSTER" && rosterName into activityText
   put CR&CR & "CONVERSATION" after activityText
   put CR & "SINCE" && sincePeriod after activityText
   --
   put "ac116b796b3f6355" into rosterItemID
   put activityText into curlyData ["id"][rosterItemID]
   --
   curly_MergePageArray pageArray, curlyData
   --
   return pageArray
end atopia_FetchPodActivity

command atopia_CreateAuthorSitesPage authorName, authorDomains, pSitesBit
   -- create a "David Bovill (sites)" page from the "Sites Template" of "author.fedwiki.org"
   
   if pSitesBit is empty then put "(sites)" into pSitesBit -- eg "recent sites"
   -- put atopia_ConstructAuthorSiteSlug (authorName, pSitesBit) into sitesPageSlug
   put atopia_ConstructAuthorSiteTitle (authorName, pSitesBit) into sitesPageTitle
   put fedwiki_ConstructSlug (sitesPageTitle) into sitesPageSlug
   put "author.fedwiki.org" into authorWikiDomain
   --
   put federation_FetchTemplatePageArray (authorWikiDomain, sitesPageTitle, "fedwiki.org,roster.fedwiki.org,sites.fedwiki.org", "Sites") into pageArray
   --
   author_SetSitesPageArray pageArray, authorName, authorDomains
   curly_ReplacePageArray pageArray, "AuthorName", authorName
   --
   pageArray_Set authorWikiDomain, sitesPageSlug, pageArray
   --
   return pageArray
end atopia_CreateAuthorSitesPage

function atopia_ConstructRosterLink authorName, pSitesBit
   put atopia_ConstructAuthorSiteSlug (authorName, pSitesBit) into authorSiteSlug
   put "ROSTER author.fedwiki.org/" & authorSiteSlug into rosterLink
   return rosterLink
end atopia_ConstructRosterLink


--> Atopia | Author | Stats
-
function atopia_FetchAuthorEditedPageArray authorName, sincePeriod
   put atopia_FetchAuthorDomains (authorName) into authorDomains
   put fedwiki_FetchRecentDomainPageArray (authorDomains, sincePeriod) into editedPageArray
   return editedPageArray
end atopia_FetchAuthorEditedPageArray

function atopia_FetchAuthorTemplateStatText
   put "988ad6e34d9ba4c8" into itemID
   put author_FetchAuthorTemplate() into templatePageArray
   put pageArray_GetItemText (templatePageArray, itemID) into mTemplate
   return mTemplate
end atopia_FetchAuthorTemplateStatText

command atopia_StoreAuthorTemplateStatText authorName, authorStatText, pSitesBit
   put atopia_FetchAuthorPageArray (authorName, pSitesBit) into pageArray
   pageArray_SetItemText pageArray, "988ad6e34d9ba4c8", authorStatText
   atopia_StoreAuthorPageArray authorName, pageArray, pSitesBit
   return pageArray
end atopia_StoreAuthorTemplateStatText

function atopia_FetchEditedPageNum editedPageArray
   put 0 into editedPageNum
   repeat for each key wikiDomain in editedPageArray
      put editedPageArray [wikiDomain] into wikiDomainPageArray
      put keys (wikiDomainPageArray) into pageSlugs
      put the number of lines of pageSlugs into domainPageNum
      add domainPageNum to editedPageNum
   end repeat
   return editedPageNum
end atopia_FetchEditedPageNum


--> Atopia | Author | Model
-
function atopia_FetchAuthorPageArray authorName, pSitesBit
   put atopia_ConstructAuthorSiteSlug (authorName, pSitesBit) into sitesPageSlug
   put pageArray_Fetch ("author.fedwiki.org", sitesPageSlug) into pageArray
   return pageArray
end atopia_FetchAuthorPageArray

command atopia_StoreAuthorPageArray authorName, pageArray, pSitesBit
   put atopia_ConstructAuthorSiteSlug (authorName, pSitesBit) into sitesPageSlug
   pageArray_Set "author.fedwiki.org", sitesPageSlug, pageArray
   return the result
end atopia_StoreAuthorPageArray
