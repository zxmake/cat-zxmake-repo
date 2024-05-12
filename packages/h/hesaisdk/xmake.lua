package("hesaisdk", function()
    set_homepage("https://github.com/HesaiTechnology/HesaiLidar_SDK_2.0")
    set_urls(
        "https://github.com/HesaiTechnology/HesaiLidar_SDK_2.0/archive/7d00ebe715d22eecbd08fc97016b4d7182d5a0e6.zip")
    add_versions("2.0.0",
                 "21efef0902c024c33658d6b15a5e5972b1ccc59727622161162c9302223b2794")
    add_deps("boost 1.82.0")

    on_install(function(package)
        io.writefile("xmake.lua", [[
            add_requires("boost 1.82.0")

            add_rules("mode.debug", "mode.release")
            set_languages("c++17")
            add_cxxflags("-Wno-c++11-narrowing")
            target("hesaisdk", function()
                set_kind("shared")
                add_files("libhesai/**.cc")
                remove_files("libhesai/Container/src/*.cc", "libhesai/UdpParser/src/*.cc",
                             "libhesai/UdpParser/*.cc", "libhesai/Lidar/*.cc")
                add_headerfiles("(**.h)", "(**.hpp)", "(**.cc)")
                add_includedirs("libhesai/PtcClient/include", "libhesai/PtcParser/include",
                                "libhesai/UdpParser/include", "libhesai/include", "driver",
                                "libhesai/Lidar", "libhesai/Source/include",
                                "libhesai/Container/include", "libhesai/Logger/include",
                                "libhesai/Container/src", "libhesai", "libhesai/PtcParser",
                                "libhesai/UdpParser", "libhesai/UdpParser/src",
                                "libhesai/UdpProtocol")
                add_packages("boost")
            end)
            
        ]])
        import("package.tools.xmake").install(package)
    end)
    -- on_test(function(package)
    --     assert(package:has_cxxtypes("hesai::lidar::HesaiLidarSdk",
    --                                 {includes = "driver/hesai_lidar_sdk.hpp"}))
    -- end)
end)
