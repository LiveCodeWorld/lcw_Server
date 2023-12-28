script "lib_Kagi"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Kagi
type: library
version: 0.1

/*Some help*/


--> Working on
-


--> Kagi
-
function kagi_GetApiToken
   return secret_Get ("Kagi")
end kagi_GetApiToken

command kagi_SetApiToken apiToken
   secret_Set "Kagi", apiToken
   return the result
end kagi_SetApiToken


--> Deps
-
