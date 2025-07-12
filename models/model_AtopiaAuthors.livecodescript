script "model_AtopiaAuthors"
--> MetaData
-
copyright: David bovill
license: GPLv3
name: model_AtopiaAuthors
type: model
version: 0.2


/*
At the moment this model is slow and painful. We store data locally as arrays.

Aim to move to online json stores in wiki, though due to complexity we migh well need a (graph) database.
*/


--> Working on
-
function author_ListFedrayDomains authorName, pSincePeriod
   put fedray_FetchModel() into fedray
   put author_ConstructFromFedray (fedray, pSincePeriod) into fedrayAuthorData
   put fedrayAuthorData [authorName] into authorArray
   put keys (authorArray) into authorDomains
   url_SortDomainIndex authorDomains
   return authorDomains
end author_ListFedrayDomains

function author_FetchPageArray authorName
   put fedwiki_ConstructSlug (authorName) into pageSlug
   put pageArray_Fetch ("author.fedwiki.club", pageSlug) into pageArray
   return pageArray
end author_FetchPageArray

command author_StorePageArray pageArray
   put pageArray ["title"] into authorName
   put fedwiki_ConstructSlug (authorName) into pageSlug
   pageArray_Set "author.fedwiki.club", pageSlug, pageArray
   return the result
end author_StorePageArray

function atopia_AuthorPageExists authorName
   put fedwiki_ConstructSlug (authorName) into pageSlug
   put fedwiki_PageExists ("author.fedwiki.club", pageSlug) into someBoolean
   return someBoolean
end atopia_AuthorPageExists

command author_CreateModelFromFedray pFedray
   put author_ConstructFromFedray (pFedray) into authorArray
   author_StoreModelArray authorArray
   return authorArray
end author_CreateModelFromFedray

function author_ConstructFromFedray pFedray, pSincePeriod
   if pFedray is empty then put fedray_FetchModel() into pFedray
   if pSincePeriod is not empty then
      put fedray_FilterSince (pFedray, pSincePeriod) into pFedray
   end if
   put fedray_ConstructAuthorData (pFedray) into authorArray
   fedray_TranslateAuthorArray authorArray
   return authorArray
end author_ConstructFromFedray

command fedray_TranslateAuthorArray @authorArray, pDictionaryArray
   put author_FetchDictionaryArray() into pDictionaryArray
   --
   repeat for each key oldName in authorArray
      put pDictionaryArray [oldName] into newName
      switch newName
         case empty
         case oldName
            next repeat
         default
            put authorArray [oldName] into authorArray [newName]
            delete variable authorArray [oldName]
      end switch   
   end repeat
   /*
   repeat for each key oldName in pDictionaryArray
      put pDictionaryArray [oldName] into newName
      --
      put authorArray [oldName] into oldArray
      put authorArray [newName] into newArray
      union newArray with oldArray recursively
      --
      put newArray into authorArray [newName]
      delete variable authorArray [oldName]
   end repeat
   */
end fedray_TranslateAuthorArray

command author_SetSitesPageArray @pageArray, rosterTitle, authorDomains
   put pageArray_FindItemType ("roster", pageArray) into firstRosterItemNum
   if firstRosterItemNum > 0 then
      put rosterTitle & CR & CR & authorDomains into rosterText
      put rosterText into pageArray ["story"][firstRosterItemNum]["text"]
   end if
   
   -- could search for a header rather than use fixed itemID
   put pageArray_FindItemID ("94aeb407a09d831b", pageArray) into listItemNum
   if listItemNum > 0 then
      put markdown_LinkedBullets (authorDomains) into markDownList
      put "# List of sites" & CR&CR & markDownList into pageArray ["story"][listItemNum]["text"]
   end if
end author_SetSitesPageArray


--> Author | Display
-
command author_Launch authorName, pSitesBit
   put atopia_ConstructAuthorSiteTitle (authorName, pSitesBit) into authorPageTitle
   fedwiki_Launch "author.fedwiki.club", authorPageTitle
end author_Launch


--> Author | Create
-
command author_StoreRosterLink authorName, pSitesBit
   if pSitesBit is empty then put "(sites)" into pSitesBit
   put atopia_ConstructRosterLink (authorName, pSitesBit) into rosterLink
   author_StoreRoster authorName, rosterLink
   return the result
end author_StoreRosterLink

function author_FetchRecentSites authorName
   -- from roster
   put author_FetchRosterSites (authorName, "(recent sites)") into thisWeeksAuthorDomains
   return thisWeeksAuthorDomains
end author_FetchRecentSites

command author_StoreRecentSites authorName, authorDomains
   author_StoreRosterAndList authorName, authorDomains, "(recent sites)"
   put the result into pageArray
   return pageArray
end author_StoreRecentSites

command author_StoreRosterAndList authorName, authorDomains, pSitesBit
   put author_ConstructRecentPageArray (authorName, authorDomains, pSitesBit) into pageArray
   author_StorePageArray authorName, pageArray, pSitesBit
   return pageArray
end author_StoreRosterAndList

function author_ConstructRecentPageArray authorName, authorDomains, pSitesBit
   if pSitesBit is empty then put "(recent sites)" into pSitesBit
   put author_FetchPageArray (authorName, pSitesBit) into pageArray
   --
   author_SetSitesPageArray pageArray, authorName, authorDomains
   pageArray_StripJournal pageArray
   pageArray_AddFork pageArray, "fedwiki.club,roster.fedwiki.club,sites.fedwiki.club"
   --
   return pageArray
end author_ConstructRecentPageArray

function author_FetchPageArray authorName, pSitesBit
   put "author.fedwiki.club" into wikiDomain
   put atopia_ConstructAuthorSiteSlug (authorName, pSitesBit) into pageSlug
   --
   put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
   return pageArray
end author_FetchPageArray

function author_FetchAuthorTemplate
   put pageArray_Fetch ("author.fedwiki.club", "author-template") into pageArray
   return pageArray
end author_FetchAuthorTemplate

command author_StorePageArray authorName, pageArray, pSitesBit
   put "author.fedwiki.club" into wikiDomain
   put atopia_ConstructAuthorSiteSlug (authorName, pSitesBit) into pageSlug
   --
   pageArray_Set wikiDomain, pageSlug, pageArray
   --
   return pageSlug
end author_StorePageArray


--> Author | Remote | Model
-
/*
A different format to atopiaAuthorData. Here we store information from any site in the federation.
*/

function author_FetchModelDomains authorName, pAuthorArray
   -- see also "atopia_FetchAuthorDomains()"
   if pAuthorArray is not an array then
      put author_FetchModelArray() into pAuthorArray
   end if
   get pAuthorArray [authorName]
   put keys (it) into domainNames
   url_SortDomainIndex domainNames
   return domainNames
end author_FetchModelDomains

function author_FetchModelArray
   put author_FetchModelData() into authorData
   put authorData ["authorData"] into authorArray
   return authorArray
end author_FetchModelArray

command author_StoreModelArray authorArray
   get author_FetchModelData()
   put authorArray into authorData ["authorData"]
   put it ["authorDictionary"] into authorData ["authorDictionary"]
   author_StoreModelData authorData
   --
   put the result into putError -- error 401 Unauthorized
   return putError
end author_StoreModelArray

function author_FetchDictionaryArray
   put author_FetchModelData() into federationAuthorData
   put federationAuthorData ["authorDictionary"] into authorDictionary
   return authorDictionary
end author_FetchDictionaryArray

command author_StoreDictionaryArray authorDictionary
   put author_FetchModelData() into authorData
   put authorDictionary into authorData ["authorDictionary"]
   author_StoreModelData authorData
   --
   put the result into putError -- error 401 Unauthorized
   return putError
end author_StoreDictionaryArray

function author_FetchModelData
   put "author-model" into modelName -- should move to "federation-author-model"
   --
   put fedwiki_FetchPluginData (modelName, "roster.fedwiki.club") into authorData
   return authorData
end author_FetchModelData

command author_StoreModelData authorData
   put "author-model" into modelName -- should move to "federation-author-model"
   put atopia_GetJsonSecret() into apiKey
   --
   put json_FromArray (authorData) into someJSON
   fedwiki_PutPluginJSON someJSON, modelName, "roster.fedwiki.club", apiKey
   put the result into putError -- error 401 Unauthorized
   return putError
end author_StoreModelData


--> Author | Roster | Model
-
/*
Don't use this (yet) for data as we are moving around the roster and using REFERENCE links, and do not have a clear place to store the roster.
Use the json based model used by "author_FetchModelDomains()" instead for now
*/

function author_FetchRosterSites authorName, pSitesBit
   -- use "author_FetchModelDomains" for now
   put author_FetchRoster (authorName, pSitesBit) into rosterText
   if line 1 of rosterText = authorName then delete line 1 of rosterText
   return word 1 to -1 of rosterText
end author_FetchRosterSites

command author_StoreRosterSites authorName, authorDomains, pSitesBit
   put authorName & CR & CR & authorDomains into rosterText
   author_StoreRoster authorName, rosterText, pSitesBit
   return the result
end author_StoreRosterSites

function author_FetchRoster authorName, pSitesBit
   put "author.fedwiki.club" into wikiDomain
   put atopia_ConstructAuthorSiteSlug (authorName, pSitesBit) into pageSlug
   put roster_Fetch (wikiDomain, pageSlug) into rosterText
   return rosterText
end author_FetchRoster

command author_StoreRoster authorName, rosterText, pSitesBit
   put "author.fedwiki.club" into wikiDomain
   put atopia_ConstructAuthorSiteSlug (authorName, pSitesBit) into pageSlug
   roster_Store wikiDomain, pageSlug, rosterText
   put the result into pageArray
   return pageArray
end author_StoreRoster

function atopia_ConstructAuthorSiteSlug authorName, pSitesBit
   put atopia_ConstructAuthorSiteTitle (authorName, pSitesBit) into pageTitle
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   return pageSlug
end atopia_ConstructAuthorSiteSlug

function atopia_ConstructAuthorSiteTitle authorName, pSitesBit
   put authorName into pageTitle
   if pSitesBit is not empty then put space & pSitesBit after pageTitle
   return pageTitle
end atopia_ConstructAuthorSiteTitle


--> Working on | Atopia | Author | Pod
-
function atopia_FetchPodDomains authorNames, authorNameData, pSincePeriod
   if pSincePeriod is empty then put "1 week" into pSincePeriod
   --
   put fedray_GetAuthorDomains (authorNames, authorNameData) into authorDomains
   put federation_LastModifiedDomains (authorDomains, pSincePeriod) into filteredAuthorDomains -- slow due to fetching sitemaps
   --
   return filteredAuthorDomains
end atopia_FetchPodDomains

command atopia_CreatePodActivityPage podName, authorNames, wikiDomain, ownershipArray, pSincePeriod, pForkDomains
   set the cursor to watch
   --
   put atopia_ConstructAuthorNameArray (ownershipArray) into authorNameData
   --
   put atopia_FetchPodActivity (podName, authorNames, authorNameData, pSincePeriod, pForkDomains) into pageArray
   --
   put fedwiki_ConstructSlug (podName && "Activity") into pageSlug
   pageArray_Set wikiDomain, pageSlug, pageArray
   --
   put the result into shellResult
   return shellResult
end atopia_CreatePodActivityPage


--> Atopia | Author | Remote | Model
-
/*
A different format to federationAuthorData. Here we store a lot of detail about sites on our own server.
*/

function atopia_FetchRecentAuthorDomains authorNames, pPeriod
   if pPeriod is empty then put "1 week" into pPeriod
   --
   put atopia_FetchAuthorNameData() into authorNameData
   put atopia_FetchPodDomains (authorNames, authorNameData, pPeriod) into filteredAuthorDomains
   --
   return filteredAuthorDomains
end atopia_FetchRecentAuthorDomains

function atopia_FetchAuthorDomains authorNames
   -- see also "author_FetchModelDomains()"
   
   put atopia_FetchAuthorNameData() into authorNameData
   put fedray_GetAuthorDomains (authorNames, authorNameData) into authorDomains
   return authorDomains
end atopia_FetchAuthorDomains

function atopia_FetchAuthorNameData
   put "atopia-author-model" into modelName
   --
   put fedwiki_FetchPluginData (modelName, "roster.fedwiki.club") into atopiaAuthorNameData
   return atopiaAuthorNameData
end atopia_FetchAuthorNameData

command atopia_StoreAuthorNameData atopiaAuthorNameData
   put "atopia-author-model" into modelName
   put atopia_GetJsonSecret() into apiKey
   --
   put json_FromArray (atopiaAuthorNameData) into someJSON
   fedwiki_PutPluginJSON someJSON, modelName, "roster.fedwiki.club", apiKey
   put the result into putError -- error 401 Unauthorized
   return putError
end atopia_StoreAuthorNameData


--> Atopia | Author | Local | Model
-
function atopia_GetLocalAuthorNameData
   put atopia_GetLocalEmailOwnerData() into ownershipArray
   put atopia_ConstructAuthorNameArray (ownershipArray) into authorNameData
   return authorNameData
end atopia_GetLocalAuthorNameData


--> Atopia | Author
-
function atopia_FetchAuthorArray authorName
   put fedwiki_ConstructSlug (authorName) into pageSlug
   put atopia_FetchAuthorJSON (pageSlug) into someJSON
   put json_ToArray (someJSON) into someArray
   return someArray
end atopia_FetchAuthorArray

command atopia_StoreAuthorArray authorName, someArray
   put fedwiki_ConstructSlug (authorName) into pageSlug
   put json_FromArray (someArray) into someJSON
   --
   atopia_StoreAuthorJSON pageSlug, someJSON
   put the result into putError
   return putError
end atopia_StoreAuthorArray

function atopia_FetchAuthorJSON pageSlug
   put fedwiki_FetchPluginJSON (pageSlug, "author.fedwiki.club") into someJSON
   return someJSON
end atopia_FetchAuthorJSON

command atopia_StoreAuthorJSON pageSlug, someJSON
   put atopia_GetJsonSecret() into apiKey
   fedwiki_PutPluginJSON someJSON, pageSlug, "author.fedwiki.club", apiKey
   put the result into putError
   switch putError
      case "error Previous request not completed"
         break
      case empty
         break
      default
         put putError
   end switch
   return putError
end atopia_StoreAuthorJSON


--> Deps
-
function line_GetCommon index1, index2
   split index1 with CR and tab
   split index2 with CR and tab
   -- split index1 with CR as set
   -- split index2 with CR as set
   intersect index1 with index2
   put keys (index1) into commonIndex
   sort lines of commonIndex
   return commonIndex
   
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
