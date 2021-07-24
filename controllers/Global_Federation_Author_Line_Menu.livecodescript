script "Global | Federation | Author | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Federation | Author | Line | Menu
type: controller
version: 0.2


--> Menu | Props
-
function _GetAuthorName displayView
   put item 1 of the selected_Path of displayView into authorName
   put text_InitialCaps (authorName) into authorName
   return authorName
end _GetAuthorName

function _GetSelectedDomain displayView
   put item 2 of the selected_Path of displayView into authorDomain
   return authorDomain
end _GetSelectedDomain

function _GetAuthorDomains displayView
   put the top_Array of displayView into authorData
   put keys (authorData) into authorName
   put authorData [authorName] into authorDomainArray
   put the keys of authorDomainArray into authorDomains
   url_SortDomainIndex authorDomains
   return authorDomains
end _GetAuthorDomains


--> Global | Federation | Author | Line | Menu
-
on menu_DisplayAuthor displayView
   put _GetAuthorName (displayView) into authorName
   display_Author authorName
end menu_DisplayAuthor

on menu_CreateQuickAuthorPage displayView
   put _GetAuthorName (displayView) into authorName
   put author_FetchUpdatedPageArray (authorName) into pageArray
   --
   author_StorePageArray pageArray
   author_Launch authorName
end menu_CreateQuickAuthorPage

on _
end _

on menu_LaunchDomain displayView
   put _GetSelectedDomain (displayView) into wikiDomain
   -- 
   fedwiki_Launch wikiDomain
end menu_LaunchDomain

on menu_LaunchFirstModified displayView
   get the selected_Path of displayView
   switch the number of items of it
      case 1
         put _GetAuthorDomains (displayView) into authorDomains
         put federation_SiteFirstDate (authorDomains) into mSeconds
         put date_MillisecondsToInternetDate (mSeconds) into siteCreationDate
         put siteCreationDate
         break
      case 2
         put item 1 of it into authorName
         put item 2 of it into authorDomain
         --put _GetSelectedDomain (displayView) into authorDomain
         -- put fedwiki_FetchSiteCreationDate (authorDomain) into mSeconds
         get fedwiki_FetchFirstCreatedSlugArray (authorDomain)
         put it ["creationDate"] into creationDate
         put it ["slug"] into slug
         --
         fedwiki_LaunchSlug authorDomain, slug
         --
         put date_MillisecondsToInternetDate (creationDate) & CR & slug
         break
   end switch
end menu_LaunchFirstModified

on _
end _

on submenu_Author
   return "Global | Author | Menu"
end submenu_Author

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


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

