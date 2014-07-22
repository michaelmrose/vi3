#Vi3

###VI3 Vim-like keybindings for i3wm implimented with fish shell and a little python

vi3 provides a config file that impliments vim like keybindings with i3 style modes and fish functions.  Most functionality is implimented via the op mode.  

Essentially vi3op is set to the desired operation and we enter the op mode.  When an additional letter key is pressed the desired operation is evaluated with this letter as an argument.  

Operations that require more than one key are implimented via vi3_take-n which is called with the function to evaluate and the number of characters to accept before executing to create a function that is bound in your i3 config.

Additionally commonly used apps are bound to letter and any function that needs to use this association simply calls app-switch on the letter given.

##Interaction Mode
- Super + v ?? -> Set volume to ??
- Super + t ?? -> Set transparency of current window to ??
- Super + a enter audio mode
- Tap Super_L to go to command mode
- Super + hjkl change focus

##Command Mode
### Operations which do NOT terminate command mode 
- hjkl change focus
- Shift+hjkl shift window
- 1-4 set the size of the next window opened via o from aprox 20% to 40%
- v sets the alignment of the next opened window with current to be vertical
- s sets the alignment of the next opened window with current to be horizontal

### Operations that end command mode
- w[a-z] switch to workspace[a-z] tap either shift key as a shortcut for Super -> w
- g[a-z] get all windows from workspace[a-z] and place them on the current workspace
- m[a-z] move window to workspace[a-z] remaining on current workspace
- t[a-z] take window to workspace[a-z] and move focus to this workspace
- f[a-z] focus applications[a-z]
- o[a-z] open application[a-z]
- F[a-z] fetch most recently opened application[a-z] and move it to current workspace
- R[a-z][a-z] relocate windows from workspace 1 to workspace 2 without changing current workspaces without changing current workspaces
- r enter resize mode same as default resize mode in i3
- n cycle through all windows with the same window class as current window eg all firefox instances
- q quit current app
- dd kill all apps in workspace
- da kill all apps on currently visible workspaces ie on all monitors
- af toggle floating
- ah arrange horizontally
- av arrange verticly
- as arrange stacked
- at arrange tabbed
- c capslock no idea why an entire useful key is devoted to this, especially when it can be better used for escape
- Escape go back to interaction mode

#### example usage 2vot open a small terminal window below current focused window

##Audio Mode
- h prev track
- l next track
- j volume down 5%
- k volume up 5%
- Space toggle playback
- n make the next audio output the default and send all currently playing streams to it
- m mute

##Convenience Functions
- wp sets your background with feh and converts file via imagemagick for usage with i3lock
- lock will run i3lock with the image created with wp
- colorscheme somename will look for somename in ~/.i3/colors/somename and use it to fill in the part of your i3 config that deals with colors font and bar style. Please see the included greenandyellow colorscheme
- saveme name will save a prospective session via saving a layout json file with i3-save-tree and a script file which will be opened it $EDITOR for you to add any programs that should be opened with that session 
- restoreme name will run ~/sessions/name and load the layout from ~/.i3/sessions/name.json


== installation ==
vi3 requires fish shell 2.x and python.  Functionality is enhansed by installing feh imagemagick xdotool xmodmap xcape.

To install clone this repo to /opt/vi3 and run ff vi3_first-run
THIS WILL OVERWRITE YOUR CURRENT I3 CONFIG BACK IT UP
