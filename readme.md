NOTE NOT FINISHED DO NOT INSTALL

==VI3 Vim-like keybindings for i3wm==

vi3 provides a config file that impliments vim like keybindings with i3 style modes and fish functions.  Most functionality is implimented via the op mode.  Essentially vi3op is set to the desired
operation and we enter the op mode.  When an additional letter key is pressed the desired operation is evaluated with this letter as an argument.  To enter command mode tap the Super or windows key.

==Functionality includes==
- Super -> w<a-z> switch to workspace<a-z> tap either shift key as a shortcut for Super -> w
- Super -> g<a-z> get windows from workspace<a-z> and place them on the current workspace
- Super -> m<a-z> move window to workspace<a-z>

== installation ==
vi3 requires fish shell 2.x and python.  Functionality is enhansed by installing feh imagemagick xdotool xmodmap xcape.

To install clone this repo to /opt/vi3 and run ff vi3_first-run
