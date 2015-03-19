# GMailinator

Adds Gmail-esque keyboard shorcuts to Mail.app.  This is still very much a work
in progress.  Tested with Mail for OS X 10.8.4.

## Supported Shortcuts

<table>
  <tr><th>Key</th><th>Action</th></tr>
  <tr><td>c</td><td>Compose new message</td></tr>
  <tr><td>r</td><td>Reply</td></tr>
  <tr><td>a</td><td>Reply All</td></tr>
  <tr><td>y, e</td><td>Archive</td></tr>
  <tr><td>#</td><td>Delete</td></tr>
  <tr><td>j</td><td>Go to previous message/thread</td></tr>
  <tr><td>k</td><td>Go to next message/thread</td></tr>
  <tr><td>/</td><td>Mailbox search</td></tr>
  <tr><td>l</td><td>Move to folder (opens dialog)</td></tr>
  <tr><td>s</td><td>Flag</td></tr>
  <tr><td>tab, then enter</td><td>Send message</td></tr>
</table>

## How to install

1. Grab the latest build from the builds/ directory, and unzip to ~/Library/Mail/Bundles
2. Enable Mail.app plugins:
       `defaults write com.apple.mail EnableBundles -bool true`

## How to build

1. Load up the project in Xcode.
2. Run the build, this should automatically create ~/Library/Mail/Bundles (but you may need to create this).
3. Enable Mail.app plugins:
       `defaults write com.apple.mail EnableBundles -bool true`
4. Relaunch Mail.

## Credits

A lot of this was built with heavy use of of the
[BindDeleteKeyToArchive](https://github.com/benlenarts/BindDeleteKeyToArchive)
project by Ben Lenarts.  The Xcode project and interface skeleton were
all from that project, and for the most part, renamed.  I added the keybinding code.

A lot of the code is also either copied in whole, or modified from the
Nostalgy4Mail.app project, by [Hajo Nils
Krabbenhöft](https://github.com/fxtentacle/Nostalgy-4-Mail.app), and
subsequently by [Jelmer van der
Linde](https://github.com/jelmervdl/Nostalgy-4-Mail.app). I've added support
for ARC (turns out there were quite a few leaks), and prettied-up (imho) the
move-to-folder dialog.

Other references:

- [Rui Carmo's PyObjC vim keybinding script](http://taoofmac.com/space/blog/2011/08/13/2110)
