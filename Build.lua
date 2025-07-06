-- premake5.lua
workspace "Demo"
  startproject "Demo"
  configurations { "Debug", "Release", "Dist" }

  -- Workspace-wide build options for MSVC
  filter "system:windows"
    platforms { "x86", "x86_64" }
    buildoptions { "/EHsc", "/Zc:preprocessor", "/Zc:__cplusplus" }
    linkoptions { "/SAFESEH:NO" } -- Image Has Safe Exception Handers: No

  filter "system:linux"
    architecture "x64"

  filter "system:macosx"
    architecture "universal"

OutputDir = "%{cfg.system}-%{cfg.architecture}/%{cfg.buildcfg}"

include "Demo/Build-Demo.lua"
