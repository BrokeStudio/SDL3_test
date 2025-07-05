project "Demo"
language "C++"
cppdialect "C++17"
targetdir "Binaries/%{cfg.buildcfg}"
debugdir "Binaries/%{cfg.targetdir}"
staticruntime "on"
targetname "Demo"

files {
  "Source/**.h", "Source/**.cpp",

  "../External/SDL3/include/**.h",
  "../External/imgui/*.h", "../External/imgui/*.cpp",
  "../External/imgui/backends/**.h", "../External/imgui/backends/**.cpp",
}

vpaths {
  ["SDL3"] = {
    "../External/SDL3/include/**.h",
  },
  ["ImGui"] = {
    "../External/imgui/*.h",
    "../External/imgui/*.cpp",
    "../External/imgui/backends/*.h",
    "../External/imgui/backends/*.cpp",
  }
}

includedirs {
  "Source",

  "../External/imgui",
  "../External/imgui/backends",
  "../External/SDL3",
}

targetdir("../Binaries/" .. OutputDir .. "/%{prj.name}")
objdir("../Binaries/Intermediates/" .. OutputDir .. "/%{prj.name}")

-- Windows / Linux / macOS

filter "configurations:Debug"
  kind "ConsoleApp"
  defines { "_DEBUG" }
  runtime "Debug"
  symbols "On"

filter "configurations:Release"
  kind "ConsoleApp"
  defines { "_RELEASE" }
  runtime "Release"
  optimize "On"
  symbols "On"

-- Windows

filter "system:windows"
  -- files { '../Windows/Resources/resources.rc', '**.ico' }
  -- vpaths { ["Resources"] = { "../Windows/Resources/*.rc", "../Windows/Resources/*.ico" } }
  systemversion "latest"
  defines {
    "_CRT_SECURE_NO_WARNINGS",
    -- "SDL_MAIN_HANDLED", -- to avoid SDL_main
  }
  includedirs {
      "../External/SDL3/include"
  }
  links {
      "winmm.lib",
      "setupapi.lib",
      "version.lib",
      -- "Imm32.lib",
      "opengl32",

      "SDL3"
  }

filter { "system:windows", "configurations:Debug" }
  libdirs {
      "../External/SDL3/lib/x86-static-debug"
  }

filter { "system:windows", "configurations:Release" }
  libdirs {
      "../External/SDL3/lib/x86-static-release"
  }

filter { "system:windows", "configurations:Dist" }
  kind "WindowedApp"
  defines { "_DIST" }
  runtime "Release"
  optimize "On"
  symbols "Off"
  targetdir("../Binaries/" .. OutputDir .. "/Demo")
  entrypoint "mainCRTStartup"
  libdirs {
      "../External/SDL3/lib/x86-static-release"
  }
  postbuildcommands {
    "{DELETE} \"../Binaries/" .. OutputDir .. "/Demo/Demo.exp\"",
    "{DELETE} \"../Binaries/" .. OutputDir .. "/Demo/Demo.lib\""
  }

-- Linux

filter "system:linux"
  -- buildoptions "`sdl3-config --cflags`"
  -- linkoptions "-lGL -lX11 -lXext -lXrandr -lXrender -lXinerama -lXi -lXcursor `sdl3-config --libs` -static"
  -- linkoptions { "-static-libsan" }
  -- -lasound -lpulse
  libdirs {
    "../External/SDL3/lib/linux"
  }
  includedirs {
    "../External/SDL3/include",
  }
  links {
        -- "SDL3", -- Pour libSDL3.a
        "GL",   -- Pour libGL.so (OpenGL)
        -- "X11",
        -- "Xext",
        -- "Xrandr",
        -- "Xrender",
        -- "Xinerama",
        -- "Xi",
        -- "Xcursor",
        -- "asound",
        -- "pulse",
        "dl",
        -- "pthread"

    "pthread",
    "SDL3" -- ou le chemin vers libSDL3.a si nécessaire
  }

filter { "system:linux", "configurations:Dist" }
  kind "WindowedApp"
  defines { "_DIST" }
  runtime "Release"
  optimize "On"
  symbols "Off"
  targetdir("../Binaries/" .. OutputDir .. "/Demo")

-- macOS

filter "system:macosx"
  linkoptions {
    "-framework OpenGL -framework CoreFoundation",
    "-framework CoreVideo -framework AudioToolbox -framework Carbon -framework IOKit",
    "-framework Cocoa -framework ForceFeedback -framework CoreAudio",
    "-framework Foundation -framework Metal",
    "-framework GameController -framework CoreHaptics",
    "-static-libsan",
  }
  links {
    "pthread",
    "m",
    "dl",
    "iconv",
    "SDL3"
  }
  libdirs {
    "../External/SDL3/lib/macOS"
  }
  includedirs {
    "../External/SDL3/include",
    "../macOS"
  }

filter { "configurations:Dist", "system:macosx" }
  kind "ConsoleApp"
  defines { "_DIST" }
  runtime "Release"
  optimize "On"
  symbols "Off"
  targetdir("../Binaries/" .. OutputDir .. "/Demo")
  postbuildcommands {
    "{RMDIR} \"%{cfg.targetdir}/Demo.app\"",
    "{MKDIR} \"%{cfg.targetdir}/Demo.app\"",
    "{MKDIR} \"%{cfg.targetdir}/Demo.app/Contents\"",
    "{MKDIR} \"%{cfg.targetdir}/Demo.app/Contents/MacOS\"",
    "{MKDIR} \"%{cfg.targetdir}/Demo.app/Contents/Resources\"",
    "{COPY} \"../macOS/Info.plist\" \"%{cfg.targetdir}/Demo.app/Contents\"",
    "{COPY} \"%{cfg.targetdir}/Demo\" \"%{cfg.targetdir}/Demo.app/Contents/MacOS\"",
    "{COPY} \"../macOS/Rainbow.png\" \"%{cfg.targetdir}/Demo.app/Contents/Resources\"",
  }
