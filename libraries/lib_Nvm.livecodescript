script "lib_Nvm"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Nvm
type: library
version: 0.1

/*Some help*/


--> Working on
-
function afds
   put "~/.nvm/nvm.sh"
end afds


--> Nvm
-
function npm_List nodeModuleName
   -- put npm_List ("wiki-server")
   put "source ~/.nvm/nvm.sh; npm list -gp" && nodeModuleName into tCommand
   put shell (tCommand) into tResult
   return tResult
end npm_List

function nvm_GetNodeVersion
   return shell ("source ~/.zshrc; nvm current")
end nvm_GetNodeVersion

command nvm_InstallNode
   -- nvm install node     ## Installing Latest version 
   -- nvm install 18       ## Installing Node.js 18.X version
   put lcw_Ask ("Install a version of node...", "latest") into nodeVersion
   switch
      case nodeVersion is a number
         put "nvm install" && nodeVersion into someShell
         ttyd_Paste someShell, xtermView
         break
      case nodeVersion is "latest"
         ttyd_Paste "nvm install node", xtermView
         break
      default
         lcw_AnswerWarning "Version needs to be a number!"
   end switch
end nvm_InstallNode

command nvm_ListNodeVersions xtermView
   ttyd_Execute "nvm ls", xtermView
end nvm_ListNodeVersions

command nvm_Update xtermView
   put lcw_Ask (someQuestion, "npm install -g npm@10.2.1") into someShell
   ttyd_Paste someShell, xtermView
   return the result
end nvm_Update

command nvm_Help xtermView
   ttyd_Execute "nvm help", xtermView
   --
   if the shiftKey is "Down" then
      launch url "https://tecadmin.net/install-nvm-macos-with-homebrew/"
   end if
end nvm_Help
