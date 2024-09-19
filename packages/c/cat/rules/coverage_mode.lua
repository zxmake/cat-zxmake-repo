rule("coverage_mode", function()
    on_config(function(target)
        if is_mode("coverage") then
            target:add("cuflags", "-g", "-lineinfo")
            target:add("cxflags", "-g")

            if not target:get("optimize") then
                target:set("optimize", "none")
            end

            target:add("cxflags", "--coverage", {force = true})
            target:add("mxflags", "--coverage", {force = true})
            target:add("ldflags", "--coverage", {force = true})
            target:add("shflags", "--coverage", {force = true})

            target:add("cxflags", "-fPIC", {force = true})

            target:add("ldflags", "-fuse-ld=lld")
            -- target:add("shflags", "-fuse-ld=lld")

            -- memory && address sanitizer
            target:add("cxxflags", "-fsanitize=address", "-fsanitize=memory")
            target:add("ldflags", "-fsanitize=address", "-fsanitize=memory")
        end
    end)
end)
