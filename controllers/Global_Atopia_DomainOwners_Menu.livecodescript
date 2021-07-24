script "Global | Atopia | DomainOwners | Menu"
--> MetaData
-
license: GPLv3
name: Global | Atopia | DomainOwners | Menu
type: controller
version: 0.1


--> Menu | Init
-
getprop disabled_ReindexNoEmail [indexView]
   get the title_Text of indexView
   if it is "No Email" then
      return false
   else
      return "delete"
   end if
end disabled_ReindexNoEmail


--> Global | Atopia | DomainOwners | Menu
-
on menu_DisplayLocalAuthorNameArray
   display_LocalAuthorNameData
end menu_DisplayLocalAuthorNameArray

on menu_DisplayAtopiaAuthorIndex
   display_AtopiaAuthorIndex
end menu_DisplayAtopiaAuthorIndex

on menu_ReindexNoEmail indexView
   put the displayed_Index of indexView into noEmailDomains
   
   -- a bug with duplicates here?
   line_SetUnique noEmailDomains
   url_SortDomainIndex noEmailDomains
   set the displayed_Index of indexView to noEmailDomains
   --
   put atopia_GetLocalEmailOwnerData() into ownershipArray
   put atopia_FetchConfigArray() into configArray
   repeat for each line wikiDomain in noEmailDomains
      atopia_UpdateOwnershipArray wikiDomain
      display_AtopiaOwnerDomains "No Email"
   end repeat
   --
   display_AtopiaOwnerDomains "david.bovill@gmail.com"
   display_AtopiaOwnerDomains "david@mediagarden.org"
end menu_ReindexNoEmail

on _
end _

on insert_Menu
   return "Global | Atopia | Tree | Menu"
end insert_Menu


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
   -- atopia_StorePersonArray "people-template", wDomainArray
   -- atopia_StorePersonArray "david-bovill", wDomainArray
end menu_StoreAuthorArray
