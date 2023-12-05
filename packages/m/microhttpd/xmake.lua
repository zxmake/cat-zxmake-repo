package("microhttpd", function()
    set_homepage("https://www.gnu.org/software/libmicrohttpd/")
    add_urls(
        "https://mirrors.aliyun.com/gnu/libmicrohttpd/libmicrohttpd-$(version).tar.gz")
    add_urls(
        "https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-$(version).tar.gz")
    add_versions("0.9.77",
                 "9e7023a151120060d2806a6ea4c13ca9933ece4eacfc5c9464d20edddb76b0a0")
    add_syslinks("pthread")
    on_install(function(package)
        local configs = {
            "--enable-shared=no", "--enable-static=yes", "--disable-doc",
            "--disable-examples"
            -- "--enable-https=no",
            -- "--disable-messages"c
        }
        import("package.tools.autoconf").install(package, configs)
    end)
    on_test(function(package)
        assert(package:has_cfuncs("MHD_start_daemon", {includes = "microhttpd.h"}))
    end)
end)
