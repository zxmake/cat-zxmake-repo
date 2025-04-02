-- cat.jetpack 用于自动检测 jetpack 版本, car.jetpack_cross 用于交叉编译时强制指定 jetpack 版本
-- 在 xmake.lua 脚本中只用 cat.jetpack 判断 jetpack 即可
-- 这个脚本仅供 xmake examples 使用, 获取的 jetpack 版本是错误的, 无实际意义

-- Usage:
--     xmake config --cat.jetpack_cross=6

option("cat.jetpack_cross", function()
    set_description("jetpack version for cross building")
    set_values("4", "5", "6")
    set_default(false)
end)

option("cat.jetpack", function()
    set_description("jetpack version")
    set_values("4", "5", "6")
    on_check(function(option)
        local jetpack_cross = get_config("cat.jetpack_cross")
        if jetpack_cross then
            cprint("${bright green}[configure] set cat.jetpack for cross-buiding:${clear} [" .. jetpack_cross .. "]")
            option:set_value(jetpack_cross)
            return
        end

        local jetpack = "5"
        local uname = string.trim(os.iorun("uname -m"))
        if uname == "x86_64" then
            jetpack = "4"
        elseif uname == "aarch64" then
            jetpack = "6"
        end
        cprint("${bright green}[configure] jetpack:${clear} [" .. zelos_jetpack .. "]")
        option:set_value(jetpack)
    end)
end)
