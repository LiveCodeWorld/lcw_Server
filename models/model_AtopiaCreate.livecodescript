script "model_AtopiaCreate"
--> MetaData
-
copyright: Anonymous
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
   -- digitalOcean_StoreData someData, AtopiaDropletName, somePath, AtopiaSshUser
   put the tempname into localFile
   put someData into url ("binfile://" & localFile)
   atopia_StoreFile localFile, somePath
   --
   put the result into shellResult
   return shellResult
end atopia_StoreData

command digitalOcean_StoreData someData, dropletName, pathToStore, pSshUserName
   put the tempname into localFile
   put someData into url ("binfile://" & localFile)
   digitalOcean_StoreFile pathToStore, localFile, dropletName, pSshUserName
   return the result
end digitalOcean_StoreData

command atopia_StoreFile localFile, pathToStore
   digitalOcean_StoreFile pathToStore, localFile, AtopiaDropletName, AtopiaSshUser
   put the result into shellResult
   return shellResult
end atopia_StoreFile

command digitalOcean_StoreFile pathToStore, localFile, dropletName, sshUserName
   put atopia_GetIP (pForceFetch) into atopiaIP
   
   server_StoreFile localFile, pathToStore, atopiaIP, sshUserName
   put the result into someResult
   return someResult
end digitalOcean_StoreFile

command server_StoreFile localFile, pathToStore, serverAddress, sshUser, pSshKeyPath
   -- uses "scp" and private keys for security
   if serverAddress is empty or sshUser is empty then
      return "Error, serverAddress is empty or sshUser is empty"
   end if
   
   if char 1 of pathToStore is "/" then
      put pathToStore into fullPath
   else
      put "~/" & pathToStore into fullPath
   end if
   shell_StoreFile sshUser, serverAddress, fullPath, localFile, pSshKeyPath
   put the result into shellResult
   return shellResult
end server_StoreFile

command shell_StoreFile sshUser, remoteDomain, remotePath, localFile, pSshKeyPath
   /*
   scp –P 40050 Desktop/url.txt yatri@192.168.1.50:~/Desktop/url.txt
   scp hierarchical.png root@178.62.43.72:~/.wiki/actual.world/pages/hierarchical.png
   
   -- https://superuser.com/questions/1022976/scp-copy-has-error-ambiguous-target
   If you have white space in a path, you have to escape the characters by using double backslashes \\ and enclosing the entire path in quotes:
         scp myfile.txt user@192.168.1.100:"/file\\ path\\ with\\ spaces/myfile.txt"
   
   */
   
   -- shell_BashParamEscape localFile
   put kwote (word 1 to -1 of localFile) into localFile
   
   -- shell_BashParamEscape fullPath
   -- The outside set of quotes are for the local shell, and the inside quotes are for the remote shell.
   --    scp "my local file.txt" user@192.168.1.100:"'/folder/my spacey folder name/'"
   put word 1 to -1 of remotePath into remotePath
   put "'" before remotePath
   put "'" after remotePath
   put kwote (remotePath) into remotePath
   
   put sshUser & "@" & remoteDomain & ":" & remotePath into scpDestination
   put "scp"  into someShell
   if pSshKeyPath is not empty then
      shell_BashParamEscape pSshKeyPath
      put space & "-i " && pSshKeyPath after someShell
   end if
   put space & localFile && scpDestination after someShell
   
   put shell (someShell) into shellResult
   return shellResult
end shell_StoreFile


--> Atopia | Files | Model | Delete
-
command atopia_DeleteFile pathToDelete
   digitalOcean_DeleteFile pathToDelete, AtopiaDropletName, AtopiaSshUser
   put the result into shellResult
   return shellResult
end atopia_DeleteFile

command ssh_DeleteFile sshUser, remoteDomain, somePath
   -- can we ensure it only deletes a single file?
   shell_BashParamEscape somePath
   --
   put "rm" && somePath into remoteCommand
   ssh_DoRemoteShell sshUser, remoteDomain, remoteCommand
   put the result into shellResult
   return shellResult
end ssh_DeleteFile


