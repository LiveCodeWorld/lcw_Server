script "model_FedServer"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_FedServer
type: model
version: 0.4

/*
Fedserver models contain metadata about a fedwiki server.
They are stored as json files on the "server.fedwiki.org" wiki.
Fedserver models can be contructed from fedrays using "federation_ServerModelFromFedray" (which you can find in "lib_Fedserver")

The federationServerModel is one big model constructed out of all the Fedserver models
It is currently stored and consteucted and composed a number of ways to see what is needed.

- 1) It can be "composed" from all the seperately stored Fedserver models.
- 2) It can be built from the federation fedray
- 3) It can be fetched from a store (federation_FetchModel ("Server Model"))
*/


--> Federation | Server | Roster | Model
-
function federation_FetchRoster serverName
   -- see also fedray_FetchDomains()
   put _ConstructServerPageSlug (serverName) into pSlug 
   put roster_Fetch ("server.fedwiki.org", pSlug, "741a0fcdd3ff76b2") into rosterText
   return word 1 to -1 of rosterText
end federation_FetchRoster

command federation_StoreRoster rosterText
   put _ConstructServerPageSlug (serverName) into pSlug 
   roster_Store "server.fedwiki.org", pSlug, rosterText, "741a0fcdd3ff76b2"
   put the result into pageArray
   return pageArray
end federation_StoreRoster


--> Fedserver
-
function federation_ListDocumentedServerNames
   put fedwiki_ListSitemapPages ("server.fedwiki.org") into wikiPages
   filter wikiPages with "* Server"
   return wikiPages
end federation_ListDocumentedServerNames

function federation_ListServerNames
   put federation_FetchModel ("Server Model") into federationServerModel
   put keys (federationServerModel) into serverNames
   sort serverNames
   return serverNames
end federation_ListServerNames

function fedserver_FetchNameDictionary
   -- construct froms stored federationServerModel (reverse the array)
   put federation_FetchModel ("Server Model") into federationServerModel
   --
   repeat for each key serverName in federationServerModel
      put federationServerModel [serverName] into serverArray
      put serverArray ["ipAddress"] into ipAddress
      put serverName into serverNameDictionary [ipAddress]
   end repeat
   return serverNameDictionary
end fedserver_FetchNameDictionary


--> Federation | Server | Model | Compose
-
function federation_ComposeServerModel
   put federation_ListServerNames() into serverNames
   repeat for each line serverName in serverNames
      put fedserver_FetchModel (serverName) into fedserverModel
      if fedserverModel is an array then
         put fedserverModel into federationServerModel [serverName]
      end if
   end repeat
   return federationServerModel
end federation_ComposeServerModel

command federation_DecomposeServerModel
   put federation_FetchModel ("Server Model") into federationServerModel
   repeat for each key serverName in federationServerModel
      set the cursor to busy
      put federationServerModel [serverName] into fedserverModel
      fedserver_StoreModel serverName, fedserverModel
      put the result into putError
      if putError is not empty then
         put serverName & CR after notIndexedServerNames
      end if
   end repeat
   delete char -1 of notIndexedServerNames
   return notIndexedServerNames
end federation_DecomposeServerModel


--> Federation | Server | Model | Build
-
/*
The federationServerModel is one big array that contains all the individual fedserverModels keyed by serverName
It can also be composed from individual fedserverModels using "federation_ComposeServerModel"
*/

function federation_ConstructServerModel pUpdateFedray
   put fedray_FetchModel() into fedray
   put federation_BuildServerModel (fedray, pUpdateFedray) into federationServerModel
   return federationServerModel
end federation_ConstructServerModel

function federation_BuildServerModel fedray, pUpdateFedray
   put federation_ServerModelFromFedray (fedray, pUpdateFedray) into federationServerModel
   --
   put fedserver_FetchNameDictionary() into serverNameDictionary
   _RenameServerModelKeys federationServerModel, serverNameDictionary
   --
   repeat for each key serverName in federationServerModel
      set the cursor to busy
      federation_UpdateServerModel federationServerModel, serverName
   end repeat
   return federationServerModel
end federation_BuildServerModel

function federation_ServerModelFromFedray fedray, pUpdateFedray
   local serverModel
   repeat for each key wikiDomain in fedray
      set the cursor to busy
      _UpdateServerModel serverModel, fedray, wikiDomain, pUpdateFedray
   end repeat
   return serverModel
end federation_ServerModelFromFedray

command federation_UpdateServerModel @federationServerModel, serverName
   put federationServerModel [serverName] into serverDomainArray
   put serverDomainArray ["domains"] into domainArray
   --
   put keys (domainArray) into domainNames
   put the number of lines of domainNames into domainNum
   put domainNum into federationServerModel [serverName]["domainNum"]
   --
   put 0 into serverPageNum
   repeat for each line domainName in domainNames
      put domainArray [domainName]["pages"] into domainPageNum
      add domainPageNum to serverPageNum
   end repeat
   put serverPageNum into federationServerModel [serverName]["pageNum"]
   --
   put serverPageNum && "pages in" && domainNum && "domains" into summaryText
   return summaryText
end federation_UpdateServerModel


--> Fedserver | Fedray | Model
-
/*
The fedServerModel contains
*/

function fedserver_FetchFedray serverName
   put fedserver_FetchModel (serverName) into fedserverModel
   put fedserverModel ["domains"] into serverFedray
   return serverFedray
end fedserver_FetchFedray

command fedserver_StoreFedray serverName, serverFedray
   put fedserver_FetchModel (serverName) into fedserverModel
   put serverFedray into fedserverModel ["domains"]
   fedserver_StoreModel serverName, fedserverModel
   put the result into putError
   return putError
end fedserver_StoreFedray


--> Fedserver | Model | Constructed
-
function fedserver_ConstructModel serverName
   put federation_ConstructServerModel() into federationServerModel
   put federationServerModel [serverName] into fedserverModel
   return fedserverModel
end fedserver_ConstructModel


--> Fedserver | Model
-
/*
Federation server models are stored on pages named "ServerName Model" on the wiki "server.fedwiki.org"

Each server model has the following structure:

- federationServerArray ["domains"] = fedray
- federationServerArray ["pageNum"]
- federationServerArray ["ipAddress"]
- federationServerArray ["domainNum"]

of which "fedray" is the most important
*/

function fedserver_FetchModel serverName
   put _ConstructServerPageSlug (serverName) into pSlug
   --
   put fedwiki_FetchPluginJSON (pSlug, "server.fedwiki.org") into someJSON
   put json_ToArray (someJSON) into fedserverModel
   if fedserverModel is false then return empty
   return fedserverModel
end fedserver_FetchModel

command fedserver_StoreModel serverName, fedserverModel
   put _ConstructServerPageSlug (serverName) into pSlug
   --
   put json_FromArray (fedserverModel) into someJSON
   put atopia_GetJsonSecret() into apiKey
   fedwiki_PutPluginJSON someJSON, pSlug, "server.fedwiki.org", apiKey
   put the result into putError
   return putError
end fedserver_StoreModel


--> Atopia | Plugin | Secret
-
function atopia_GetJsonSecret
   put secret_Get ("AtopiaJsonApiKey", "jsonApiKey") into apiKey
   return apiKey
end atopia_GetJsonSecret

command atopia_SetJsonSecret apiKey
   secret_Set "AtopiaJsonApiKey", apiKey, "jsonApiKey"
   return the result
end atopia_SetJsonSecret


--> Private
-
private function _ConstructServerPageSlug serverName
   put serverName && "Server" into pageTitle
   put fedwiki_ConstructSlug (pageTitle) into pSlug
   return pSlug
end _ConstructServerPageSlug

private command _UpdateServerModel @serverModel, fedray, wikiDomain, pUpdateFedray
   if pUpdateFedray is true then fedray_UpdateLastModified fedray, wikiDomain
   put fedray [wikiDomain] into domainArray
   put domainArray ["ipAddress"] into ipAddress
   if ipAddress is not empty then
      if the number of lines of ipAddress > 1 then
         put line -1 of ipAddress into ipAddress
      end if
      put domainArray into serverModel [ipAddress]["domains"][wikiDomain]
      put ipAddress into serverModel [ipAddress]["ipAddress"] -- only needs to do once but OK
   end if
end _UpdateServerModel

private command _RenameServerModelKeys @serverModel, serverNameDictionary
   repeat for each key serverName in serverModel
      put serverNameDictionary [serverName] into newName
      if newName is not empty then
         put serverModel [serverName] into serverArray
         put serverArray into serverModel [newName]
         delete variable serverModel [serverName]
      end if
   end repeat
end _RenameServerModelKeys
