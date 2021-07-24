script "lib_DisplayWikiAuthors"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_DisplayWikiAuthors
type: library
version: 0.1

/*Some help*/


--> Working on
-
command display_Author authorName, pAuthorArray
   if pAuthorArray is empty then
      put author_FetchModelArray() into authorData
      put authorData [authorName] into pAuthorArray
   end if
   --
   display_Data pAuthorArray, authorName, "Federation Author"
   put the result into displayView
   display_SetInteractions displayView, "Author", "mDoubleUp_Author"
   return displayView
end display_Author


--> Display | Wiki | Authors
-
command display_AuthorData pAuthorData, pTitle, pLabel
   if pAuthorData is empty then put author_FetchModelArray() into pAuthorData
   if pTitle is empty then put "Wiki Authors" into pTitle
   if pLabel is empty then put "Federation" into pLabel
   --
   display_Data pAuthorData, pTitle, pLabel
   put the result into displayView
   display_SetInteractions displayView, "Atopia | Author", mDoubleUp
   return displayView
end display_AuthorData


--> Display | Local | Authors
-
command display_LocalAtopiaOwnerDomains userEmail
   put atopia_GetLocalDomainsFromEmail (userEmail) into domainNames
   url_SortDomainIndex domainNames
   --
   put userEmail into aTitle
   put "mDoubleUp_Domain" into mDoubleUp
   --
   put "Global | Atopia | DomainOwners | Menu" into mTitle
   put "Global | Atopia | DomainOwners | Line | Menu" into mLineTitle
   --
   _DisplayAtopia domainNames, aTitle, mTitle, mLineTitle, mDoubleUp
   put the result into indexView
   return indexView
end display_LocalAtopiaOwnerDomains

command display_LocalAuthorNameData
   put "Wiki Authors" into aTitle
   put atopia_GetLocalAuthorNameData() into authorNameArray
   --
   put "mDoubleUp_Authors" into mDoubleUp
   put "Global | Atopia | Author | Menu" into mTitle
   put "Global | Atopia | Author | Line | Menu" into mLineTitle
   --
   _DisplayAtopia authorNameArray, aTitle, mTitle, mLineTitle, mDoubleUp
   put the result into indexView
   return indexView
end display_LocalAuthorNameData

command display_LocalAtopiaAuthors
   put atopia_ListLocalDomainOwners() into atopiaDomains
   --
   put "mDoubleUp_ListOwnerDomains" into mDoubleUp
   --
   put "Domain Owners" into aTitle
   put "Global | Atopia | DomainOwners | Menu" into mTitle
   put "Global | Atopia | DomainOwners | Line | Menu" into mLineTitle
   --
   _DisplayAtopia atopiaDomains, aTitle, mTitle, mLineTitle, mDoubleUp
   --
   return indexView
end display_LocalAtopiaAuthors


--> Private
-
private command _DisplayAtopia domainNames, aTitle, pTitleMenu, pLineMenu, pDoubleUp, pDisplayView
   if pTitleMenu is empty then put "Global | Atopia | Menu" into pTitleMenu
   if pLineMenu is empty then put "Global | Atopia | Line | Menu" into pLineMenu
   if pDoubleUp is empty then put "mDoubleUp_Domain" into pDoubleUp
   --
   display_Data domainNames, aTitle, "Atopia", pDisplayView
   put the result into indexView
   display_SetIndexMenus indexView, pTitleMenu, pLineMenu, pDoubleUp
   --
   return indexView
end _DisplayAtopia


