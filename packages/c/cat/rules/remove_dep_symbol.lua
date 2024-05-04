rule("remove_dep_symbol", function()
    -- add_rules("@cat/remove_dep_symbol", {wanted_prefixs = {"dep_a", "dep_b"}})
    -- add_rules("@cat/remove_dep_symbol", {wanted_prefixs = {"store"}, excludes = {"store.proto"}})
    before_link(function(target)
        local extraconf = target:extraconf("rules", "@cat/remove_dep_symbol")

        local includes
        local excludes
        local wanted_prefixs
        if extraconf then
            wanted_prefixs = extraconf.wanted_prefixs
            excludes = extraconf.excludes
            includes = extraconf.includes
        end

        if not includes and not wanted_prefixs and not excludes then
            raise("args for rule `@cat/remove_dep_symbol` is empty!")
        end

        target_deps = {}
        for _, dep in pairs(target:deps()) do
            table.insert(target_deps, dep:name())
        end
        cprint(format(
                   "${bright yellow}[rule@cat/remove_dep_symbol][warn]${clear} target [%s] deps [%s], please make sure to remove what you need!",
                   target:name(), table.concat(target_deps, " || ")))

        -- clear target:objectfiles()
        -- we iterate throught the Lua table in reverse to avoid skipping some elements during iteration
        for i = #target:objectfiles(), 1, -1 do
            table.remove(target:objectfiles(), i)
        end

        -- objectfiles from deps sourcebatches
        local sourcebatches_objectfiles = {}
        for _, sourcebatch in pairs(target:sourcebatches()) do
            table.join2(sourcebatches_objectfiles, sourcebatch.objectfiles)
        end
        table.unique(sourcebatches_objectfiles)
        table.join2(target:objectfiles(), sourcebatches_objectfiles)
        cprint(format(
            "${bright blue}[rule@cat/remove_dep_symbol][info]${clear} retain target [%s] sourcebatches objectfiles",
            target:name()))
        print(sourcebatches_objectfiles)

        -- objectfiles from deps
        for _, dep in pairs(target:deps()) do
            dep_name = dep:name()
            local wanted = false
            for _, wanted_prefix in pairs(wanted_prefixs) do
                if dep_name:startswith(wanted_prefix) then
                    wanted = true
                    break
                end
            end
            if wanted then
                for _, exclude in pairs(excludes) do
                    if dep_name == exclude:trim() then
                        wanted = false
                        break
                    end
                end
            end
            for _, include in pairs(includes) do
                if dep_name == include:trim() then
                    wanted = true
                    break
                end
            end

            if wanted then
                table.join2(target:objectfiles(), dep:objectfiles())
                cprint(format(
                           "${bright blue}[rule@cat/remove_dep_symbol][info]${clear} retain target [%s] dep [%s]",
                           target:name(), dep_name))
            else
                -- remove dep for this target
                cprint(format(
                           "${bright yellow}[rule@cat/remove_dep_symbol][warn]${clear} remove target [%s] dep [%s]",
                           target:name(), dep_name))
                target:deps()[dep_name] = nil
            end
        end

        -- for _, dep_name in pairs(remove_deps) do

        --     for object_file_idx = #target:objectfiles(), 1, -1 do
        --         local object_file = target:objectfiles()[object_file_idx]
        --         if not target:dep(dep_name) then
        --             raise(format(
        --                       "target [%s] don't have dep [%s], please check it!",
        --                       target:name(), dep_name))
        --         end
        --         if table.contains(target:dep(dep_name):objectfiles(),
        --                           object_file) then
        --             table.remove(target:objectfiles(), object_file_idx)
        --             cprint(format(
        --                        "${bright blue}[rule@cat/remove_dep_symbol][info]${clear} remove target [%s] object file [%s]",
        --                        target:name(), object_file))
        --         end
        --     end

        --     -- remove dep for this target
        --     target:deps()[dep_name] = nil
        -- end
    end)
end)
