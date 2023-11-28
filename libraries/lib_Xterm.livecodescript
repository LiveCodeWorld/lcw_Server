script "lib_Xterm"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Xterm
type: library
version: 0.1

/*Some help*/

--> Variables
-
local LocalArray


--> Working on
-
command display_Xterm pXtermBrowser, pStackStyle, pStackRect
   put "View|Xterm" into viewName
   put "Xterm Browser" into pStackLabel
   put xterm_URL() into someURL
   --
   switch
      case pXtermBrowser is true
         display_ViewTemplate viewName
         put the result into xtermBrowser
         set the browser_Url of xtermBrowser to someURL
         break
      case exists (pXtermBrowser)
         put pXtermBrowser into xtermBrowser
         if pStackLabel is not empty then set the stack_Label of xtermBrowser to pStackLabel
         set the browser_Url of xtermBrowser to someURL
         break
      default
         if pStackStyle is empty then put "toplevel" into pStackStyle
         --
         display_View viewName, someURL, pStackLabel, pStackRect, "browser_URL", pStackStyle
         put the result into xtermBrowser
         display_SetMenu xtermBrowser, "Xterm", "title_Menu"
   end switch
   return xtermBrowser
end display_Xterm


--> Working on
-
getprop xterm_Result [jsScript]
   put the browser_View of the target into browserWidget
   set the javascriptHandlers of browserWidget to "xterm_GetJavascriptResult"
   --
   do jsScript in browserWidget
   put the result into sResult -- sometimes does not work
   put LocalArray ["sResult"] into sResult
   --
   put sResult = "visible" into isVisible
   return isVisible
end xterm_Result

on xterm_GetJavascriptResult sResult
   put sResult into LocalArray ["sResult"]
   return sResult
end xterm_GetJavascriptResult


--> Ttyd
-
command ttyd_Execute someShell, browserView
   put ttypd_PasteJS (someShell) into jsTemplate
   put CR & "document.querySelector('textarea.xterm-helper-textarea').dispatchEvent(new KeyboardEvent('keypress', {charCode: 13}))" after jsTemplate
   put merge (jsTemplate) into someJS
   --
   set the browser_Javascript of browserView to someJS
   return someJS
end ttyd_Execute

command ttyd_Paste someShell, browserView
   put ttypd_PasteJS (someShell) into someJS
   set the browser_Javascript of browserView to someJS
   return someJS
end ttyd_Paste

function ttypd_PasteJS someShell
   put "term.paste('[[someShell]]');" into jsTemplate
   put merge (jsTemplate) into someJS
   return someJS
end ttypd_PasteJS


--> Xterm
-
function xterm_FindView pLineNum
   if pLineNum is not a number then put 1 into pLineNum
   --
   put xterm_ListBrowsers() into xtermViews
   put line pLineNum of xtermViews into xtermView
   return xtermView
end xterm_FindView

function xterm_ListBrowsers pLabel
   return display_List ("View|Xterm", pLabel)
end xterm_ListBrowsers

function xterm_IsRunning
   return xterm_ProcessID() is not empty
end xterm_IsRunning

function xterm_ProcessID
   put word 1 of shell ("pgrep ttyd") into pid
   return pid
end xterm_ProcessID

function xterm_URL
   return "http://localhost:8080"
end xterm_URL

command xterm_Start
   put "ttyd -p 8080 -W zsh > /dev/null 2>&1 < /dev/null & sleep 1; pgrep ttyd" into someShell
   
   set the cursor to watch
   put shell (someShell) into shellResult
   put word 1 of shellResult into pid
   --
   return pid
end xterm_Start

command xterm_Stop pAsk
   put word 1 of shell ("pgrep ttyd") into pid
   if pAsk is not false then
      put lcw_Ask ("Kill found process...", pid) into pid
   end if
   put shell ("kill" && pid) into killResult
   
   /*
   put LocalArray ["XtermProcessName"] into pName
   if pName is not empty then
      close process pName
      delete variable LocalArray ["XtermProcessName"]
   end if
   */
   -- process_CloseAll
   return killResult
end xterm_Stop

function ttyd_ThemeJson sColour
   put "green" into sColour
   put "'background': '[[sColour]]'" into themeJSON
   replace "'" with quote in themeJSON
   return themeJSON
end ttyd_ThemeJson
