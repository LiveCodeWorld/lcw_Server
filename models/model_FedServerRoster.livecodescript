script "model_FedServerRoster"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_FedServerRoster
type: model
version: 0.1

/*
Federation server models are stored on pages named "ServerName Model" on the wiki "server.fedwiki.org"

Each server model has the following structure:

- federationServerArray ["domains"] = fedray
- federationServerArray ["pageNum"]
- federationServerArray ["ipAddress"]
- federationServerArray ["domainNum"]

of which "fedray" is the most important
*/


--> Variables
-
/*
Roster models are wiki pages on "roster.fedwiki.org" named "ModelName Model"
The wiki pages contain a json plugin which stored the model 
*/
constant FedModelDomain = "roster.fedwiki.org"


--> Working on
-
command federation_Launch modelTitle
   put federation_ModelDomain() into modelDomain
   fedwiki_Launch modelDomain, modelTitle
   return the result
end federation_Launch

function federation_ModelDomain
   return FedModelDomain
end federation_ModelDomain

command federation_CreateModelPage modelTitle
   if federation_ModelExists (modelTitle) then
      return merge ("Error, model '[[modelTitle]]' already exists. Delete first if you want to create it anew.")
   end if
   
   put fedwiki_ConstructSlug (modelTitle) into pageSlug
   put empty into forkDomains
   --
   put pageArray_GetTemplate (FedModelDomain, "Model Template", modelTitle, forkDomains) into pageArray
   pageArray_Set FedModelDomain, pageSlug, pageArray
   --
   return pageArray
end federation_CreateModelPage

command federation_DeleteModelPage modelTitle
   put fedwiki_ConstructSlug (modelTitle) into pageSlug
   pageArray_Delete FedModelDomain, pageSlug
   return the result
end federation_DeleteModelPage


--> Federation | Server | Sites
-
function federation_ModelExists modelTitle
   put federation_ListModels() into modelTitles
   set the wholematches to true
   put modelTitle is among the lines of modelTitles into modelExists
   return modelExists
end federation_ModelExists

function federation_ListModels
   put fedwiki_ListSitemapPages (FedModelDomain) into pageTitles
   filter pageTitles with "* Model"
   return pageTitles
end federation_ListModels

function federation_ListDocumentedServerNames
   put fedwiki_ListSitemapPages ("server.fedwiki.org") into wikiPages
   filter wikiPages with "* Server"
   return wikiPages
end federation_ListDocumentedServerNames


--> Roster | Model
-
function fedserver_ConstructModel serverName
   put federation_ConstructServerModel() into federationServerModel
   put federationServerModel [serverName] into fedserverModel
   return fedserverModel
end fedserver_ConstructModel

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
