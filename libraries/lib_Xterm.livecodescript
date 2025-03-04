﻿script "lib_Xterm"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Xterm
type: library
version: 0.1

/*
A library to display an Xterm browser in Livecode.
*/

--> Variables
-
local LocalArray


--> Working on
-
command ttyd_Message sShell, pHow
   put the long id of the target into xTermBrowser
   if pHow is "execute" then
      ttyd_Execute sShell, xTermBrowser
   else
      ttyd_Paste sShell, xTermBrowser
   end if
end ttyd_Message

command ttyd_Execute someShell, pXtermView
   if exists (pXtermView) is false then
      breakpoint
      return empty
   end if
   
   put ttypd_PasteJS (someShell) into jsTemplate
   put "; " & "document.querySelector('textarea.xterm-helper-textarea').dispatchEvent(new KeyboardEvent('keypress', {charCode: 13}))" after jsTemplate
   put merge (jsTemplate) into someJS
   --
   set the browser_Javascript of pXtermView to someJS
   return someJS
end ttyd_Execute


--> Ttyd
-
command ttyd_Paste someShell, pXtermView
   if exists (pXtermView) is false then
      breakpoint
      return empty
   end if
   
   put ttypd_PasteJS (someShell) into someJS
   set the browser_Javascript of pXtermView to someJS
   --
   put the short id of pXtermView into wID
   put the stack_Name of pXtermView into sName
   if exists (widget id wID of stack sName) then
      -- focus on control id wID of stack sName -- # bug
      -- put the focusedobject
   end if
   return someJS
end ttyd_Paste

function ttypd_PasteJS sShell
   put "term.paste(" & kwote (sShell) & ");" into someJS
   return someJS
end ttypd_PasteJS


--> Display | Xterm
-
command display_XtermAtFolder sFolder, pShell, pXtermView
   # Execute cd views to assets folder
   put "cd" && kwote (sFolder, "'") into cdShell
   --
   put ";" && pShell after cdShell
   display_Xterm cdShell, pXtermView, "execute"
   put the result into xTermBrowser
   --
   return xTermBrowser
   
   set the defaultfolder to sFolder -- not useful
   if pShell is not empty then
      -- wait 30 ticks
      ttyd_Paste pShell, xTermBrowser
   end if
   return xTermBrowser
end display_XtermAtFolder

command display_Xterm pShellCommand, pXtermBrowser, pHow, pStackStyle 
   # Start if not running
   if xterm_IsRunning() is false then
      xterm_Start
      wait 60 ticks
   end if
   
   # Display
   --
   if exists (pXtermBrowser) then
      put xterm_URL() into xTermURL
      get the kind of pXtermBrowser
      if it = "com.livecode.widget.browser" then
         set the url of pXtermBrowser to xTermURL
      else
         set the browser_URL of pXtermBrowser to xTermURL
      end if
      put pXtermBrowser into xTermBrowser
   else
      put empty into stackLabel
      display_XtermView stackLabel, pXtermBrowser, pStackStyle
      put the result into xTermBrowser
   end if
   
   if pShellCommand is not empty then
      send "ttyd_Message pShellCommand,pHow" to xTermBrowser in 60 ticks
   end if
   return xTermBrowser
end display_Xterm

command display_XtermView pStackLabel, pXtermBrowser, pStackStyle
   if pStackStyle is empty then put "toplevel" into pStackStyle
   put "Xterm Browser" into pStackLabel
   put xterm_URL() into someURL
   put "url" into urlProp
   --
   display_ModuleInstance "View|Xterm", someURL, pStackLabel, pXtermBrowser, urlProp, pStackStyle
   put the result into xTermBrowser
   
   # Set menus
   display_SetMenu xTermBrowser, "Xterm"
   return xTermBrowser
end display_XtermView

on xterm_GetJavascriptResult sResult
   put sResult into LocalArray ["sResult"]
   return sResult
end xterm_GetJavascriptResult


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
