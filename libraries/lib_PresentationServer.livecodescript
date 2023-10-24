script "lib_PresentationServer"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_PresentationServer
type: library
version: 0.1

/*
The idea here is to have a quick and easy http server that we can use to control presentations on a LAN.
*/

--> Variables
-
constant ServerID = 12345


--> Working on
-
command presentation_StartServer
   httpdStart "NewRequest", ServerID, "Presentation Server"
   put it into sadf
   --
   launch url ("http://localhost:" & it)
end presentation_StartServer

on NewRequest pSocketID, pRequest
   local tPath
   put the effective filename of me into tPath
   set the itemDelimiter to slash
   
   put "files/" & pRequest["resource"] into the last item of tPath
   if there is a file tPath then
      local tData
      put url ("binfile:" & tPath) into tData
      httpdResponse pSocketID, 200, tData
   else
      -- not found
      httpdResponse pSocketID, 404
   end if
end NewRequest

command presentation_StopServer
   httpdStop ServerID
end presentation_StopServer

function presentation_ServerIsRunning
   get the opensockets
   set the wholeMatches to true
   return ServerID is among the lines of it
end presentation_ServerIsRunning


--> Presentation | Server
-


--> Deps
-
