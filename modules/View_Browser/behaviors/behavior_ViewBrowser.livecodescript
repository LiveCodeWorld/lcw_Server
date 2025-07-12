script "behavior_ViewBrowser"
--> MetaData
-
license: GPLv3
name: behavior_ViewBrowser
type: behavior
version: 0.2

local LocalArray

--> Props
-
/*
setprop page_Title [remoteDomain] pageSlug
   if remoteDomain is empty then
      put wiki_InternalLinkJavascript (pageSlug) into someJavascript
   else
      put wiki_RemoteLinkJavascript (pageSlug, remoteDomain) into someJavascript
   end if
   set the browser_Javascript of me to someJavascript
   put the result into doResult
   return doResult
end page_Title

setprop ghost_PageArray pageArray
   put json_FromArray (pageArray) into pageJSON
   set the browser_Javascript of me to _ConstructJavascript (pageJSON)
   return the result
end ghost_PageArray

setprop ghost_PageJson pageJSON
   set the browser_Javascript of me to _ConstructJavascript (pageJSON)
   return the result
end ghost_PageJson

getprop wiki_Domain
   put the browser_URL of me into someURL
   set the itemdelimiter to slash
   put item 3 of someURL into wikiDomain
   set the itemdelimiter to "."
   if item 1 of wikiDomain = "www" then delete item 1 of wikiDomain
   return wikiDomain
end wiki_Domain

getprop footer_Visible
   put _FooterGroup() into footerGroup
   put the visible of footerGroup into someBoolean
   return someBoolean
end footer_Visible

setprop footer_Visible someBoolean
   put _FooterGroup() into footerGroup
   put the rect of me into oRect
   --
   lock screen
   set the browser_WikiFooterVisible of me to (not someBoolean)
   set the visible of footerGroup to someBoolean
   LayoutControl oRect
   unlock screen
end footer_Visible

setprop wiki_Domain domainOrURL
   set the itemdelimiter to slash
   switch
      case item 1 of domainOrURL = "https:"
      case item 1 of domainOrURL = "http:"
         -- http://arodic.github.io/p/jellyfish/
         put domainOrURL into someURL
         break
      default
         put "http://" & domainOrURL into someURL
   end switch
   set the browser_URL of me to someURL
end wiki_Domain
*/

--> Events | Init
-
-- on preOpenControl
   init_Module
   pass preOpenControl
end preOpenControl

-- on preOpenControl
-- not reliably sent?
view_Init
pass preOpenControl
end preOpenControl

getprop view_BehaviorStackNames
   put the uOPN ["view_BehaviorStackNames"] of me into mBehaviorStackNames
   replace comma with CR in mBehaviorStackNames
   return mBehaviorStackNames
end view_BehaviorStackNames

setprop view_BehaviorStackNames mBehaviorStackNames
   replace comma with CR in mBehaviorStackNames
   set the uOPN ["view_BehaviorStackNames"] of me to mBehaviorStackNames
   
   # Send-in-time to prevent behavior setting behavior
   send "init_Module" to me in 2 ticks -- for safety place "init_Module" on card script
end view_BehaviorStackNames

getprop view_BehaviorStackNames
   put the uOPN ["view_BehaviorStackNames"] of me into sNames
   return sNames
end view_BehaviorStackNames

setprop view_BehaviorStackNames sNames
   set the uOPN ["view_BehaviorStackNames"] of me to sNames
   --
   view_Init
end view_BehaviorStackNames


--> Events
-
on mouseUp
   local tActionName
   put the mouseAction of me into tActionName
   switch tActionName
      case "back"
         go back
         break
      case "add"
         set the opaque of me to true
         set the backgroundcolor of me to white
         break
      default
         put tActionName
   end switch
end mouseUp

on resizeControl
   LayoutControl
end resizeControl

command LayoutControl pRect
   if pRect is empty then put the rect of me into pRect

   if the menubar of the defaultstack is not empty then
      put the menu_Group of me into mGroup
      if exists(mGroup) then
         put the height of mGroup into sHeight
         subtract sHeight from item 2 of pRect
      end if
   end if
   set the rect of me to pRect
end LayoutControl


--> Props
-
getprop displayed_Data
   put the browser_URL of me into someURL
   if someURL is empty then
      return the browser_HtmlText of me
   else
      return someURL
   end if
end displayed_Data

setprop displayed_Data urlOrHtml
   set the itemdelimiter to ":"
   put item 1 of urlOrHtml is among the items of "http:https" into isUrl
   --
   if isUrl then
      set the browser_URL of me to urlOrHtml
   else
      set the browser_HtmlText of me to urlOrHtml
   end if
   return isUrl
end displayed_Data


--> Browser | Props
-
getprop browser_Element
   return LocalArray ["elementHtml"]
end browser_Element

on browser_InitResult elementHtml
   -- put "svg" into elementHtml
   --
   delete variable LocalArray ["elementHtml"]
   set the javascriptHandlers of me to "browser_JavascriptResult"
   --
   put merge ("var r=document.getElementById('[[elementHtml]]').outerHTML;liveCode.browser_JavascriptResult(r)") into sJavascript
   replace "'" with quote in sJavascript
   do sJavascript in me
end browser_InitResult

on browser_JavascriptResult elementHtml
   put elementHtml into LocalArray ["elementHtml"]
end browser_JavascriptResult

setprop browser_Element elementID
   browser_InitResult "svg"
   return the result
end browser_Element

setprop browser_Javascript someJavascript
   -- put "wiki.doInternalLink('Federateed Wiki')" into someJavascript
   
   do someJavascript in me
   put the result into doResult
   return doResult
end browser_Javascript

getprop browser_Snapshot
   export snapshot from me to pictVariable as PNG
   return pictVariable
end browser_Snapshot

getprop browser_JavascriptHandlers
   put the javascriptHandlers of me into handlerList
   return handlerList
end browser_JavascriptHandlers

setprop browser_JavascriptHandlers handlerList
   set the javascriptHandlers of me to handlerList
   return the result
end browser_JavascriptHandlers

getprop browser_File
   put the url of me into someURL
   if char 1 to 7 of someURL = "file://" then
      put char 8 to -1 of someURL into someFile
      return someFile
   else
      return empty
   end if
end browser_File

setprop browser_File sFile
   put "file://" & sFile into sURL
   set the url of me to sURL
   return sURL
end browser_File

getprop browser_URL  
   put the url of me into someURL
   return someURL
end browser_URL

setprop browser_URL someURL
   set the url of me to someURL
   return the long id of me
end browser_URL

getprop browser_HtmlText
   put the htmltext of me into someHTML
   return someHTML
end browser_HtmlText

setprop browser_HtmlText someHTML
   set the htmltext of me to someHTML
   return the long id of me
end browser_HtmlText


--> Objects
-
getprop view_Object
   return the long id of me
end view_Object

getprop browser_View
   return the long id of me
end browser_View
