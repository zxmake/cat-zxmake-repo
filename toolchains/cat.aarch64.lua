toolchain("cat.aarch64", function()
    set_toolset("cc", "clang")
    set_toolset("cxx", "clang++")
    set_toolset("cpp", "clang -E")
    set_toolset("as", "clang")
    set_toolset("sh", "clang++")
    set_toolset("ld", "clang++")
    set_toolset("ar", "/usr/lib/llvm-14/bin/llvm-ar")
    set_toolset("strip", "/usr/lib/llvm-14/bin/llvm-strip")
    set_toolset("mm", "clang")
    set_toolset("mxx", "clang", "clang++")
    set_toolset("as", "clang")
    set_toolset("ranlib", "/usr/lib/llvm-14/bin/llvm-ranlib")

    add_syslinks("stdc++", "m", "pthread")

    add_cxflags("-m64", "-fPIC", "--target=aarch64-linux-gnu", "-march=armv8-a")
    add_ldflags("-m64", "--target=aarch64-linux-gnu", "-march=armv8-a")
    add_shflags("-m64", "-fPIC", "--target=aarch64-linux-gnu", "-march=armv8-a")

    on_load(function(toolchain)
        -- 设置运行时环境变量
        os.setenv("C_INCLUDE_PATH", "")
        os.setenv("CPLUS_INCLUDE_PATH", "")
    end)
end)
