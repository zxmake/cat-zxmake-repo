package("cat", function()
    -- xmake f -c
    on_load(function(package)
        os.tryrm(package:installdir("rules"))
        os.cp(path.join(os.scriptdir(), "rules"), package:installdir())
        if option.get("verbose") then
            cprint(
                "${bright blue}[package@cat][info]${clear} install successfully!")
        end
    end)

    on_install(function(package)
        -- handle some bad cases
        os.vrunv("cp", {
            "-v", "-r", path.join(os.scriptdir(), "rules"), package:installdir()
        })
    end)
end)
