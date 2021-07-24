script "Global | Atopia | Home | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Atopia | Home | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Events
-
on doubleUp_Home displayView, pageSlug
   put atopia_FetchDefaultPageArray (pageSlug) into pageArray
   --
   display_PageArray pageArray
end doubleUp_Home

on drop_Home displayView, dData
   -- http://roster.fedwiki.org/view/welcome-visitors/view/skunk-activity/michael.offersandwants.me/loveworker-project-scraps--introduction
   set the itemdelimiter to slash
   put dData ["text"] into droppedURL
   --
   put item 3 of droppedURL into wikiDomain
   if the number of items of droppedURL = 4 AND droppedURL ends with ".html" then
      -- it's a link to a wiki-page
      get item 4 of droppedURL
      set the itemdelimiter to "."
      put item 1 of it into pageSlug
      --
      put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
      --
      -- display_PageArray pageArray
      atopia_StoreDefaultPageArray pageArray
   else
      -- it's a lineUP
      -- put fedwiki_GetLineUpData (droppedURL) into lineUpData
      lcw_AnswerWarning "Cannot process lineups. Drop a wiki-html page-link?", displayView
   end if
end drop_Home


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into displayView
   --
   return displayView
end menu_Target

getprop menu_CheckTarget [mTarget]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget


--> Global | Atopia | Home | Menu
-
on menu_DisplayDefaultWikiPages
   put atopia_ListDefaultPages() into wikiPages
   --
   display_Data wikiPages, "Default Pages", "Atopia Home", empty, "system"
   put the result into displayView
   display_SetInteractions displayView, "Atopia | Home", "doubleUp_Home"
   set the drop_Command of displayView to "drop_Home"
   set the drop_Target of displayView to the long id of me
   --
   return displayView
end menu_DisplayDefaultWikiPages

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_StoreFedwikiOrgDefaultPages indexView
   put "Copy a few pages from fedwiki.org to the defaul page location, so that they are available to all sites?" into someQuestion
   lcw_Answer someQuestion, indexView
   breakpoint
   --
   put "fedwiki.org" into wikiDomain
   put "changes-to-this-site,federation-activity,fedwiki-tools,filtered-federation-activity,the-federation" into pageSlugs
   repeat for each item pageSlug in pageSlugs
      put pageArray_Fetch (wikiDomain, pageSlug) into pageArray
      atopia_StoreDefaultPageArray pageArray
   end repeat
end menu_StoreFedwikiOrgDefaultPages

on _
end _

on menu_RevigniterHelp
   launch url "https://revigniter.com/userGuide/toc.html"
end menu_RevigniterHelp
