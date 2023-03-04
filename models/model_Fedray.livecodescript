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

/*
--> Old
-
function old_FetchDomainArray
   -- also "fedserver_FetchFedray" of model_FedServer
   put fedwiki_FetchPluginJSON ("atopia-domain-index", "server.fedwiki.org") into someJSON
   put json_ToArray (someJSON) into atopiaFedray
   if atopiaFedray is false then return empty
   return atopiaFedray
end old_FetchDomainArray

command old_StoreDomainArray atopiaFedray
   if atopiaFedray is not an array then return "Error, atopiaFedray is not an array. Delete instead?"
   --
   put json_FromArray (atopiaFedray) into someJSON
   put secret_Get ("AtopiaJsonApiKey", "jsonApiKey") into apiKey
   fedwiki_PutPluginJSON someJSON, "atopia-domain-index", "server.fedwiki.org", apiKey
   --
   put the result into writeError
   return writeError
end old_StoreDomainArray

function old_FetchFederationModel modelTitle
   put fedwiki_ConstructSlug (modelTitle) into pageSlug
   put fedwiki_FetchPluginData (pageSlug, FedModelDomain) into fedray
   if fedray is false then return empty
   return fedray
end old_FetchFederationModel

command old_StoreFederationModel modelName, fedray
   put fedwiki_ConstructSlug (modelTitle) into pageSlug
   -- put atopia_GetJsonSecret() into apiKey
   put secret_Get ("AtopiaJsonApiKey", "jsonApiKey") into apiKey
   put json_FromArray (fedray) into someJSON
   fedwiki_PutPluginJSON someJSON, pageSlug, FedModelDomain, apiKey
   put the result into putError
   return putError
end old_StoreFederationModel

command federation_Migrate
   federation_MigrateModel "Federation Model"
end federation_Migrate

on federation_MigrateModel modelName
   put federationFetchOldModel (modelName) into modelData
   federation_StoreModel modelName, modelData
end federation_MigrateModel
*/

function jwt_ConstructToken userName
   put the seconds into tIAT
   put tIAT + 10 into tNBF
   put tIAT + 60 into tEXP
   
   put "jwt test" into tJWTpayloadA ["sub"]
   put userName into tJWTpayloadA ["name"]
   put "true" into tJWTpayloadA ["admin"]
   
   # NOTE: SECONDS NEED TO BE A STRING, OTHERWISE THE DATA OF JSONEXPORT IS NOT VALID.
   put tIAT & "" into tJWTpayloadA ["iat"]
   put tNBF & "" into tJWTpayloadA ["nbf"]
   put tEXP & "" into tJWTpayloadA ["exp"]
   put uuid() into tJWTpayloadA ["jti"]
   
   put rigJWTencode( , tJWTpayloadA) into tJWT
   return tJWT
end jwt_ConstructToken


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
      union authorNameArray with it into authorNameArray
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


--> Private
-
private command _SetModelSlug @pageSlug, pModelTitle
   -- ideally a single "pageTitle" like word
   if pModelTitle is empty then put "Federation" into pModelTitle
   put pModelTitle && "Model" into pageTitle
   put fedwiki_ConstructSlug (pModelTitle) into pageSlug
   return pageTitle
end _SetModelSlug
