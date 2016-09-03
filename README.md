# TapWheel
Modular and extendable iPod classic simulator for iOS

# About

I started working on this project back in September 2014. I encountered some problems with glitches and other stuff that were looking too much time, so I abandoned the whole thing. After that, many things happened, and today (Sep 3rd, 2016) I decided to pick it back up and iron out the bugs, which I did!

If you start poking around, you will see the app crash lots of times. These are, however, not bugs! it's because you tried to navigate to a part of the menu that's not yet implemented. The app uses a very modular structure of VCs and segues, and I didn't bother to implement constraints on what's not finished because the plan is to implement a full simulation (so a code that prevents that would become useless when the project is done).

The currently implemented menus are:

* Music > Playlists > *
* Music > Artists > *
* Music > Albums > *
* Music > Songs > *
* Now Playing

Any other menu will crash the app :((

Feel free to contribute (as long as you follow the existing development patter) and to fiddle around.

Oh, btw, no chance of putting this in the App Store. It is explicitly forbidden.

# Screenshots

<img src="http://i.imgur.com/jszJlqn.png" width="320px">
<img src="http://i.imgur.com/vbXfrZ2.png" width="320px">
