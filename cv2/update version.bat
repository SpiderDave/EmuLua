@echo off
set stage=beta

rem create lua file for automatic versioning
set mydate=%date:~-4,4%.%date:~-10,2%.%date:~-7,2%
echo version={stage="%stage%", date="%mydate%", time="%time%"}>version.lua
