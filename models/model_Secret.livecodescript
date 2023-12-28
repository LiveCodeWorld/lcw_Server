script "model_Secret"
--> MetaData
-
license: GPLv3
name: model_Secret
type: model
version: 0.3

/*
At the moment we store secrets in the config.lc file on the server
But on the desktop we usually use a separate array file per project.
These arrays need to be stored outside of the projects which are checked into Github

This library is for storing and fetching secrets. Passwords and REST authentication secrets.
It is important that this code does not hold any actual secrets as it will be stored in the open on GitHub.
Actual secrets will be stored in a secure way on a per-platform basis, taking advantages of the features of each platform.

By keeping all handlers here we can avoid graphing of uneseccary dependencies for each library that uses a secret. 
Desktop "user_Array" handlers for instance have a lot of dependencies that servers do not need.

The library is so small is should probably be combined with a general lib_REST library.
At the moment we avoid adding this library as a dependency for transporters by adding the following handler as a dependency handler:

'''
function secret_Get secretName
   -- for server use only
   if the environment is not "server" then pass "secret_Get"
   --
   put rigFetchConfigItem (secretName) into someSecret
   return someSecret
end secret_Get
'''
*/


--> Secret
-
function secret_Get secretName, pArrayKey
   if the environment = "server" then
      put rigFetchConfigItem (secretName) into someSecret
   else
      put _ConstructShortArrayFile (pArrayKey) into shortArrayFile
      put user_GetValue (secretName, shortArrayFile) into someSecret
   end if
   return someSecret
end secret_Get

command secret_Set secretName, secretValue, pArrayKey
   put _ConstructShortArrayFile (pArrayKey) into shortFile
   user_SetValue secretName, shortFile, secretValue
   put the result into modelFile
   return modelFile
end secret_Set

command secret_GetArray pArrayKey
   put _ConstructShortArrayFile (pArrayKey) into shortArrayFile
   put user_GetArray (shortArrayFile) into userArray
   return userArray
end secret_GetArray

command secret_AddArray newArray, pArrayKey
   put _ConstructShortArrayFile (pArrayKey) into shortArrayFile
   user_AddArray shortArrayFile, newArray
   put the result into modelFile
   return modelFile
end secret_AddArray

command secret_SetArray userArray, pArrayKey
   put _ConstructShortArrayFile (pArrayKey) into shortArrayFile
   user_SetArray shortArrayFile, userArray
   put the result into modelFile
   return modelFile
end secret_SetArray


--> Local
-
function secret_GetLocalArray pArrayKey
   put _ConstructShortArrayFile (pArrayKey) into shortFile
   put user_GetArray (shortFile) into secretArray
   return secretArray
end secret_GetLocalArray


--> Private
-
private function _ConstructShortArrayFile pArrayKey
   -- "pinterest_Authentication.array" or "secret_Authentication.array" (default)
   if pArrayKey is empty then put "secret" into pArrayKey
   put tolower(pArrayKey) & "_Authentication.array" into shortFile
   return shortFile
end _ConstructShortArrayFile
