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

--> Ttyd
-
command ttyd_Execute someShell, browserView
   put ttypd_PasteJS (someShell) into jsTemplate
   put CR & "document.querySelector('textarea.xterm-helper-textarea').dispatchEvent(new KeyboardEvent('keypress', {charCode: 13}))" after jsTemplate
   put merge (jsTemplate) into someJS
   --
   set the browser_Javascript of browserView to someJS
end ttyd_Execute

command ttyd_Paste someShell, browserView
   put ttypd_PasteJS (someShell) into someJS
   set the browser_Javascript of browserView to someJS
end ttyd_Paste

function ttypd_PasteJS someShell
   put "term.paste('[[someShell]]');" into jsTemplate
   put merge (jsTemplate) into someJS
   return someJS
end ttypd_PasteJS

--> Xterm
-
function xterm_ProcessID
   put word 1 of shell ("pgrep ttyd") into pid
   return pid
end xterm_ProcessID

command display_Xterm pXtermBrowser
   put xterm_URL() into xtermURL
   display_Browser xtermURL, pXtermBrowser, pShowTools, pStackStyle
   put the result into pXtermBrowser
   return pXtermBrowser
end display_Xterm

command xterm_Start
   put "ttyd -p 8080 -W zsh > /dev/null 2>&1 < /dev/null & sleep 1; pgrep ttyd" into someShell
   
   set the cursor to watch
   put shell (someShell) into shellResult
   put word 1 of shellResult into pid
   --
   return pid
end xterm_Start

function xterm_URL
   return "http://localhost:8080"
end xterm_URL

function ttyd_ThemeJson sColour
   put "green" into sColour
   put "'background': '[[sColour]]'" into themeJSON
   replace "'" with quote in themeJSON
   return themeJSON
end ttyd_ThemeJson

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
