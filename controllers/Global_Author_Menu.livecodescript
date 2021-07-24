script "Global | Author | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Author | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put tObject into  LocalArray ["tObject"]
   if word 1 of tObject is not "widget" then pass menu_Target
   
   put the display_View of tObject into displayView
   put the kind of tObject into tKind
   switch tKind
      case "com.livecode.widget.headerBar"
         put the title_Text of displayView into authorName
         break
      case "com.livecode.widget.treeView"
         put item 1 of the selected_Path of displayView into authorName
         put text_InitialCaps (authorName) into authorName
         break
      default
         put tKind
   end switch
   --
   put atopia_AuthorPageExists (authorName) into LocalArray ["authorExists"]
   --
   return authorName
end menu_Target

getprop menu_CheckTarget [authorName]
   put LocalArray ["tObject"] into tObject
   put word 1 of tObject is "widget" into isWidget
   if isWidget is false then return false
   put the display_View of tObject into displayView
   return exists (displayView)
end menu_CheckTarget

getprop disabled_CreateAuthor [authorName]
   put LocalArray ["authorExists"] into authorExists
   return authorExists
end disabled_CreateAuthor

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


--> Global | Author | Menu
-
on menu_LaunchAuthorPage authorName
   author_Launch authorName
end menu_LaunchAuthorPage

on menu_Refresh authorName
   display_Author authorName
end menu_Refresh

on _
end _

on menu_CreateAuthor authorName
   put lcw_Ask ("Create or update author page for:", authorName) into authorName
   --
   author_Create authorName
   author_Launch authorName
end menu_CreateAuthor

on menu_CreateQuickAuthorPage authorName
   put author_UpdatePageArray (authorName) into pageArray
   author_StorePageArray pageArray
   author_Launch authorName
end menu_CreateQuickAuthorPage

on menu_UpdateAuthorParagraphs authorName
   put author_FetchModelDomains (authorName) into authorDomains
   --
   put author_FetchPageArray (authorName) into pageArray
   if pageArray is empty then
      lcw_AnswerWarning "Author page does nto exist create one first?", displayView
   end if
   
   put author_FetchAuthorTemplate() into templatePageArray
   pageArray_DeleteItem templatePageArray, 1
   pageArray_Combine pageArray, templatePageArray
   --
   author_UpdatePageArray pageArray, authorName, authorDomains
   curly_ReplacePageArray pageArray, "AuthorName", authorName
   --
   display_PageArray pageArray
   -- author_StorePageArray authorName, pageArray
   -- author_Launch authorName
end menu_UpdateAuthorParagraphs

on _
end _

on insert_AuthorRoster
   return "Author | Roster | Menu"
end insert_AuthorRoster

on _
end _

on menu_CreateAuthorSitesPage authorName
   put author_FetchModelDomains (authorName) into authorDomains
   --
   atopia_CreateAuthorSitesPage authorName, authorDomains
   author_StoreRosterLink authorName, "sites"
   --
   author_Launch authorName, "sites"
end menu_CreateAuthorSitesPage

on _
end _

on menu_UpdateAboutAuthorParagraph authorName
   put author_FetchModelDomains (authorName) into authorDomains
   --
   put lcw_Ask ("Since when?", "1 week") into sincePeriod
   --
   put atopia_FetchAuthorPageArray (authorName) into pageArray
   author_UpdatePageArray pageArray, authorName, authorDomains, sincePeriod
   atopia_StoreAuthorPageArray authorName, pageArray
   --
   author_Launch authorName
end menu_UpdateAboutAuthorParagraph

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Author | Roster | Menu
-
on menu_SetAuthorRoster authorName
   put author_FetchModelDomains (authorName) into authorDomains
   --
   author_StoreRosterSites authorName, authorDomains
   -- 
   author_Launch authorName
end menu_SetAuthorRoster

on menu_SetSitesRoster authorName
   --
   author_StoreRosterLink authorName, "sites"
   -- 
   author_Launch authorName, "(sites)"
end menu_SetSitesRoster

on menu_SetRecentRoster authorName
   put author_ListRecentSites (authorName) into thisWeeksAuthorDomains
   author_StoreRecentSites authorName, thisWeeksAuthorDomains
   --
   author_StoreRosterLink authorName, "recent sites"
   -- 
   author_Launch authorName, "(recent sites)"
end menu_SetRecentRoster


--> Dev | Menu
-
on menu_TestQuickText authorName
   put fedray_FetchModel() into fedray
   put author_FetchModelDomains (authorName) into authorDomains
   put author_ConstructQuickPara (authorName, authorDomains, fedray) into statParagraph
   --
   display_Text statParagraph
end menu_TestQuickText

on menu_CheckCreationDates authorName
   put author_FetchModelDomains (authorName) into authorDomains
   --
   put fedray_FetchModel() into fedray
   if fedray is not an array then
      lcw_AnswerWarning "Fedray was empty. Resetting internet..."
      resetAll
   end if
   
   repeat for each line wikiDomain in authorDomains
      set the cursor to busy
      put fedwiki_FetchSiteCreationDate (wikiDomain) into storedDate -- can be very slow
      put fedray_FetchSiteCreationDate (wikiDomain, fedray) into realDate
      --
      if storedDate is not realDate then
         put wikiDomain & CR after badDomains
         fedray_StoreSiteCreationDate wikiDomain, realDate, fedray
         put the result into fedray
      end if
   end repeat
   delete char -1 of badDomains
   --
   if badDomains is empty then
      lcw_Answer "All good :)", displayView
   else
      put badDomains
      set the displayed_Data of displayView to fedray
      lcw_Answer "Fixed these domains...", displayView
   end if
end menu_CheckCreationDates


--> Private
-
