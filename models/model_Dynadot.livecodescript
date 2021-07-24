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


--> Dynadot | Model | Stored
-
command dynadot_UpdateCachedIndexDomainArray
   put dynadot_FetchIndexedDomainArray() into DynodotDomainArray
   --
   return DynodotDomainArray
end dynadot_UpdateCachedIndexDomainArray

private command _CheckApiError @responseArray, @errorText
   if responseArray is not an array then
      breakpoint
      return false
   end if
   --
   put responseArray ["Response"]["ResponseHeader"]["error"] into errorText
   if errorText is empty then
      return true
   else
      put empty into responseArray
      return false
   end if
end _CheckApiError

function dynadot_FetchIndexedDomainArray
   -- v3
   -- https://api.dynadot.com/api3.xml?key=mykey&command=list_domain
   put dynadot_GetAdvancedXML ("list_domain") into someXML
   --
   if dynadot_CheckError (someXML) is not empty then
      breakpoint
   end if
   --
   put xml_ToArray (someXML) into responseArray
   --
   _CheckApiError responseArray, errorText
   --
   if the result is false then
      put errorText
      lcw_AnswerWarning "There was an api error fetching Dynadot IndexDomainArray..."
   end if
   --
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

function dynadot_GetDomainNameArray pForceUpdate
   if pForceUpdate is true then
      put dynadot_GetIndexedDomainArray (true) into DynodotDomainArray
   end if   
   put dynadot_ConstructDomainListArray (DynodotDomainArray) into domainNameArray
   return domainNameArray
end dynadot_GetDomainNameArray

function dynadot_GetIndexedDomainArray pForceUpdate
   if DynodotDomainArray is not an array or pForceUpdate is true then
      dynadot_UpdateCachedIndexDomainArray
   end if
   return DynodotDomainArray
end dynadot_GetIndexedDomainArray

command dynadot_SetIndexedDomainArray newDynodotDomainArray
   put DynodotDomainArray into DynodotDomainArray
end dynadot_SetIndexedDomainArray
