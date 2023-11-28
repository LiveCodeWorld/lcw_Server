script "Global | NVM | Menu"
--> MetaData
-
license: GPLv3
name: Global | NVM | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   return the browser_View of tObject
end menu_Target

getprop menu_CheckTarget [browserView]
   return exists (browserView)
end menu_CheckTarget

getprop disabled_CreateNvmFolder
   put there is a folder "~/.nvm" into folderExists
   return folderExists
end disabled_CreateNvmFolder


--> Global | NVM | Menu
-
on menu_RemoveExistingNodeVersions browserView
   ttyd_Paste "brew uninstall --ignore-dependencies node", browserView
end menu_RemoveExistingNodeVersions

on menu_ForceRemoveNode browserView
   ttyd_Paste "brew uninstall --force node", browserView
end menu_ForceRemoveNode

private on _
end _

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

private on __
end __

on menu_InstallNodeVersion browserView
   nvm_InstallNode
end menu_InstallNodeVersion

on menu_CheckInstalledNodeVersion browserView
   nvm_ListNodeVersions
end menu_CheckInstalledNodeVersion

private on ___
end ___

on menu_ListJobs
   put shell ("jobs -l")
end menu_ListJobs

on menu_NvmHelp xtermView
   nvm_Help xtermView
end menu_NvmHelp

private on ____
end ____

on menu_NpmUpdate xtermView
   nvm_Update xtermView
end menu_NpmUpdate

on menu_NpmVersion xtermView
   ttyd_Execute "npm -v", xtermView
end menu_NpmVersion

private on _____
end _____

on menu_NvmBin
   put nvm_GetBin()
end menu_NvmBin

on menu_NvmNodeVerson
   put nvm_GetNodeVersion()
end menu_NvmNodeVerson

on submenu_Dev
   return menu_DevTitle ("Global | NVM | Menu")
end submenu_Dev
