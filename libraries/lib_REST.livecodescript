script "lib_REST"
--> MetaData
-
license: GPLv3
name: lib_REST
type: library
version: 0.5


--> Working on
-
function jsonrpc_POST someJSON, restUrl, pOAuthToken, pVersionNum, pExtraHeaders
   -- change to a command
   rest_SetJsonHeaders pOAuthToken, pVersionNum, pExtraHeaders
   post someJSON to url restUrl
   put it into jsonResult
   return jsonResult
end jsonrpc_POST


--> JsonRPC | Array
-
function jsonrpc_GetArray restURL, pOAuthToken, pVersionNum, pExtraHeaders
   put jsonrpc_GET (restURL, pOAuthToken, pVersionNum) into someJson
   put json_ToArray (someJson) into someArray
   return someArray
end jsonrpc_GetArray


--> JSON RPC
-
function jsonrpc_GET restURL, pOAuthToken, pVersionNum, pExtraHeaders
   rest_SetJsonHeaders pOAuthToken, pVersionNum, pExtraHeaders
   put url restURL into someJson
   return someJson
end jsonrpc_GET


--> JSON
-
function json_FromArray pArray, pForceRootType, pPretty
   repeat for each key tKey in pArray
      if pArray[tKey] is an array then
         put "}"&json_FromArray(pArray[tKey]) into pArray[tKey]
      end if
   end repeat
   return(mergJSONEncode("pArray",pForceRootType,pPretty))
end json_FromArray

function json_ToArray pJSON
   if pJSON is empty then return false
   try -- as otherwise an error with non-json causes script to exit
      local tArray,tKeys
      if pJSON is empty then return empty
      repeat for each line tKey in mergJSONDecode(pJSON,"tArray")
         put json_ToArray(tArray[tKey]) into tArray[tKey]
      end repeat
      return tArray
   catch e
      return empty
   end try
end json_ToArray


--> REST
-
command rest_SetJsonHeaders pOAuthToken, pVersionNum, pExtraHeaders
   put "Content-type: application/json" into someHeader
   put CR & "Accept: application/json" after someHeader
   put CR & "Accept-Charset: utf-8" after someHeader
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
   --
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


--> Deps
-
function utf8_Encode someText
   put unidecode(uniencode (someText),"UTF8") into encodedText
   return encodedText
end utf8_Encode
