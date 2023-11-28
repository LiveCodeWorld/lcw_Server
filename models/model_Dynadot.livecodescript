script "model_Dynadot"
--> MetaData
-
license: GPLv3
name: model_Dynadot
type: model
version: 0.1


--> Varaibles
-
local DynodotDomainArray

--> Working on
--
function dynadot_GetDomainNameArray pForceUpdate
   if pForceUpdate is not false then
      put dynadot_GetIndexedDomainArray (true) into DynodotDomainArray
   end if   
   put dynadot_ConstructDomainListArray (DynodotDomainArray) into domainNameArray
   return domainNameArray
end dynadot_GetDomainNameArray


--> Dynadot | Model | Stored
-
command dynadot_UpdateCachedIndexDomainArray
   put dynadot_FetchIndexedDomainArray() into DynodotDomainArray
   return DynodotDomainArray
end dynadot_UpdateCachedIndexDomainArray

function dynadot_FetchDomainArray
   put dynadot_FetchArray ("list_domain") into responseArray
   return responseArray
end dynadot_FetchDomainArray

function dynadot_FetchIndexedDomainArray
   put dynadot_FetchArrayFromXml() into responseArray
   return responseArray
end dynadot_FetchIndexedDomainArray


--> Dynadot | Model | Indexed Array
-
function dynadot_GetDomainInfoArray domainName, pForceUpdate
   -- could cache
   put dynadot_GetDomainNameArray (pForceUpdate) into domainNameArray
   put domainNameArray [domainName] into domainDetailsArray
   return domainDetailsArray
end dynadot_GetDomainInfoArray

function dynadot_GetIndexedDomainArray pForceUpdate
   if DynodotDomainArray is not an array or pForceUpdate is true then
      dynadot_UpdateCachedIndexDomainArray
   end if
   return DynodotDomainArray
end dynadot_GetIndexedDomainArray

command dynadot_SetIndexedDomainArray newDynodotDomainArray
   put DynodotDomainArray into DynodotDomainArray
end dynadot_SetIndexedDomainArray
