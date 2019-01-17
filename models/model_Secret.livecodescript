script "model_Secret"
--> MetaData
-
license: GPLv3
name: model_Secret
type: model
version: 0.2

/*
This library is for storing and fetching secrets. Passwords and REST authentication secrets.
It is important that this code does not hold any actual secrets as it will be stored in the open on GitHub.
Actual secrets will be stored in a secure way on a per-platform basis, taking advantages of the features of each platform.

By keeping all handlers here we can avoid graphing of uneseccary dependencies for each library that uses a secret. 
Desktop "user_Array" handlers for instance have a lot of dependencies that servers do not need.

The idea is that there would be two libraries that we can swap in and out for different platforms,
as each platform stores secrets in different ways.

For now we use the environment switch to allow a single interface to stroing secrets on all platforms.
*/


--> Variables
-
local SecretArray


--> Secret
-
function secret_Get secretName, arrayKey
   /*
   At the moment we store secrets in the config.lc file on the server
   and don't use specific files or database keys.
   
   But on the desktop we usually use a separate array file per project.
   This is something that eventualy the server should probably use as well.
   */
   
   if the environment = "server" then
      -- at the moment does not use arrayKey
      put rigFetchConfigItem (secretName) into someSecret
   else
      put _ConstructShortArrayFile (arrayKey) into shortFileFile
      put user_GetValue (secretName, shortFileFile) into someSecret
   end if
   return someSecret
end secret_Get

command secret_Set secretName, arrayKey, secretValue
   if the environment = "server" then return empty -- not working on server
   --
   put _ConstructShortArrayFile (arrayKey) into shortFileFile
   user_SetValue secretName, shortFileFile, secretValue
   put the result into modelDataFile
   return modelDataFile
end secret_Set

function secret_GetCached secretName, arrayKey
   put SecretArray [arrayKey][secretName] into someSecret
   if someSecret is not empty then return someSecret -- cached
   
   put secret_Get (secretName, arrayKey) into someSecret
   put someSecret into SecretArray [arrayKey][secretName]
   return someSecret
end secret_GetCached


--> Private
-
private function _ConstructShortArrayFile arrayKey
   -- "pinterest_Authentication.array"
   put arrayKey & "_Authentication.array" into shortFileFile
   return shortFileFile
end _ConstructShortArrayFile
