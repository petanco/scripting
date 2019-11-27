# Bash scripting

Bash based script that, inputting some information and a .CSV curated file, is able to:

  1- Read a .CSV curated file, which column separator is a semicolon ';'  
  
  2- Get the last added uidNumber to your LDAP Server and insert the new users one number above  
  
  3- Generate a .LDIF file with all the passed users from the .CSV  
  
  4- Show the user the first entry in that .LDIF file, the last entry and the total number of entries  
  
  5- Ask for confirmation  
  
  6- Run the .LDIF file and add the users to the LDAP Server  
  
  7- Show the user the last two user details so he/she can assure that the command has been run correctly  
  
You need csv_to_ldap.sh and ldifCSV.csv files to run the script.

Run csv_to_ldap.sh and follow instructions.

To use your own .csv:

  - It must have 4 columns separated with semicolon ';'
  
  - The first column can be anything, for example a number for each entry but it is not used in the proccess.
  
  - Second column the uid name. It can´t have spaces
  
  - Third column is the Organizational Unit. It must be created manually before running the program
  
  - Fourth and last column is for User details.
  
  
Enjoy :)
