Ä¿Â¼½á¹¹£º
- |-build/
  | Will contain any build modules (currently nothing here as it is all
  | hacked into the JakeFile)
  |
  |-lib
  |  |-xFace.js
  |  | Common Cordova stuff such as callback handling and
  |  | window/document add/removeEventListener hijacking 
  |  | 
  |  |-common/
  |  | Contains the common-across-platforms base modules
  |  |
  |  |-common/builder.js
  |  | Injects in our classes onto window and navigator (or wherever else 
  |  | is needed)
  |  |
  |  |-common/channel.js
  |  | A pub/sub implementation to handle custom framework events 
  |  |
  |  |-common/common.js
  |  | Common locations to add Cordova objects to browser globals.
  |  |
  |  |-common/exec.js
  |  | Stub for platform's specific version of exec.js
  |  |
  |  |-common/platform.js
  |  | Stub for platform's specific version of platform.js
  |  |
  |  |-common/utils.js
  |  | General purpose JS utility stuff: closures, uuids, object
  |  | cloning, extending prototypes
  |  |
  |  |-common/extension
  |  | Contains the common-across-platforms extension modules
  |  |
  |  |-scripts/
  |  | Contains non-module JavaScript source that gets added to the
  |  | resulting cordova.<platform>.js files closures, uuids, object
  |  |
  |  |-scripts/bootstrap.js
  |  | Code to bootstrap the Cordova platform, inject APIs and fire events
  |  |
  |  |-scripts/require.js
  |  | Our own module definition and require implementation. 
  |  |
  |  |-<platform>/
  |  | Contains the platform-specific base modules.
  |  |
  |  |-<platform>/extension/<platform>
  |  | Contains the platform-specific extension modules.

Usage:
Command 1:
jake build[<platform>]
Build the js source files, and generated xface.js.
<platform> could be android, ios or wp8.
Example:
jake build[android]

Command 2:
jake doc[<proj>,<destDir>]
Analyze the js source files, and generated api reference of js.
<proj> is the project name that you want to be analyze. Default value is xface.
<destDir> is the path of dest directory which the document will be saved. Default value is jsdoc.
Available: cmbc, paas, tydk, unionpay, xface
The generated doc files is in path destDir or xface/js/jsdoc.
Example: 
jake doc
(The js api reference of project xface will be generated in folder jsdoc of current directory)
jake doc[cmbc,F:/jsapi]
(The js api reference of project cmbc will be generated in path [F:/jsapi])