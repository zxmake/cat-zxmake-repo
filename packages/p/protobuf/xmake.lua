package("protobuf", function()
    set_homepage("https://developers.google.com/protocol-buffers/")
    set_description("Google's data interchange format for cpp")

    -- https://github.com/protocolbuffers/protobuf/issues/4958
    -- 这个版本的 protobuf 必须带上 -lpthread, 否则会报错:
    -- terminate called after throwing an instance of 'std::system_error'
    --   what():  Unknown error -1
    -- Aborted (core dumped)
    add_syslinks("pthread")

    -- https://github.com/protocolbuffers/protobuf/releases/download/v21.7/protobuf-cpp-3.21.7.zip
    -- add_urls(
    --     "https://github.com/protocolbuffers/protobuf/releases/download/v$(version)/protobuf-cpp-3.$(version).zip")
    -- 下载 tag
    -- add_urls(
    --     "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v3.$(version).zip")

    add_urls("https://github.com/protocolbuffers/protobuf/releases/download/v$(version)", {
        version = function(version)
            local ver = tostring(version)
            if ver == "3.21.7" then
                return "21.7/protobuf-cpp-" .. version .. ".zip"
            else
                return version .. "/protobuf-cpp-" .. version .. ".zip"
            end
        end
    })

    add_versions("3.21.7", "87f3265aac463cbca6ca5c23a52a75aebbf645c986f521e68c13259d138b2874")
    -- 和 ubuntu 20.04 自带的 protobuf 版本对齐
    add_versions("3.6.1", "ced3d566b14ccee1e6e96a2cc8dc7c4a3e92bf2d637c3ccf794d018d860647f4")
    -- 和 ubuntu 22.04 自带的 protobuf 版本对齐
    add_versions("3.12.4", "5ad4cf085cfd866043dc1035c8f8e97e6968573a2d117e054e2a890eb19259d1")
    add_configs("zlib", {description = "Enable zlib", default = true, type = "boolean"})

    add_deps("cmake")

    add_links("protobuf")

    on_load(function(package)
        package:addenv("PATH", "bin")
        if package:config("zlib") then
            package:add("deps", "zlib")
        end
    end)

    on_install(function(package)
        os.cd("cmake")
        io.replace("CMakeLists.txt", "set(protobuf_DEBUG_POSTFIX \"d\"", "set(protobuf_DEBUG_POSTFIX \"\"",
                   {plain = true})
        local configs = {"-Dprotobuf_BUILD_TESTS=OFF", "-Dprotobuf_BUILD_PROTOC_BINARIES=ON"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("zlib") then
            table.insert(configs, "-Dprotobuf_WITH_ZLIB=ON")
        end
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
        os.trycp("build/Release/protoc.exe", package:installdir("bin"))
    end)

    on_test(function(package)
        if package:is_cross() then
            return
        end
        io.writefile("test.proto", [[
            syntax = "proto3";
            package test;
            message TestCase {
                string name = 4;
            }
            message Test {
                repeated TestCase case = 1;
            }
        ]])
        os.vrun("protoc test.proto --cpp_out=.")
        assert(package:check_cxxsnippets({test = io.readfile("test.pb.cc")}, {
            configs = {includedirs = {".", package:installdir("include")}, languages = "c++11"}
        }))
    end)
end)
