package("cat", function()
    -- xmake f -c
    on_load(function(package)
        os.tryrm(package:installdir("rules"))
        os.cp(path.join(os.scriptdir(), "rules"), package:installdir())
        cprint("${bright blue}[package@cat][info]${clear} install successfully!")
    end)

    on_install(function(package)
    end)
end)
