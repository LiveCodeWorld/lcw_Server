script "lib_Tunnel"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Tunnel
type: library
version: 0.2

/*
This library if creating tunnels between local servers and the wider internet.
There are a number of services that do this (see lib_Ngrok), but here we focus on LocalXpose
*/

--> Variables
-
local LocalArray


--> Working on
-
on mDoubleUp_TunnelReserved dView, tunnelDomain
   if the optionKey is "Down" then breakpoint
   put tunnel_GetRegisteredCName (tunnelDomain)
end mDoubleUp_TunnelReserved

command display_ReservedTunnels pDisplayView
   put tunnel_ListDomains() into tunnelDomains
   --
   display_Data tunnelDomains, "Reserved Domains", "Tunnel", pDisplayView
   put the result into dView
   display_SetMouseAndMenu dView, "Tunnel | Reserved", "lib_Tunnel"
   return dView
end display_ReservedTunnels

function tunnel_GetRegisteredCName tunnelDomain
   put tunnel_FetchDomainArray() into domainArray
   put domainArray [tunnelDomain]["cname"] into cNameValue
   return cNameValue
end tunnel_GetRegisteredCName

function tunnel_AccountStatus
   put shell ("loclx account status") into shellResult
   return line 2 of shellResult
end tunnel_AccountStatus

command tunnel_Login pXtermBrowser
   display_Xterm pXtermBrowser
   put the result into xtermView
   object_GoTo xtermView, true
   --
   put tunnel_GetApiKey() into apiKey
   --
   shell_Do "loclx account login", "execute", xtermView
   shell_Do apiKey, "paste", xtermView
   return line 2 of shellResult
end tunnel_Login

function tunnel_GetApiKey
   -- available on web site
   return secret_Get ("LocalXpose")
end tunnel_GetApiKey

command tunnel_SetApiKey sApiKey
   secret_Set "LocalXpose", sApiKey
   return the result
end tunnel_SetApiKey

function tunnel_ListDomains
   get tunnel_FetchDomainArray()
   put keys(it) into domainNames
   url_SortDomainIndex domainNames
   return domainNames
end tunnel_ListDomains

function tunnel_FetchDomainArray
   /*
   loclx domain list     
   eu -> astralship.wiki, pz2lxakw1leizrw.eu.loclx.io
   eu -> radical.institute, jfwwfydq93tktzy.eu.loclx.io
   eu -> astral.eu.loclx.io
   eu -> *.astralship.wiki, a2v0pgisrrpogjv.eu.loclx.io
   eu -> *.platform.earth, yhdhcbundskxzwc.eu.loclx.io
   
   */
   put shell ("loclx domain list") into shellResult
   --
   repeat for each line sLine in shellResult
      set the itemdelimiter to "->"
      if the number of items of sLine = 2 then
         put word 1 to -1 of item 1 of sLine into sRegion
         get item 2 of sLine
         
         -- astralship.wiki, pz2lxakw1leizrw.eu.loclx.io
         set the itemdelimiter to comma
         put word 1 to -1 of item 1 of it into subDomain 
         put word 1 to -1 of item 2 of it into cNameValue
         --
         put cNameValue into domainArray [subDomain]["cname"]
         put sRegion into domainArray [subDomain]["region"]
      end if
   end repeat
   return domainArray
end tunnel_FetchDomainArray

function tunnel_IsActive
   put tunnel_ListProcessIds() into pID
   return pID is a number
end tunnel_IsActive

function tunnel_ListProcessIds
   -- put LocalArray ["loclx tunnel pid"] into pIDs
   put shell_ListProcessIds ("loclx tunnel config") into pIDs
   return pIDs
end tunnel_ListProcessIds

command tunnel_Kill pIDs
   if pIDs is empty then
      put tunnel_ListProcessIds() into pIDs
   end if
   --
   repeat for each item pID in pIDs
      kill process pID
   end repeat
end tunnel_Kill

command tunnel_LaunchFromConfig
   put tunnel_GetYamlFile() into yamlFile
   --
   put the model_Folder of stack "lib_Tunnel" into serverModelFolder
   put the defaultFolder into oDefaultFolder
   set the defaultfolder to serverModelFolder
   -- 
   put "loclx tunnel config -f" && kwote (yamlFile) into someShell
   nohup_DoShell someShell, false
   put the result into pID
   put pID into LocalArray ["loclx tunnel pid"]
   -- shell_Do someShell
   ---
   set the defaultfolder to oDefaultFolder
   return pID
end tunnel_LaunchFromConfig

function tunnel_ConstructAstralConfig reservedDomain, pCors, pLocalPort, pRegion
   put _ConstructAstralConfigBit ("astral", "astralship.wiki", pCors, pLocalPort, pRegion) into sYaml
   put CR&CR after sYaml
   put _ConstructAstralConfigBit ("subastral", reservedDomain, pCors, pLocalPort, pRegion) after sYaml
   return sYaml
end tunnel_ConstructAstralConfig

private function _ConstructAstralConfigBit tunnelName, reservedDomain, pCors, pLocalPort, pRegion
   if pCors is empty then put true into pCors
   if pRegion is empty then put "eu" into pRegion
   if pLocalPort is empty then put 80 into pLocalPort
   put "  " into tabBit
   put LF into lDelim
   
   put tunnelName & ":" & CR after sYaml
   put tabBit & "type: http" & lDelim after sYaml
   put tabBit & "region:" && pRegion & lDelim after sYaml
   put tabBit & "reserved_domain:" && reservedDomain & lDelim after sYaml
   put tabBit & "to: localhost:" & pLocalPort & lDelim after sYaml
   if pCors is true then
      put tabBit & "plugins:" & lDelim after sYaml
      put tabBit & tabBit & "request_header:" & lDelim after sYaml
      put tabBit & tabBit & tabBit & "- 'Access-Control-Allow-Origin: *'" & lDelim after sYaml
   end if
   delete char - 1 of sYaml
   return sYaml
end _ConstructAstralConfigBit

command tunnel_Create sDomain, pSomeHow, pBrowserView
   if pSomeHow is empty then put "nohup" into pSomeHow
   --
   put "loclx tunnel http --to localhost:80 --request-header 'Access-Control-Allow-Origin: *' --reserved-domain" && kwote (sDomain) into someShell
   replace "'" with quote in someShell
   --   
   shell_Do someShell, pSomeHow, pBrowserView
   put the result into pID
   return the result
end tunnel_Create

command tunnel_ReserveLocalDomain sDomain, pRegion, pSomeHow, pBrowserView
   put merge ("loclx domain reserve --domain [[sDomain]] --region [[pRegion]]") into someShell
   --
   shell_Do someShell, pSomeHow, pBrowserView
   put the result into shellResult
   
   -- Error: domain is taken 
   
   put _GetCnameValue (shellResult) into cNameValue
   return cNameValue
end tunnel_ReserveLocalDomain

private function _GetCnameValue shellResult
   put lineOffset ("Please add this dns cname record", shellResult) into lineNum
   put word -1 of line lineNum of shellResult into cNameValue
   return cNameValue
end _GetCnameValue

function tunnel_VerifyCname sDomain, pSomeHow, pBrowserView
   put "loclx domain status --domain" && sDomain into someShell
   --
   shell_Do someShell, pSomeHow, pBrowserView
   return the result
end tunnel_VerifyCname

command tunnel_CreateCertificate sDomain, pSomeHow, pBrowserView
   put "loclx domain letsencrypt --domain" && sDomain into someShell
   --
   shell_Do someShell, pSomeHow, pBrowserView
   return the result
end tunnel_CreateCertificate


--> Tunnel | Config
-
command tunnel_GetYaml
   put tunnel_GetYamlFile() into yamlFile
   put url ("file:" & yamlFile) into sYaml
   return sYaml
end tunnel_GetYaml

command tunnel_SetYaml sYaml
   put tunnel_GetYamlFile() into yamlFile
   -- put sYaml into url ("file:" & yamlFile)
   text_Set yamlFile, sYaml
end tunnel_SetYaml
   
function tunnel_GetYamlFile
   put the model_Value ["yamlFile"] of stack "lcw_Server" into yamlFile
   if there is a file yamlFile then
      return yamlFile
   else
      return "/Users/david/Documents/git-repos/LiveCodeWorld/lcw_Server/models/config.yaml"
   end if
end tunnel_GetYamlFile

command tunnel_SetYamlFile yamlFile
   put "/Users/david/Documents/git-repos/LiveCodeWorld/lcw_Server/models/config.yaml" into yamlFile
   set the model_Value ["yamlFile"] of stack "lcw_Server" to yamlFile
   return the result
end tunnel_SetYamlFile
