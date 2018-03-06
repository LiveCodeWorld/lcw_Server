script "lib_DreamFactory"
--> MetaData
-
license: GPLv3
name: lib_DreamFactory
type: library
version: 0.2


--> Test
-
on menu_TestUploadImage
   /*
   put "{'resource': [{'name': 'filename.jpg', 'type': 'file', 'is_base64': true, 'content': 'base 64 encoded string goes here'}]}" into someJSON
   replace "'" with quote in someJSON
   put json_ToArray (someJSON) into resourceArray
   display_Array resourceArray
   return empty
   */
   
   put "https://farm5.staticflickr.com/4425/36358560396_e3e84da625.jpg" into imageURL
   put "wiki/video.icotopia.io/status/theme/test2.jpg" into relImageFile
   -- put url imageURL into someImage
   -- dreamfactory_UploadImage relImageFile, someImage
   dreamfactory_TransferFile relImageFile, imageURL
end menu_TestUploadImage


--> Fedwiki | DreamFactory
-
function fedwiki_FetchFolderArray domainFolderName, pSessionToken
   -- http://culturecollective.cc/api/v2/files/%2Fwiki%2Fdavid.icotopia.io%2Fpages%2F
   -- /?include_properties=true&include_folders=true&include_files=true&full_tree=false&zip=false
   
   put true into paramArray ["include_properties"]
   --
   _Login apiKey, pSessionToken
   put "wiki/" & domainFolderName & "/pages/" into relPath
   put dreamfactory_ConstructRestURL ("files", relPath, paramArray) into someURL
   rest_SetDreamFactoryHeaders apiKey, pSessionToken
   --
   put url someUrl into jsonReply
   put json_ToArray (jsonReply) into responseArray
   put jsonReply
   display_Array responseArray
   return responseArray
end fedwiki_FetchFolderArray

function fedwiki_ListPageSlugs domainFolderName
   put fedwiki_FetchFolderResourceArray (domainFolderName) into resourceArray
   repeat for each key itemNum in resourceArray
      put resourceArray [itemNum]["name"] into someKey
      put resourceArray [itemNum]["path"] into nameArray [someKey]
   end repeat
   return keys (nameArray)
end fedwiki_ListPageSlugs

function fedwiki_FetchPageListArray domainFolderName
   put fedwiki_FetchFolderResourceArray (domainFolderName) into resourceArray
   repeat for each key itemNum in resourceArray
      put resourceArray [itemNum]["name"] into pageSlug
      put fedwiki_ConstructTitle (pageSlug) into pageTitle
      put resourceArray [itemNum]["path"] into relPath
      --
      put relPath into nameArray [pageTitle]["path"]
      put pageSlug into nameArray [pageTitle]["slug"] 
   end repeat
   return nameArray
end fedwiki_FetchPageListArray

function fedwiki_FetchFolderResourceArray domainFolderName
   put "wiki/" & domainFolderName & "/pages/" into someFolder
   put dreamfactory_ListFiles (someFolder) into someJSON
   put json_ToArray (someJSON) into pageListArray
   put pageListArray ["resource"] into resourceArray
   return resourceArray
end fedwiki_FetchFolderResourceArray

function fedwiki_FetchPage pageSlug, wikiDomain, pSessionToken
   put "/wiki/" & wikiDomain & "/pages/" & pageSlug into relPath
   put dreamfactory_FetchFile (relPath, pSessionToken) into pageJSON
   return pageJSON
end fedwiki_FetchPage
   
command fedwiki_StorePage pageSlug, wikiDomain, fileData, pSessionToken
   put "/wiki/" & wikiDomain & "/pages/" & pageSlug into relPath
   -- put "files/" & wikiDomain & "/pages/" & pageSlug into relPath
   dreamfactory_StoreFile relPath, fileData, pSessionToken
   return the result
end fedwiki_StorePage

command fedwiki_DeletePage pageSlug, wikiDomain, pSessionToken
   put "/wiki/" & wikiDomain & "/pages/" & pageSlug into relPath
   dreamfactory_DeleteFile relPath, pSessionToken
   return the result
end fedwiki_DeletePage

command fedwiki_CreateThemeFolder domainFolderName
   dreamfactory_CreateFolder relPath
end fedwiki_CreateThemeFolder


--> DreamFactory | Upload
-
command dreamfactory_UploadImage relImageFile, someImage
   local paramArray
   -- let's tidy and check path first
   put word 1 to -1 of relFolder into relFolder
   if char -1 of relFolder is slash then
      -- it's a folder and we should be passing a file
      breakpoint
      return empty
   end if
   
   set the itemdelimiter to slash
   put item -1 of relImageFile into shortFile
   put item 1 to -2 of relImageFile & slash into relFolder
   
   --    POST http://foo.com/api/v2/files/images/
   put dreamfactory_ConstructRestURL ("files", relFolder, paramArray) into folderUrl
   --
   /*
   */
   put shortFile into resourceArray ["resource"][1]["name"]
   put "file" into resourceArray ["resource"][1]["type"]
   put true into resourceArray ["resource"][1]["is_base64"]
   put base64Encode (someImage) into resourceArray ["resource"][1]["content"]
   put json_FromArray (resourceArray) into imageJSON
   --
   _Login apiKey, pSessionToken
   rest_SetDreamFactoryHeaders apiKey, pSessionToken
   post imageJSON to url folderUrl
   put it into jsonReply
   --
   put folderUrl
   display_Json imageJSON, "imageJSON"
   display_Json jsonReply, "jsonReply"
   return jsonReply
end dreamfactory_UploadImage

command dreamfactory_TransferFile relImageFile, imageURL
   local paramArray
   -- let's tidy and check path first
   put word 1 to -1 of relFolder into relFolder
   if char -1 of relFolder is slash then
      -- it's a folder and we should be passing a file
      breakpoint
      return empty
   end if
   
   set the itemdelimiter to slash
   put item -1 of relImageFile into shortFile
   put item 1 to -2 of relImageFile & slash into relFolder
   
   -- POST http://foo.com/api/v2/files/images/?url=http://example.com/images/profile_picture.jpg
   put imageURL into paramArray ["url"]
   put dreamfactory_ConstructRestURL ("files", relFolder, paramArray) into folderUrl
   --
   _Login apiKey, pSessionToken
   rest_SetDreamFactoryHeaders apiKey, pSessionToken
   post empty to url folderUrl
   put it into jsonReply
   --
   put imageURL & CR & line 1 of url imageURL
   display_Json jsonReply, "jsonReply"
   return jsonReply
end dreamfactory_TransferFile

command dreamfactory_CreateFolder relPath
   /*
   -- put "wiki/david.icotopia.io/status/theme/" into relPath
   
   If relPath ends in a slash it is considered a folder. Else it is considered a file.
   In strange circumstances files are createsd at the root (wiki) folder.
   */
   
   local paramArray
   -- let's tidy and check path first
   put word 1 to -1 of relPath into relPath
   if char -1 of relPath is not slash then
      breakpoint
      return empty
   end if
   
   put dreamfactory_ConstructRestURL ("files", relPath, paramArray) into someURL
   -- put "http://culturecollective.cc/api/v2/files/wiki%2Fdavid.icotopia.io%2Ftest%2F" into someURL
   --
   _Login apiKey, pSessionToken
   rest_SetDreamFactoryHeaders apiKey, pSessionToken
   --
   set the itemdelimiter to slash
   put item -1 of relPath into folderInfoArray ["name"]
   put relPath into folderInfoArray ["path"]
   put json_FromArray (folderInfoArray) into folderJSON
   --
   post folderJSON to url someUrl
   put it into jsonReply
   --
   put someUrl
   display_Json folderJSON, "folderJSON"
   display_Json jsonReply, "jsonReply"
   return jsonReply
end dreamfactory_CreateFolder


--> Working on
-
private command _Login @apiKey, @sToken
   -- put dreamfactory_FileApiKey() into apiKey  
   put dreamfactory_WikiApiKey() into apiKey
   
   -- if sToken is empty then
   -- put dreamfactory_GetSessionToken() into sToken
   -- if sToken is empty then
   
   -- dreamfactory_Login "david@feast.fm", "bosmeg", apiKey
   dreamfactory_AdminLogin "david.bovill@gmail.com", "b05m3g", apiKey
   put the result into sToken
   
   -- end if
   -- end if
   return sToken
end _Login

command dreamfactory_Login uMail, pWord, pApiKey
   put dreamfactory_WikiApiKey() into pApiKey
   
   put dreamfactory_FetchLoginArray ("david@feast.fm", "bosmeg", pApiKey) into loginArray
   -- display_Array loginArray
   
   put loginArray ["session_id"] into sID
   put loginArray ["session_token"] into sToken
   --
   dreamfactory_SetSessionToken sToken
   --
   return sToken
end dreamfactory_Login

command dreamfactory_AdminLogin uMail, pWord, pApiKey
   /*
   curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' --header 'X-DreamFactory-Api-Key: 36fda24fe5588fa4285ac6c6c2fdfbdb6b6bc9834699774c9bf777f706d05a88' --header 'X-DreamFactory-Session-Token: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhY2E0ODdjMDlhNzA0OWFiNjc4YTM3ODQ4ZGNmYTI4NSIsImlzcyI6Imh0dHA6Ly9jdWx0dXJlY29sbGVjdGl2ZS5jYy9hcGkvdjIvc3lzdGVtL2FkbWluL3Nlc3Npb24iLCJpYXQiOjE1MDIyODc5MDgsImV4cCI6MTUwMjI5MTUwOCwibmJmIjoxNTAyMjg3OTA4LCJqdGkiOiJOOGVkV1JhQXo3RlJjNXhhIiwidXNlcl9pZCI6MywiZm9yZXZlciI6ZmFsc2V9.ekGzrfCKswH4L4enXyNmQSuoR19uAGciTmxO21cWNo4' -d '{
   "email": "david.bovill@gmail.com",
   "password": "b05m3g"
   }' 'http://culturecollective.cc/api/v2/system/admin/session'
   
   http://culturecollective.cc/api/v2/system/admin/session
   */
   
   put dreamfactory_WikiApiKey() into pApiKey
   
   put dreamfactory_ConstructLoginJSON (uMail, pWord) into someJSON
   dreamfactory_POST "system/admin/session", someJSON, pApiKey
   put the result into loginJSON
   put json_ToArray (loginJSON) into loginArray
   
   -- display_Array loginArray
   -- breakpoint
   --
   put loginArray ["session_id"] into sID
   put loginArray ["session_token"] into sToken
   --
   dreamfactory_SetSessionToken sToken
   --
   return sToken
end dreamfactory_AdminLogin


--> Variables
-
local DreamFactorySessionToken
local DreamFactoryApiKey

function dreamfactory_GetSessionToken
   return DreamFactorySessionToken
end dreamfactory_GetSessionToken

command dreamfactory_SetSessionToken sToken
   put sToken into DreamFactorySessionToken
end dreamfactory_SetSessionToken

function dreamfactory_GetApiKey
   return DreamFactoryApiKey
end dreamfactory_GetApiKey

command dreamfactory_SetApiKey apiKey
   put apiKey into DreamFactoryApiKey
end dreamfactory_SetApiKey

function dreamfactory_WikiApiKey
   return "c29ece1b26738412c261dc6884ac3dc14b4f24ef4910fc1ab7d370e3902b989c"
end dreamfactory_WikiApiKey

function dreamfactory_FileApiKey
   return "b5cb82af7b5d4130f36149f90aa2746782e59a872ac70454ac188743cb55b0ba"
end dreamfactory_FileApiKey


--> DreamFactory | Files | List
-
function dreamfactory_FetchFileArray
   put dreamfactory_ListFilesAndFolders() into jsonReply
   put json_ToArray (jsonReply) into jsonArray
   display_Array jsonArray
   return jsonArray
end dreamfactory_FetchFileArray
 
function dreamfactory_ListFilesAndFolders
   /*
   curl -X GET --header 'Accept: application/json' --header 'X-DreamFactory-Api-Key: 36fda24fe5588fa4285ac6c6c2fdfbdb6b6bc9834699774c9bf777f706d05a88' --header 'X-DreamFactory-Session-Token: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhY2E0ODdjMDlhNzA0OWFiNjc4YTM3ODQ4ZGNmYTI4NSIsImlzcyI6Imh0dHA6Ly9jdWx0dXJlY29sbGVjdGl2ZS5jYy9hcGkvdjIvc3lzdGVtL2FkbWluL3Nlc3Npb24iLCJpYXQiOjE1MDIyODc5MDgsImV4cCI6MTUwMjI5MTUwOCwibmJmIjoxNTAyMjg3OTA4LCJqdGkiOiJOOGVkV1JhQXo3RlJjNXhhIiwidXNlcl9pZCI6MywiZm9yZXZlciI6ZmFsc2V9.ekGzrfCKswH4L4enXyNmQSuoR19uAGciTmxO21cWNo4' 'http://culturecollective.cc/api/v2/files?include_folders=true&include_files=true&full_tree=true&zip=false'
   http://culturecollective.cc/api/v2/files?include_folders=true&include_files=true&full_tree=true&zip=false
   */
   
   put dreamfactory_WikiApiKey() into apiKey
   -- dreamfactory_Login "david@feast.fm", "bosmeg", apiKey
   dreamfactory_AdminLogin "david.bovill@gmail.com", "b05m3g", apiKey
   put the result into sToken
   
   put dreamfactory_ConstructRestURL ("files", empty, empty) into someURL
   put "?full_tree=true" after someURL
   rest_SetDreamFactoryHeaders apiKey, sToken   
   put url someUrl into jsonReply
   return jsonReply
end dreamfactory_ListFilesAndFolders

function dreamfactory_ListFiles someFolder
   -- put "wiki/david.icotopia.io/pages/" into someFolder
   /*
   curl -X GET --header 'Accept: application/json' --header 'X-DreamFactory-Api-Key: 36fda24fe5588fa4285ac6c6c2fdfbdb6b6bc9834699774c9bf777f706d05a88' 
   --header 'X-DreamFactory-Session-Token: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhY2E0ODdjMDlhNzA0OWFiNjc4YTM3ODQ4ZGNmYTI4NSIsImlzcyI6Imh0dHA6Ly9jdWx0dXJlY29sbGVjdGl2ZS5jYy9hcGkvdjIvc3lzdGVtL2FkbWluL3Nlc3Npb24iLCJpYXQiOjE1MDIyODc5MDgsImV4cCI6MTUwMjI5MTUwOCwibmJmIjoxNTAyMjg3OTA4LCJqdGkiOiJOOGVkV1JhQXo3RlJjNXhhIiwidXNlcl9pZCI6MywiZm9yZXZlciI6ZmFsc2V9.ekGzrfCKswH4L4enXyNmQSuoR19uAGciTmxO21cWNo4' '
   http://culturecollective.cc/api/v2/files/%2Fwiki/?include_properties=false&include_folders=true&include_files=true&full_tree=false&zip=false'
   
   http://culturecollective.cc/api/v2/files/%2Fwiki/?include_properties=true&include_folders=false&include_files=true&full_tree=false&zip=false
   */
   put dreamfactory_WikiApiKey() into apiKey
   
   dreamfactory_AdminLogin "david.bovill@gmail.com", "b05m3g", apiKey
   put the result into sToken
   put dreamfactory_ConstructRestURL ("files", someFolder, empty) into someURL
   -- put "http://culturecollective.cc/api/v2/files/" & someFolder  into someURL
   -- put "?include_properties=true&include_folders=false&include_files=true&full_tree=false&zip=false" after someURL -- some problem
   
   rest_SetDreamFactoryHeaders apiKey, sToken   
   put url someUrl into jsonReply
   return jsonReply
end dreamfactory_ListFiles


--> DreamFactory | Files
-
function dreamfactory_FetchFile relPath, sToken
   _Login apiKey, sToken
   put dreamfactory_ConstructRestURL ("files", relPath) into someURL
   -- put dreamfactory_ConstructRestURL ("wiki", relPath) into someURL
   --
   rest_SetDreamFactoryHeaders apiKey, sToken   
   put url someUrl into jsonReply
   switch
      case token 2 of jsonReply = "error"
         breakpoint
         -- put token 15 of someJson begins with "Token has expired:"
         put dreamfactory_WikiApiKey() into apiKey
         dreamfactory_Login "david@feast.fm", "bosmeg", apiKey
         put the result into pSessionToken
         
         rest_SetDreamFactoryHeaders apiKey, pSessionToken   
         put url someUrl into jsonReply
         return jsonReply
      case line 1 of jsonReply ="<!DOCTYPE html>"
         return empty
      default
         return jsonReply 
   end switch
end dreamfactory_FetchFile

command dreamfactory_StoreFile relPath, fileData, sToken
   -- curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' --header 'X-DreamFactory-Api-Key: 36fda24fe5588fa4285ac6c6c2fdfbdb6b6bc9834699774c9bf777f706d05a88' --header 'X-DreamFactory-Session-Token: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhY2E0ODdjMDlhNzA0OWFiNjc4YTM3ODQ4ZGNmYTI4NSIsImlzcyI6Imh0dHA6Ly9jdWx0dXJlY29sbGVjdGl2ZS5jYy9hcGkvdjIvc3lzdGVtL2FkbWluL3Nlc3Npb24iLCJpYXQiOjE1MDIyODc5MDgsImV4cCI6MTUwMjI5MTUwOCwibmJmIjoxNTAyMjg3OTA4LCJqdGkiOiJOOGVkV1JhQXo3RlJjNXhhIiwidXNlcl9pZCI6MywiZm9yZXZlciI6ZmFsc2V9.ekGzrfCKswH4L4enXyNmQSuoR19uAGciTmxO21cWNo4' -d 'Hey I\u0027ve replaced you.' 'http://culturecollective.cc/api/v2/files/%2Fwiki%2Fpages%2Fhello?check_exist=false'
   -- http://culturecollective.cc/api/v2/files/%2Fwiki%2Fpages%2Fhello?check_exist=false   
   --
   put dreamfactory_ConstructRestURL ("files", relPath) into someURL
   -- put someURL = "http://culturecollective.cc/api/v2/files/%2Fwiki%2Fdavid.icotopia.io%2Fpages%2Fhello" into someTest
   _Login apiKey, sToken
   --
   rest_SetDreamFactoryHeaders apiKey, sToken   
   --
   post fileData to url someUrl
   put it into jsonReply
   if token 2 of jsonReply = "error" then
      
   end if
   return jsonReply
end dreamfactory_StoreFile

command dreamfactory_DeleteFile relPath, sToken
   put dreamfactory_ConstructRestURL ("files", relPath) into someURL
   _Login apiKey, sToken
   rest_SetDreamFactoryHeaders apiKey, sToken   
   --
   delete url someUrl
   put it into jsonReply
   return the result
end dreamfactory_DeleteFile

function dreamfactory_FetchLoginArray uMail, pWord, apiKey
   /*
   put "36fda24fe5588fa4285ac6c6c2fdfbdb6b6bc9834699774c9bf777f706d05a88" into apiKey
   -- put "http://culturecollective.cc/api/v2/user/session" into restURL
   
   {"session_token":"[[api key]]","id":4,"name":"david","first_name":null,"last_name":null,"email":"david@feast.fm","is_sys_admin":false,"last_login_date":"2017-08-09 11:07:39","host":"Trevor"}
   */
   
   put dreamfactory_ConstructLoginJSON (uMail, pWord) into someJSON
   dreamfactory_POST "user/session", someJSON, apiKey
   put the result into loginJSON
   put json_ToArray (loginJSON) into loginArray
   return loginArray
end dreamfactory_FetchLoginArray

function dreamfactory_ConstructLoginJSON uMail, pWord
   put uMail into paramArray ["email"]
   put pWord into paramArray ["password"]
   put json_FromArray (paramArray) into someJSON
   return someJSON
end dreamfactory_ConstructLoginJSON


--> DreamFactory | RSET
-
command dreamfactory_POST apiPath, someJSON, apiKey, pSessionToken   
   /*
   {
   "email": "david@feast.fm",
   "password": "bosmeg"
   }
   'http://culturecollective.cc/api/v2/user/session
   */
   
   put "http://culturecollective.cc/api/v2/" into restURL
   put apiPath after restURL
   --
   rest_SetDreamFactoryHeaders apiKey, pSessionToken   
   post someJSON to url restURL
   put it into postResult
   --
   return postResult
end dreamfactory_POST

function dreamfactory_GET apiPath
   put "36fda24fe5588fa4285ac6c6c2fdfbdb6b6bc9834699774c9bf777f706d05a88" into apiKey
   get "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhY2E0ODdjMDlhNzA0OWFiNjc4YTM3ODQ4ZGNmYTI4NSIsImlzcyI6Imh0dHA6Ly9jdWx0dXJlY29sbGVjdGl2ZS5jYy9hcGkvdjIvc3lzdGVtL2FkbWluL3Nlc3Npb24iLCJpYXQiOjE1MDIyNzE1MzUsImV4cCI6MTUwMjI3NTEzNSwibmJmIjoxNTAyMjcxNTM1LCJqdGkiOiJNZndkUld0ak5EMWNqVEdXIiwidXNlcl9pZCI6MywiZm9yZXZlciI6ZmFsc2V9.aq9zQRiEqVCJsXwHHkBx_iDqhlzkkXxGhNc-wVe5dXY"
   put it into pSessionToken
   
   put "david@feast.fm" into paramArray ["email"]
   put "bosmeg" into paramArray ["password"]
   put json_FromArray (paramArray) into someJSON
   
   /*
   {
   "email": "david@feast.fm",
   "password": "bosmeg"
   }
   'http://culturecollective.cc/api/v2/user/session
   */
   
   rest_SetDreamFactoryHeaders apiKey, pSessionToken   
   put url someUrl into someJson
   return someJson
end dreamfactory_GET

function dreamfactory_ConstructRestURL serviceName, firstParam, pParamArray
   -- put "http://culturecollective.cc/api/v2/files/wiki/pages/hello?download=false" into someURL
   -- put "http://culturecollective.cc/api/v2/files/" & relPath into someURL
   
   put "http://culturecollective.cc/api/v2" into someURL   
   put slash & serviceName after someURL
   put slash & urlencode (firstParam) after someURL
   -- put slash & firstParam after someURL
   if pParamArray is an array then
      put "?" after someURL
      repeat for each key someKey in pParamArray
         put someKey & "=" after someURL
         put pParamArray [someKey] into paramValue
         -- url_EncodeItems paramValue
         put paramValue & "&" after someURL
      end repeat 
      delete char -1 of someURL
   end if
   return someURL
end dreamfactory_ConstructRestURL


--> REST
-
command rest_SetDreamFactoryHeaders apiKey, pSessionToken
   /*
   POST /api/v2/user/session HTTP/1.1
   > Host: culturecollective.cc
   > User-Agent: curl/7.51.0
   > Content-Type: application/json
   > Accept: application/json
   > X-DreamFactory-Api-Key: 36fda24fe5588fa4285ac6c6c2fdfbdb6b6bc9834699774c9bf777f706d05a88
   > X-DreamFactory-Session-Token: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhY2E0ODdjMDlhNzA0OWFiNjc4YTM3ODQ4ZGNmYTI4NSIsImlzcyI6Imh0dHA6Ly9jdWx0dXJlY29sbGVjdGl2ZS5jYy9hcGkvdjIvc3lzdGVtL2FkbWluL3Nlc3Npb24iLCJpYXQiOjE1MDIyNzc5ODEsImV4cCI6MTUwMjI4MTU4MSwibmJmIjoxNTAyMjc3OTgxLCJqdGkiOiJ4UHNZQmtxSVJLZ05Sb2RXIiwidXNlcl9pZCI6MywiZm9yZXZlciI6ZmFsc2V9.h7dbrRHjDkEZCelCUjhT3eL8S6gPDylyQ7LohqZNiZU
   > Content-Length: 55
   > 
   
   put "36fda24fe5588fa4285ac6c6c2fdfbdb6b6bc9834699774c9bf777f706d05a88" into apiKey
   get "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhY2E0ODdjMDlhNzA0OWFiNjc4YTM3ODQ4ZGNmYTI4NSIsImlzcyI6Imh0dHA6Ly9jdWx0dXJlY29sbGVjdGl2ZS5jYy9hcGkvdjIvc3lzdGVtL2FkbWluL3Nlc3Npb24iLCJpYXQiOjE1MDIyNzc5ODEsImV4cCI6MTUwMjI4MTU4MSwibmJmIjoxNTAyMjc3OTgxLCJqdGkiOiJ4UHNZQmtxSVJLZ05Sb2RXIiwidXNlcl9pZCI6MywiZm9yZXZlciI6ZmFsc2V9.h7dbrRHjDkEZCelCUjhT3eL8S6gPDylyQ7LohqZNiZU"
   put it into pSessionToken
   */
   
   put "Content-type: application/json" into newHeaders
   put CR & "Accept: application/json" after newHeaders
   put CR & merge ("X-DreamFactory-Api-Key: [[apiKey]]") after newHeaders
   if pSessionToken is not empty then
      put CR & merge ("X-DreamFactory-Session-Token: [[pSessionToken]]") after newHeaders
   end if
   set the httpHeaders to newHeaders
   return newHeaders
end rest_SetDreamFactoryHeaders

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
