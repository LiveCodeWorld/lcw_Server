script "Global | Atopia | Author | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Atopia | Author | Line | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Init
-
getprop menu_Target [tObject]
   put the display_View of tObject into displayView
   --
   _SetInfo displayView, authorName, wikiDomain
   put the result into sPath
   --
   put sPath into LocalArray ["sPath"]
   put authorName into LocalArray ["authorName"]
   put wikiDomain into LocalArray ["wikiDomain"]
   put atopia_AuthorPageExists (authorName) into LocalArray ["authorExists"]
   --
   return displayView
end menu_Target

getprop disabled_LaunchDomain [displayView]
   put LocalArray ["sPath"] into sPath
   switch the number of items of sPath
      case 1
         return true
      default
         return false
   end switch
end disabled_LaunchDomain

private command _SetInfo displayView, @authorName, @wikiDomain
   put the selected_Path of displayView into sPath
   if sPath is empty then
      put empty into authorName
      put empty into wikiDomain
      return empty
   end if
   
   put item 1 of sPath into authorName
   put item 3 of sPath into wikiDomain
   return sPath
end _SetInfo

getprop disabled_CreateAuthor [displayView]
   if LocalArray ["authorExists"] then
      return "delete"
   else
      return false
   end if
end disabled_CreateAuthor

getprop disabled_RecreateAuthor [displayView]
   if LocalArray ["authorExists"] then
      return false
   else
      return "delete"
   end if
end disabled_RecreateAuthor

getprop disabled_UpdateAuthorRoster [displayView]
   if LocalArray ["authorExists"] then
      return false
   else
      return "delete"
   end if
end disabled_UpdateAuthorRoster

private function _GetAuthorDomains displayView
   put the top_Array of displayView into authorNameArray
   --
   put authorNameArray ["domains"] into authorDomainArray
   put keys (authorDomainArray) into authorDomains
   --
   url_SortDomainIndex authorDomains
   return authorDomains
end _GetAuthorDomains

private command _CreateAuthor displayView
   put the top_Line of displayView into authorName
   put _GetAuthorDomains (displayView) into authorDomains
   --
   put lcw_Ask ("Create or update author page for:", authorName) into authorName
   --
   author_Create authorName, authorDomains
   --
   fedwiki_Launch "author.fedwiki.org", authorName 
end _CreateAuthor


--> Global | Atopia | Author | Line | Menu
-
on menu_LaunchAuthorPage displayView
   put LocalArray ["authorName"] into authorName
   fedwiki_Launch "author.fedwiki.org", authorName
end menu_LaunchAuthorPage

on menu_LaunchDomain displayView
   put LocalArray ["wikiDomain"] into wikiDomain
   fedwiki_Launch wikiDomain
end menu_LaunchDomain

on menu_DisplayAuthor displayView
   put LocalArray ["authorName"] into authorName
   display_Author authorName
end menu_DisplayAuthor

on _
end _

on menu_IsInFederation displayView
   put the selected_Path of displayView into somePath
   switch the number of items of somePath
      case 3
         put item 3 of somePath into wikiDomain
         --
         put fedray_ListAllDomainNames() into fedrayDomains
         put wikiDomain is among the lines of fedrayDomains
         break
      default
         put somePath
         -- breakpoint
   end switch
end menu_IsInFederation

on _
end _

on menu_LaunchInvoice displayView
   put the top_Line of displayView into authorName
   --
   voz_LaunchInvoice authorName, "Media Garden"
end menu_LaunchInvoice

on menu_CreateInvoice displayView
   put the top_Line of displayView into authorName
   put _GetAuthorDomains (displayView) into authorDomains
   --
   put lcw_Ask ("Since when?", "1 week") into sincePeriod
   --
   voz_CreateInvoice authorName, "Media Garden", sincePeriod
   --
   voz_LaunchInvoice authorName, "Media Garden"
end menu_CreateInvoice

on menu_SetInvoicePageSection displayView
   put the top_Line of displayView into authorName
   put "Media Garden" into toName
   --
   put voz_FetchInvoice (authorName, toName) into pageArray
   --
   put voz_FetchEditedPageMarkDown (authorName) into markdownSection
   pageArray_SetItemText pageArray, "e9a8b033dfc5cfa4", markdownSection
   --
   voz_StoreInvoice authorName, toName, pageArray
   --
   voz_LaunchInvoice authorName, "Media Garden"
end menu_SetInvoicePageSection

on menu_AzureEntites
   put lcw_Ask ("Choose a domain to index..", "david.bovill.me") into wikiDomain
   display_AzureEntities wikiDomain
end menu_AzureEntites

on _
end _

on menu_UpdateAboutAuthorParagraph displayView
   put the top_Line of displayView into authorName
   put _GetAuthorDomains (displayView) into authorDomains
   --
   put lcw_Ask ("Since when?", "1 week") into sincePeriod
   --
   set the cursor to watch
   --
   put fedwiki_FetchRecentDomainPageArray (authorDomains, sincePeriod) into editedPageArray
   --
   put author_ConstructStatText (authorName, authorDomains, editedPageArray, sincePeriod) into authorStatText
   --
   atopia_StoreAuthorTemplateStatText authorName, authorStatText
   --
end menu_UpdateAboutAuthorParagraph

on menu_UpdateRecentAuthorRoster displayView
   put the top_Line of displayView into authorName
   --
   put author_ListRecentSites (authorName) into thisWeeksAuthorDomains
   author_StoreRecentSites authorName, thisWeeksAuthorDomains
   --
   author_Launch authorName, "(recent sites)"
end menu_UpdateRecentAuthorRoster

on menu_CreateRecentAuthorSitesPage displayView
   put the top_Line of displayView into authorName
   put _GetAuthorDomains (displayView) into authorDomains
   --
   put lcw_Ask ("Since when?", "1 week") into sincePeriod
   put federation_LastModifiedDomains (authorDomains, sincePeriod) into recentAuthorDomains
   --
   put "(recent sites)" into siteBit
   author_StoreRosterLink authorName, siteBit
   atopia_CreateAuthorSitesPage authorName, recentAuthorDomains, siteBit
   put the result into pageArray
   put pageArray ["title"] into newPageTitle
   --
   author_Launch authorName, "(recent sites)"
end menu_CreateRecentAuthorSitesPage

on _
end _

on menu_CreateAuthor displayView
   _CreateAuthor displayView
end menu_CreateAuthor

on menu_RecreateAuthor displayView
   _CreateAuthor displayView
end menu_RecreateAuthor

on menu_CreateAuthorSitesPage displayView
   put the top_Line of displayView into authorName
   put _GetAuthorDomains (displayView) into authorDomains
   --
   atopia_CreateAuthorSitesPage authorName, authorDomains
   put the result into pageArray
   put pageArray ["title"] into newPageTitle
   --
   fedwiki_Launch "author.fedwiki.org", newPageTitle 
end menu_CreateAuthorSitesPage

on _
end _

on menu_SetFullAuthorRoster displayView
   put the top_Line of displayView into authorName
   put _GetAuthorDomains (displayView) into authorDomains
   --
   put lcw_Ask ("Update roster page of author:", authorName) into authorName
   --
   author_StoreRosterLink authorName
   author_StoreRosterAndList authorName, authorDomains, "(sites)"
   --
   fedwiki_Launch "author.fedwiki.org", authorName 
end menu_SetFullAuthorRoster

on _
end _

on menu_DisplayServerAuthorArray displayView
   put the top_Line of displayView into authorName
   --
   put atopia_FetchAuthorArray (authorName) into authorArray
   --
   display_Data authorArray, "atopia_FetchAuthorArray()"
end menu_DisplayServerAuthorArray

on menu_StoreServerAuthorArray displayView
   put the top_Line of displayView into authorName
   put the top_Array of displayView into authorNameArray
   --
   atopia_StoreAuthorArray authorName, authorNameArray
   --
   put the result
end menu_StoreServerAuthorArray

on _
end _

on menu_TrashDomain displayView
   set the cursor to watch
   _SetInfo displayView, authorName, wikiDomain
   put the result into somePath
   --
   if wikiDomain is empty then
      lcw_AnswerWarning "No domain selected!", displayView
   end if
   
   put atopia_CheckDomain (wikiDomain) into someError
   if someError is empty then
      lcw_AnswerWarning "Domain is not faulty!", displayView
   else
      atopia_TrashDomain wikiDomain
      --
      if the result is empty then
         lcw_AnswerWarning "Domain is good. Nothing changed", displayView
      else
         put the selected_LineNum of displayView into lineNum
         set the deleted_Line of displayView to somePath
      end if
   end if
end menu_TrashDomain

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_RecentDomains displayView
   put the top_Line of displayView into authorName
   put the top_Array of displayView into authorNameArray
   --
   put authorNameArray ["domains"] into authorDomainArray
   put keys (authorDomainArray) into authorDomains
   url_SortDomainIndex authorDomains
   --
   put lcw_Ask ("Since when?", "1 weeks") into sincePeriod
   put federation_LastModifiedDomains (authorDomains, sincePeriod) into wikiDomains
   --
   display_Data wikiDomains
end menu_RecentDomains
