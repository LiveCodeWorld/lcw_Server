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
command wiki_Start pBrowserView, pLog
   if exists (pBrowserView) then
      ## Does not work with Shell
      put "wiki --security_legacy > /dev/null 2>&1 < /dev/null" into wikiBit
      put wikiBit && "& sleep 1; jobs -l" into someShell
      ttyd_Execute someShell, pBrowserView
      --
      -- [1]+ 49160 Done(127)               wiki --security_legacy > /dev/null 2>&1 < /dev/null
      -- put lineOffset (wikiBit, shellResult) into lineNum
      -- put word 2 of line lineNum of shellResult into pid
   else
      set the defaultfolder to "~"
      put "/Users/david/.nvm/versions/node/v21.0.0/bin/wiki" into wikiBinFile 
      put merge ("/usr/bin/nohup [[wikiBinFile]] --security_legacy") into someShell
      if pLog is true then
         put " > nohup.out 2> error.log &" after someShell
      else
         put " > /dev/null 2>&1 &" after someShell
      end if
      --
      put shell (someShell) into shellResult
      return "~/nohup.out"
   end if
end wiki_Start

function wiki_ProcessIds
   put shell ("ps aux | grep 'wiki --security_legacy'") into shellResult
   put lineOffset ("grep wiki --security_legacy", shellResult) into lineNum
   delete line lineNum of shellResult
   --
   repeat for each line sLine in shellResult
      put word 2 of sLine into pid
      put pid & comma after pids
   end repeat
   delete char -1 of pids
   return pids
end wiki_ProcessIds

command wiki_Start pBrowserView
   breakpoint
   set the cursor to watch
   open process wiki for update
   
   ## Federated Wiki server listening on 3000 in mode: development
   read from process wiki until "Federated Wiki server listening on 3000 in mode: development"
   put it into wikiInfoToParse
   put "http://localhost:3000" into wikiURL
   
   ## Display
   if exists (pBrowserView) then
      set the browser_Url of pBrowserView to wikiURL
   end if
   return wikiURL
end wiki_Start

command wiki_Stop
   if the platform = "MacOS" then
      put wiki_ProcessIds() into pIDs
      repeat for each item pID in pIDs
         kill process pID
      end repeat
      -- kill process wiki
   else
      close process wiki
   end if
end wiki_Stop


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

command xterm_Start browserView
   put "ttyd -p 8080 -W zsh > /dev/null 2>&1 < /dev/null & sleep 1; pgrep ttyd" into someShell
   
   set the cursor to watch
   put shell (someShell) into shellResult
   put word 1 of shellResult into pid
   --
   
   put "http://localhost:8080" into xtermURL
   return xtermURL
end xterm_Start

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
