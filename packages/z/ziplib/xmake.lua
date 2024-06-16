package("ziplib", function()
    set_homepage("https://github.com/hsmith/ziplib.git")
    -- set_urls("https://github.com/hsmith/ziplib.git")
    set_urls(
        "https://github.com/hsmith/ziplib/archive/6a7ada3cf1b438c4e56326f8faeb04b2cad765f2.zip")

    add_versions("1.0.0",
                 "c31ceb7038466570af74b49a3e5e6798f757334962ba0f6130bf3248e5fd7722")

    on_install(function(package)
        io.writefile("xmake.lua", [[
            add_rules("plugin.compile_commands.autoupdate", {outputdir = "."})

            set_config("cxx", "clang++")
            set_config("cc", "clang")
            set_config("ld", "clang++")
            
            set_languages("c++11", "c11")
            add_includedirs(os.projectdir())
            add_sysincludedirs("/usr/include/opencv4")
            add_sysincludedirs("/usr/include/pcl-1.10")
            add_cxxflags("-Wall", "-Wextra", "-Werror", "-Wno-unused-function",
                         "-Wno-unused-parameter")
            set_optimize("fastest")
            add_cxflags("-g", "-fPIC")
            add_ldflags("-Wl,--export-dynamic", "-Wl,--build-id")
            if is_arch("x86.*") then add_ldflags("-flto=thin") end
            
            add_cxxflags("-Wno-error,-Wsign-compare")
            add_cxxflags("-Wno-unknown-warning-option")
            add_cxxflags("-Wno-deprecated-declarations")
            add_cxxflags("-Wno-sign-compare")
            add_cxxflags("-Wno-unused-but-set-variable")
            add_cxxflags("-Wno-delete-non-abstract-non-virtual-dtor")
            add_cxxflags("-Wno-reorder-ctor")
            
            target("bzip2", function()
                set_kind("object")
                add_files("Source/ZipLib/extlibs/bzip2/*.c")
            end)
            
            target("lzma", function()
                set_kind("object")
                add_files("Source/ZipLib/extlibs/lzma/unix/**.c")
            end)
            
            target("zlib", function()
                set_kind("object")
                add_files("Source/ZipLib/extlibs/zlib/*.c")
            end)
            
            target("ziplib", function()
                set_kind("static")
                add_files("Source/ZipLib/detail/*.cpp")
                add_files("Source/ZipLib/*.cpp")
                add_deps("bzip2", "lzma", "zlib")
            
                add_headerfiles("Source/(ZipLib/**.h)")
            end)
        ]])
        import("package.tools.xmake").install(package)
    end)
end)
