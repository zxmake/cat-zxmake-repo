rule("cuda_devlink", function()
    on_config(function(target)
        import("core.platform.platform")
        -- get cuda sdk
        local cuda = assert(target:data("cuda"), "Cuda SDK not found!")
        -- add arch
        if target:is_arch("i386", "x86") then
            target:add("cuflags", "-m32", {force = true})
            target:add("culdflags", "-m32", {force = true})
        else
            target:add("cuflags", "-m64", {force = true})
            target:add("culdflags", "-m64", {force = true})
        end
        -- add rdc, @see https://github.com/xmake-io/xmake/issues/1975
        if target:values("cuda.rdc") ~= false then
            target:add("cuflags", "-rdc=true")
        end
        -- add links
        target:add("syslinks", "cudadevrt")
        local cudart = false
        for _, link in ipairs(table.join(target:get("links") or {},
                                         target:get("syslinks"))) do
            if link == "cudart" or link == "cudart_static" then
                cudart = true
                break
            end
        end
        if not cudart then target:add("syslinks", "cudart_static") end
        if target:is_plat("linux") then
            target:add("syslinks", "rt", "pthread", "dl")
        end
        target:add("linkdirs", cuda.linkdirs)
        target:add("rpathdirs", cuda.linkdirs)

        -- add includedirs
        target:add("includedirs", cuda.includedirs)
    end)

    after_build(function(target, opt)
        import("core.base.option")
        import("core.tool.linker")
        import("core.project.depend")
        import("utils.progress")

        -- load linker instance
        local linkinst = linker.load("gpucode", "cu", {target = target})
        -- init culdflags
        local culdflags = {"-dlink"}
        -- add shared flag
        if target:is_shared() then table.insert(culdflags, "-shared") end
        -- get link flags
        local linkflags = linkinst:linkflags({
            target = target,
            configs = {force = {culdflags = culdflags}}
        })
        -- get target file
        local targetfile = target:objectfile(
                               path.join("rules", "cuda", "devlink",
                                         target:basename() .. "_gpucode.cu"))
        -- get object files
        local objectfiles = nil
        for _, sourcebatch in pairs(target:sourcebatches()) do
            if sourcebatch.sourcekind == "cu" then
                objectfiles = sourcebatch.objectfiles
            end
        end
        if not objectfiles then return end
        -- insert gpucode.o to the object files
        table.insert(target:objectfiles(), targetfile)
        -- need build this target?
        local depfiles = objectfiles
        for _, dep in ipairs(target:orderdeps()) do
            if dep:kind() == "static" then
                if depfiles == objectfiles then
                    depfiles = table.copy(objectfiles)
                end
                table.insert(depfiles, dep:targetfile())
            end
        end
        local dryrun = option.get("dry-run")
        local depvalues = {linkinst:program(), linkflags}
        depend.on_changed(function()

            -- is verbose?
            local verbose = option.get("verbose")

            -- trace progress info
            progress.show(opt.progress,
                          "${color.build.target}devlinking.$(mode) %s",
                          path.filename(targetfile))

            -- trace verbose info
            if verbose then
                -- show the full link command with raw arguments, it will expand @xxx.args for msvc/link on windows
                print(linkinst:linkcmd(objectfiles, targetfile,
                                       {linkflags = linkflags, rawargs = true}))
            end

            -- link it
            if not dryrun then
                assert(linkinst:link(objectfiles, targetfile,
                                     {linkflags = linkflags}))
            end

        end, {
            dependfile = target:dependfile(targetfile),
            lastmtime = os.mtime(targetfile),
            changed = target:is_rebuilt(),
            values = depvalues,
            files = depfiles,
            dryrun = dryrun
        })
    end)
end)
