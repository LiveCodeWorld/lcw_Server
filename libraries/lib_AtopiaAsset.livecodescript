script "lib_AtopiaAsset"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_AtopiaAsset
type: library
version: 0.1

/*Some help*/

--> Variables
-
constant AtopiaDropletName = "Atopia"
constant AtopiaSshUser = "root"


--> Working on
-
command atopia_UploadRecording mFilePath, pTitle, pDescription, pVlogDomain
   if pVlogDomain is empty then put "vlog.mediagarden.org" into pVlogDomain
   --
   atopia_RsyncPushAssetFolder mFilePath, pVlogDomain
   put the result into pathToStore
   if pathToStore is empty then
      return ("Error, failed to upload video -" && mFilePath)
   end if
   
   if pTitle is empty then
      return empty
   else
      put empty into forkDomains
      put pageArray_GetTemplate (pVlogDomain, "Recording Template", pTitle, forkDomains) into pageArray
      --
      if pDescription is not empty then
         put pDescription into pageArray ["story"][1]["text"]
      end if
      --
      set the itemdelimiter to slash
      put item -1 of pathToStore into shortFile
      put fedwiki_ConstructAssetUrl (shortFile, pVlogDomain) into recordingURL
      --
      put fedwiki_ConstructVideoItemText ("HTML5 mp4", recordingURL, pDescription) into itemText
      pageArray_SetFirstItem pageArray, "video", itemText
      --
      put fedwiki_ConstructSlug (pTitle) into pageSlug
      --
      pageArray_Set pVlogDomain, pageSlug, pageArray
      put the result into wikiURL
      return wikiURL
   end if
end atopia_UploadRecording


--> Display | Atopia | Assets
-
command display_AtopiaAssets wikiDomain, pShortFolder
   put atopia_ListAssets (wikiDomain, pShortFolder) into assetData
   --
   if pShortFolder is empty then
      put "Assets" into sTitle
   else
      put text_InitialCaps (pShortFolder) && "Assets" into sTitle
   end if
   --
   display_Data assetData, sTitle, wikiDomain
   put the result into displayView
   display_SetInteractions displayView, "Wiki | Assets", "mDoubleUp_WikiAsset"
   return displayView
end display_AtopiaAssets


--> Atopia | Asset | Upload | Rsync
-
command atopia_RsyncPushAssetFolder localFile, wikiDomain, pShortFolder
   set the cursor to watch
   set the itemdelimiter to slash
   put item -1 of localFile into shortFile
   put atopia_WikiAssetFile (wikiDomain, shortFile, pShortFolder) into fullPath
   atopia_CreateAssetFolder wikiDomain, pShortFolder
   --
   put rsync_ConstructFolderPushShell (localFile, fullPath, "root", "fedwiki.org") into someShell
   put shell (someShell) into shellResult
   return the result
end atopia_RsyncPushAssetFolder

command atopia_StoreAssetData wikiDomain, shortFile, someData, pShortFolder
   -- saves data to temp file and uploads file with scp
   set the cursor to watch
   put atopia_WikiAssetFile (wikiDomain, shortFile, pShortFolder) into somePath
   put atopia_PathExists (somePath) into someBoolean
   if someBoolean is true then return "error, asset exists at" && somePath
   --
   atopia_StoreData somePath, someData -- uses server_StoreFile / scp
   put the result into shellResult
   return shellResult
end atopia_StoreAssetData

command atopia_StoreAssetFile wikiDomain, shortFile, localFile, pShortFolder
   set the cursor to watch
   put atopia_WikiAssetFile (wikiDomain, shortFile, pShortFolder) into somePath
   put atopia_PathExists (somePath) into someBoolean
   if someBoolean is true then return "error, asset exists at" && somePath
   --
   atopia_StoreFile localFile, somePath
   put the result into shellResult
   return shellResult
end atopia_StoreAssetFile


--> Atopia | Asset
-
function atopia_FetchAsset somePath
   -- ie fetch some json
   put digitalOcean_FetchFile (somePath, AtopiaDropletName, AtopiaSshUser) into someJSON
   if item 1 of someJSON = "error" then
      breakpoint
      resetall
      put digitalOcean_FetchFile (somePath, AtopiaDropletName, AtopiaSshUser) into someJSON
   end if
   return someJSON
end atopia_FetchAsset

function atopia_ListAssets wikiDomain, pSubFolder
   put atopia_FetchAssetFileArray (wikiDomain, pSubFolder) into fileArray
   put keys (fileArray) into shortFiles
   return shortFiles
end atopia_ListAssets

function atopia_FetchAssetFileArray wikiDomain, pSubFolder
   put atopia_WikiAssetsFolder (wikiDomain, pSubFolder) into assetsFolder
   put atopia_FetchLsArray (assetsFolder) into infoArray
   put infoArray ["file"] into fileArray
   return fileArray
end atopia_FetchAssetFileArray

command atopia_DeleteAsset pathToDelete
   digitalOcean_DeleteFile pathToDelete, AtopiaDropletName, AtopiaSshUser
   put the result into shellResult
   return shellResult
end atopia_DeleteAsset


--> Atopia | Asset | Files
-
command atopia_CreateAssetFolder wikiDomain, pShortFolder
   put atopia_WikiAssetsFolder (wikiDomain) into assetsFolder
   --
   put atopia_PathExists (assetsFolder) into someBoolean
   if someBoolean is true then return false
   
   -- create assets folder
   shell_BashParamEscape assetsFolder
   put "mkdir" && assetsFolder into remoteShell
   atopia_DoRemoteShell remoteShell
   
   -- now repeat over pShortFolder
   return true
end atopia_CreateAssetFolder

function atopia_AssetFolderExists wikiDomain
   put atopia_WikiAssetsFolder (wikiDomain) into assetsFolder
   put atopia_PathExists (assetsFolder) into someBoolean
   return someBoolean
end atopia_AssetFolderExists

function atopia_WikiHomeFolder wikiDomain
   put wikiDomain & "/assets/home/" into relFolder
   return atopia_WikiFolder (relFolder)
end atopia_WikiHomeFolder

function atopia_WikiAssetFile wikiDomain, shortFile, pShortFolder
   if pShortFolder is not empty then
      text_AddTrailing pShortFolder, slash
      put pShortFolder before shortFile
   end if
   put atopia_WikiAssetsFolder (wikiDomain) & shortFile into assetFile
   return assetFile
end atopia_WikiAssetFile

function atopia_WikiAssetsFolder wikiDomain, pSubFolder
   put wikiDomain & "/assets/" into relFolder
   if pSubFolder is not empty then
      text_AddTrailing pSubFolder, slash
      put pSubFolder after relFolder
   end if
   put atopia_WikiFolder (relFolder) into assetsFolder
   return assetsFolder
end atopia_WikiAssetsFolder


--> Deps
-
