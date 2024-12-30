script "model_AtopiaCreate"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_AtopiaCreate
type: model
version: 0.1

/*
This library if for creating and deliting files on teh Atopia server.

It is ugly and dangerous, and also had a lot of dependencies - so we look to move it into one place.
Eventually all file creation should be done with native code on the outpost and not use ssh.
*/

--> Variables
-
constant AtopiaDropletName = "Atopia"
constant AtopiaSshUser = "root"


--> Atopia | Files | Model | Store
-
command atopia_StoreData somePath, someData
   put the tempname into localFile
   put someData into url ("binfile://" & localFile)
   atopia_StoreFile localFile, somePath
   --
   put the result into shellResult
   return shellResult
end atopia_StoreData

command atopia_StoreFile localFile, pathToStore
   put atopia_GetIP() into atopiaIP
   server_StoreFile localFile, pathToStore, atopiaIP, AtopiaSshUser
   put the result into shellResult
   return shellResult
end atopia_StoreFile

command atopia_DeleteFile pathToDelete
   put atopia_GetIP() into atopiaIP
   ssh_DeleteFile AtopiaSshUser, atopiaIP, pathToDelete
   put the result into shellResult
   return shellResult
end atopia_DeleteFile


--> Private
-
private command ssh_DeleteFile sshUser, remoteDomain, somePath
   -- can we ensure it only deletes a single file?
   shell_BashParamEscape somePath
   --
   put "rm" && somePath into remoteCommand
   ssh_DoRemoteShell remoteDomain, remoteCommand, sshUser
   put the result into shellResult
   return shellResult
end ssh_DeleteFile

private command server_StoreFile localFile, pathToStore, serverAddress, sshUser, pSshKeyPath
   -- uses "scp" and private keys for security
   if serverAddress is empty or sshUser is empty then
      return "Error, serverAddress is empty or sshUser is empty"
   end if
   
   if char 1 of pathToStore is "/" then
      put pathToStore into fullPath
   else
      put "~/" & pathToStore into fullPath
   end if
   scp_StoreFile serverAddress, fullPath, localFile, sshUser, pSshKeyPath
   put the result into shellResult
   return shellResult
end server_StoreFile

private command shell_BashParamEscape @someParam
   put word 1 to -1 of someParam into someParam
   if text_IsQuoted(someParam) is false then
      repeat for each char someChar in " |()"
         replace someChar with ("\" & someChar) in someParam
      end repeat
   end if
end shell_BashParamEscape

private function text_IsQuoted someText, pString
   local quotedText
   put "['" & quote & "]" into someQuote
   if pString is empty then
      put "(?m)" & someQuote & "(.*)" & someQuote into someReg
   else
      put "(?m)" & someQuote & "(.*" & pString & ".*)" & someQuote into someReg
   end if
   put matchtext (someText, someReg, quotedText) into someBoolean
   return someBoolean
end text_IsQuoted
