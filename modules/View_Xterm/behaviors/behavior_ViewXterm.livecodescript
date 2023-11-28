script "behavior_ViewXterm"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewXterm
type: behavior
version: 0.1


--> Events
-
on resizeControl
   LayoutControl
end resizeControl

command LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   set the rect of me to pRect
end LayoutControl


--> Working on
-

--> Browser | Props
-
setprop browser_Javascript someJavascript
   put _BrowserWidget() into browserWidget
   do someJavascript in browserWidget
   put the result into doResult
   return doResult
end browser_Javascript

getprop browser_JavascriptHandlers
   put the javascriptHandlers of _BrowserWidget() into handlerList
   return handlerList
end browser_JavascriptHandlers

setprop browser_JavascriptHandlers handlerList
   put _BrowserWidget() into browserWidget
   set the javascriptHandlers of browserWidget to handlerList
   return the result
end browser_JavascriptHandlers

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
private function _BrowserWidget
   return the long id of me
end _BrowserWidget

getprop view_Object
   return the long id of me
end view_Object

getprop browser_View
   return the long id of me
end browser_View
