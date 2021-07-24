script "model_Fedray"
--> MetaData
-
license: GPLv3
name: model_Fedray
type: model
version: 0.2

/*
This library concerns itself with "federation arrays" or fedray. See also "lib_Fedray"
There is one big fedray for the federation. But individual servers can also have small fedrays - such as the atopia fedray

# Federation Fedray
The federation fedray is stored as json on the wiki page "federation-model" of the domain "roster.fedwiki.org"
You can access the federation fedray model using: "fedray_FetchModel" and "fedray_StoreModel"

# Federation | Server | Roster | Model
Local server fedrays are stored as json on pages 
The Atopia Fedray Model for instance is stored 
-

*/


--> Working on
-
function fedray_FetchDomains pWikiDomain
   -- see also federation_FetchRoster() and federation_ListAllDomains()
   put fedray_FetchModel() into fedray
   put the keys of fedray into fedrayDomains
   url_SortDomainIndex fedrayDomains
   --
   if pWikiDomain is not empty then
      filter fedrayDomains with ("*." & pWikiDomain)
      put pWikiDomain & CR before fedrayDomains
   end if
   return fedrayDomains
end fedray_FetchDomains


--> Atopia | Fedray | Model
-
command fedray_AddAtopiaDomainArray atopiaFedray
   put fedray_FetchModel() into fedray
   --
   union fedray with atopiaFedray
   --
   fedray_StoreModel fedray
   return fedray
end fedray_AddAtopiaDomainArray


--> Fedray | Author
-
function fedray_FetchAuthorDomains authorNames
   put fedray_FetchModel() into fedray
   put fedray_ConstructAuthorData (fedray) into authorNameData
   
   replace comma with CR in authorNames
   repeat for each line authorName in authorNames
      get authorNameData [authorName]
      union authorNameArray with it
   end repeat
   put keys (authorNameArray) into authorDomains
   url_SortDomainIndex authorDomains
   
   return authorDomains
end fedray_FetchAuthorDomains

function fedray_ConstructAuthorData fedray
   local authorArray
   repeat for each key wikiDomain in fedray
      set the cursor to busy
      put fedray [wikiDomain] into domainArray
      put domainArray ["owner"] into ownerName
      if ownerName is empty then put "No name" into ownerName
      put domainArray into authorArray [ownerName][wikiDomain]
   end repeat
   return authorArray
end fedray_ConstructAuthorData

function fedray_GetAuthorDomains authorNames, authorNameData
   local authorNameArray
   --
   replace comma with CR in authorNames
   repeat for each line authorName in authorNames
      get authorNameData [authorName]["domains"]
      union authorNameArray with it
   end repeat
   put keys (authorNameArray) into authorDomains
   url_SortDomainIndex authorDomains
   --
   return authorDomains
end fedray_GetAuthorDomains


--> Fedray | Model
-
function fedray_FetchModel
   put federation_FetchModel ("Federation Model") into fedray
   return fedray
end fedray_FetchModel

command fedray_StoreModel fedray
   federation_StoreModel "Federation Model", fedray
   put the result into putError
   return putError
end fedray_StoreModel


--> Fedray | Model
-
/*
Federation models are wiki pages on "roster.fedwiki.org" named "[[ModelName]] Model"
The wiki pages contain a json plugin which stored the model 
*/

constant FedModelDomain = "roster.fedwiki.org"

function federation_ModelDomain
   return FedModelDomain
end federation_ModelDomain

command federation_Launch modelTitle
   put federation_ModelDomain() into modelDomain
   fedwiki_Launch modelDomain, modelTitle
   return the result
end federation_Launch

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

command federation_CreateModelPage modelTitle
   if federation_ModelExists (modelTitle) then
      return merge ("Error, model '[[modelTitle]]' already exists. Delete first if you want to create it anew.")
   end if
   
   put fedwiki_ConstructSlug (modelTitle) into pageSlug
   put empty into forkDomains
   --
   put pageArray_FetchTemplate (FedModelDomain, "Model Template", modelTitle, forkDomains) into pageArray
   pageArray_Store FedModelDomain, pageSlug, pageArray
   --
   return pageArray
end federation_CreateModelPage

command federation_DeleteModelPage modelTitle
   put fedwiki_ConstructSlug (modelTitle) into pageSlug
   pageArray_Delete FedModelDomain, pageSlug
   return the result
end federation_DeleteModelPage

function federation_FetchModel modelTitle
   put fedwiki_ConstructSlug (modelTitle) into pageSlug
   put fedwiki_FetchPluginData (pageSlug, FedModelDomain) into fedray
   if fedray is false then return empty
   return fedray
end federation_FetchModel

command federation_StoreModel modelTitle, fedray
   put fedwiki_ConstructSlug (modelTitle) into pageSlug
   -- put atopia_GetJsonSecret() into apiKey
   put secret_Get ("AtopiaJsonApiKey", "jsonApiKey") into apiKey
   put json_FromArray (fedray) into someJSON
   fedwiki_PutPluginJSON someJSON, pageSlug, FedModelDomain, apiKey
   put the result into putError
   return putError
end federation_StoreModel


--> Private
-
private command _SetModelSlug @pageSlug, pModelTitle
   -- ideally a single "pageTitle" like word
   if pModelTitle is empty then put "Federation" into pModelTitle
   put pModelTitle && "Model" into pageTitle
   put fedwiki_ConstructSlug (pModelTitle) into pageSlug
   return pageTitle
end _SetModelSlug
