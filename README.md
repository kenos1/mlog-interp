# mlog-interp (I have not made a good name for this)

A mindustry logic interpreter made in Lua. Very W.I.P.

## Getting started

This project requires
- Lua 5.4 (PUC, LuaJIT won't work)
- Git

```sh
# Clone the repo
git clone https://github.com/kenos1/mlog-interp.git

cd mlog-interp

# Get dependencies
git submodule init
git submodule update

# Run the program
lua main.lua
```

## Features

- A pure testing environment
- Infinite memory (though you should probably limit your usage)

## Compatibility

Because this is a work in progress project, compatibility with in-game logic is not guaranteed. I also need to write tests to make sure everything works correctly.

## To-Do

- Strict mode
    - Error on improperly handled null values
    - Strong type checking?
- Unit control (kinda)
- Building control
- Game data
- SVG output for display logic
- Lots of missing functions
- World processor logic
- Controlled side effects (unit positions, building positions, etc.)
- A CLI
