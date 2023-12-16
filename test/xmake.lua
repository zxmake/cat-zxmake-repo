add_repositories("my-repo https://github.com/TOMO-CAT/xmake-repo.git")

add_rules("plugin.compile_commands.autoupdate", {outputdir = "."})
add_rules("mode.release", "mode.debug")
set_languages("c++17")

-- add_requires("microhttpd 0.9.77")
add_requires("httpmockserver 1.0.0")
add_requires("gtest")

target("test", function()
    add_files("test/test.cc")
    add_packages("gtest")
    add_packages("httpmockserver")
end)
