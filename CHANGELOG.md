### 20 April 2020 - Version 2.0.0
Added with_out scope, Added ability to give a user multiple roles at the same time. Updated to support Rails 6.x

### 12 March 2019 - Version 2.0.0.beta
Updated to support Rails 5.x

### 18 August 2011 - Version 2.0.0.beta
Rewrite the whole gem to be more modular, API is exactly the same
Only supports Rails 3.x

### 06 September 2010 - Version 1.1.0
Fixed the issue where the is_user? method was not working through association, if the is_user? method had not been called before
Wrote tests (FINALLY!!!)

### 05 April 2010 - Version 1.0.0
Serialize method updated for Rails 3 compatibility. (Thanks to firebelly for pointing this out)

### 03 February 2010 - Version 0.4.2
Fixed migration names
Does not allow duplicates to be added

### 08 December 2009 - Version 0.4.1
Added a bitmask migration generator (Read below for usage)

### 08 December 2009 - Version 0.4.0
Added the ability to use bitmasks instead of serializing the roles in a table (Read below on how to setup and use)

### 17 November 2009 - Version 0.3.0
Added a generator to generate the database columns "script/generate easy_roles Table Column_Name"

### 21 October 2009 - Version 0.2.0
Added bang methods for 'add_role' and 'remove_role' which can be accessed through 'add_role!' and 'remove_role!' respectively.