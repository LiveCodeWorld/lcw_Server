script "Global | Xterm | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Xterm | Menu
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
   put xterm_ProcessID() into LocalArray ["TtydProcessID"]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop checked_Xterm [browserView]
   return LocalArray ["TtydProcessID"] is not empty
end checked_Xterm

getprop disabled_KillTtydProcess
   return LocalArray ["TtydProcessID"] is empty
end disabled_KillTtydProcess

getprop disabled_CreateNvmFolder
   put there is a folder "~/.nvm" into folderExists
   return folderExists
end disabled_CreateNvmFolder


--> Global | Xterm | Menu
-
on menu_RemoveExistingNodeVersions browserView
   ttyd_Paste "brew uninstall --ignore-dependencies node", browserView
end menu_RemoveExistingNodeVersions

on menu_ForceRemoveNode browserView
   ttyd_Paste "brew uninstall --force node", browserView
end menu_ForceRemoveNode

on menu_InstallNvm browserView
   ttyd_Paste "brew install nvm", browserView
end menu_InstallNvm

on menu_CreateNvmFolder browserView
   ttyd_Paste "mkdir ~/.nvm", browserView
end menu_CreateNvmFolder

on menu_EditBashProfile browserView
   -- ~/.bash_profile ( or ~/.zshrc for macOS Catalina or newer versions)
   ttyd_Paste "nano -w ~/.zshrc", browserView
   --
   get the focusedObject
   -- get "focus on" && browserView
   -- put it
end menu_EditBashProfile

on menu_LoadShellEnvironment browserView
   ttyd_Paste "source ~/.zshrc", browserView
end menu_LoadShellEnvironment

on menu_ListNodeVersions browserView
   ttyd_Execute "nvm ls-remote", browserView
end menu_ListNodeVersions

on menu_InstallNodeVersion browserView
   -- nvm install node     ## Installing Latest version 
   -- nvm install 18       ## Installing Node.js 18.X version
   put lcw_Ask ("Install a version of node...", "latest") into nodeVersion
   switch
      case nodeVersion is a number
         put "nvm install" && nodeVersion into someShell
         ttyd_Paste someShell, browserView
         break
      case nodeVersion is "latest"
         ttyd_Paste "nvm install node", browserView
         break
      default
         lcw_AnswerWarning "Version needs to be a number!"
   end switch
end menu_InstallNodeVersion

on menu_CheckInstalledNodeVersion browserView
   ttyd_Execute "nvm ls", browserView
end menu_CheckInstalledNodeVersion

on menu_InstallWiki browserView
   ttyd_Paste "npm install -g wiki", browserView
end menu_InstallWiki

on menu_StartWiki browserView
   wiki_Start browserView
end menu_StartWiki

on menu_StopWiki browserView
   wiki_Start browserView
end menu_StopWiki

on menu_ListJobs
   put shell ("jobs -l")
end menu_ListJobs

on menu_NvmHelp browserView
   ttyd_Execute "nvm help", browserView
   --
   if the shiftKey is "Down" then
      launch url "https://tecadmin.net/install-nvm-macos-with-homebrew/"
   end if
end menu_NvmHelp

private on __
end __

on menu_NpmVersion browserView
   ttyd_Execute "npm -v", browserView
end menu_NpmVersion

on menu_NpmUpdate browserView
   put lcw_Ask (someQuestion, "npm install -g npm@10.2.1") into someShell
   ttyd_Paste someShell, browserView
end menu_NpmUpdate

on menu_Clear browserView
   ttyd_Execute "clear", browserView
end menu_Clear

private on _
end _

on menu_HtmlText browserView
   get the browser_HtmlText of browserView
end menu_HtmlText

on menu_Xterm browserView
   if LocalArray ["TtydProcessID"] is empty then
      xterm_Start displayView
      put the result into xtermURL
      set the browser_URL of browserView to xtermURL
   else
      xterm_Stop false
      set the browser_URL of browserView to empty
   end if
end menu_Xterm

on menu_KillTtydProcess browserView
   xterm_Stop true
   menu_Refresh browserView
end menu_KillTtydProcess

on menu_Refresh browserView
   -- put "http://localhost:8080" into xtermURL
   put the browser_URL of browserView into xtermURL
   set the browser_URL of browserView to xtermURL
end menu_Refresh
