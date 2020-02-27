title: Lua Install

Git Submodule
------------

!!! info
	This process requires knowledge of [rojo](https://github.com/rojo-rbx/rojo).

To use Snapdragon as a git submodule, you need to do the following:

Run the command

```
git submodule add https://github.com/roblox-aurora/rbx-snapdragon.git <targetfolder>
```
e.g. if you wanted it in modules/snapdragon: 
```
git submodule add https://github.com/roblox-aurora/rbx-snapdragon.git modules/snapdragon
```

Then in your `*.project.json` folder, simply point it to `<targetfolder>` for the Lua output (e.g. in the above example, `modules/snapdragon`.