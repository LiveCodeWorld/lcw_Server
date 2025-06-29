﻿script "lib_REST"
--> MetaData
-
license: GPLv3
name: lib_REST
type: library
version: 0.5


--> Working on
-
-- function json_FromArray pArray, pForceRootType, pPretty
   -- put jsonExport (pArray) into someJSON -- not the same
   
   repeat for each key tKey in pArray
      if pArray[tKey] is an array then
         put "}"&json_FromArray(pArray[tKey]) into pArray[tKey]
      end if
   end repeat
   return (mergJSONEncode("pArray",pForceRootType,pPretty))
end json_FromArray

-- function json_ToArray pJSON
   local tArray,tKeys
   if pJSON is empty then return false
   -- put jsonImport (pJSON) into tArray -- not the same
   
   try -- as otherwise an error with non-json causes script to exit
      if pJSON is empty then return empty
      repeat for each line tKey in mergJSONDecode(pJSON,"tArray")
         put json_ToArray(tArray[tKey]) into tArray[tKey]
      end repeat
      return tArray
   catch e
      return empty
   end try
end json_ToArray


--> JsonRPC | Array
-
function jsonrpc_GetArray restURL, pOAuthToken, pExtraHeaders, pVersionNum
   put jsonrpc_GET (restURL, pOAuthToken, pExtraHeaders, pVersionNum) into utf8Json
   put textEncode (utf8Json, "UTF-8") into rJson
   put json_ToArray (rJson) into rArray
   return rArray
end jsonrpc_GetArray

function jsonrpc_PostArray postData, restUrl, pOAuthToken, pExtraHeaders, pVersionNum
   put json_FromArray (postData) into postJSON
   -- put textDecode (postJSON, "UTF-8") into postJSON -- seems to cause an issue sometimes???
   --
   put jsonrpc_POST (postJSON, restUrl, pOAuthToken, pExtraHeaders, pVersionNum) into utf8Json
   --
   put textEncode (utf8Json, "UTF-8") into rPageJson
   put json_ToArray (rPageJson) into rPageArray
   return rPageArray
end jsonrpc_PostArray

function jsonrpc_POST someJSON, restUrl, pOAuthToken, pExtraHeaders, pVersionNum
   rest_SetJsonHeaders pOAuthToken, pVersionNum, pExtraHeaders
   post someJSON to url restUrl
   put it into utf8Json
   return utf8Json
end jsonrpc_POST


--> JSON RPC
-
function jsonrpc_GET restURL, pOAuthToken, pExtraHeaders, pVersionNum
   rest_SetJsonHeaders pOAuthToken, pVersionNum, pExtraHeaders
   put url restURL into someJson
   return someJson
end jsonrpc_GET

function jsonrpc_Headers pOAuthToken, pVersionNum, pExtraHeaders
   put "Content-type: application/json; charset=utf-8" into someHeader
   put CR & "Accept: application/json" after someHeader
   -- put CR & "Accept-Charset: utf-8" after someHeader -- https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Charset
   -- put CR & "Content-type: charset: UTF-8" after someHeader -- charset=UTF-8
   --
   if pVersionNum is not empty then
      put "; version=" & pVersionNum after someHeader
   end if
   if pExtraHeaders is not empty then
      put CR & word 1 to -1 of pExtraHeaders after someHeader
   end if
   if pOAuthToken is not empty then
      put CR & "Authorization: Bearer" && pOAuthToken after someHeader
   end if
   return someHeader
end jsonrpc_Headers


--> REST
-
command rest_SetJsonHeaders pOAuthToken, pVersionNum, pExtraHeaders
   put jsonrpc_Headers (pOAuthToken, pVersionNum, pExtraHeaders) into someHeader
   set the httpHeaders to someHeader
   return someHeader
end rest_SetJsonHeaders


--> REST | Forms
-
function rest_FormEncodeData pFilename
   /*
   Files should be sent using HTTP multipart encoding. 
   You must include a 'filename' parameter in the Content-Disposition multipart header, to ensure that our webserver processes it as a file.
   
   -- should simulate this from audioboo-oauth-webapp.rb
   
   <form action='/upload' enctype='multipart/form-data' method=POST>
   Want to upload an audio file?
   <input type=file name=audio_file>
   <input type=submit value=Upload>
   </form>
   
   ...image content...
   --01ead4a5-7a67-4703-ad02-589886e00923
   Content-Type: image/jpeg
   Content-Disposition: form-data; name=image2; filename=url.jpg
   */
   
   if pFilename is empty then
      answer file "Select an image file..."
      put it into pFilename
   end if
   
   local tForm   
   put libURLMultipartFormData (tForm) into tError
   put "<file>" & pFilename into tFile
   put "image/gif" into tType
   put "binary" into tEnc
   put libURLMultipartFormAddPart (tForm, "file", tFile, tType, tEnc) into tError
   if tError is empty then
      put utf8_Encode (tForm) into tForm
      return tForm
   else
      return tError
   end if
end rest_FormEncodeData


--> REST | Array
-
function rest_PostArray someArray, restUrl, pOAuthToken, pVersionNum
   put rest_ConstructFormArray (someArray) into formArray
   put libURLMultipartFormData (formData, formArray) into tError
   if tError is not empty then return tError
   
   post formData to url restUrl
   put it into jsonResult
   return jsonResult
end rest_PostArray

function rest_ConstructFormArray someArray
   /*
   You can also pass in an array instead of pairs of parameters. 
   This could be useful if there are many parts to a form. 
   The array must be numerically indexed, and each element should contain the part name and part value, separated by a comma. 
   */
   put 1 into i ndexNum
   repeat for each key someKey in someArray
      put someArray [someKey] into someValue
      put someKey,someValue into formArray [indexNum]
      add 1 to indexNum
   end repeat
   return formArray
end rest_ConstructFormArray


--> REST | Post
-
function rest_PostJson jsonOrArray, restUrl, pOAuthToken, pVersionNum
   if jsonOrArray is an array then
      put json_FromArray (jsonOrArray) into someJSON
   else
      -- could error check here
      put jsonOrArray into someJSON
   end if
   put jsonrpc_POST (someJSON, restUrl, pOAuthToken, pVersionNum) into jsonResult
   return jsonResult
end rest_PostJson

command rest_SetBasicHeaders oauthAccessToken, pExtraHeaders
   put "Content-type: application/json" & CR & "Authorization: Bearer" && oauthAccessToken into newHeaders
   if pExtraHeaders is not empty then
      put CR & "Accept: application/json; version=1" after newHeaders
   end if
   set the httpHeaders to newHeaders
   return newHeaders
end rest_SetBasicHeaders

command rest_SetOauthHeaders oauthAccessToken, pExtraHeaders
   put "Content-type: application/json" & CR & "Authorization: Bearer" && oauthAccessToken into newHeaders
   if pExtraHeaders is not empty then
      put CR & "Accept: application/json; version=1" after newHeaders
   end if
   set the httpHeaders to newHeaders
   return newHeaders
end rest_SetOauthHeaders


--> Deps
-
-- function secret_Get secretName
   -- for server use only
   if the environment is not "server" then pass "secret_Get"
   --
   put rigFetchConfigItem (secretName) into someSecret
   return someSecret
end secret_Get

function utf8_Encode someText
   put unidecode(uniencode (someText),"UTF8") into encodedText
   return encodedText
end utf8_Encode
