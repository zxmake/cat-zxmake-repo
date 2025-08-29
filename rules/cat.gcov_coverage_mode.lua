rule("cat.gcov_coverage_mode", function()
    on_config(function(target)
        if is_mode("gcov_coverage") then
            target:add("cuflags", "-g", "-lineinfo")
            target:add("cxflags", "-g")

            if not target:get("optimize") then
                target:set("optimize", "none")
            end

            -- -fprofile-update=atomic
            target:add("cxflags", "--coverage", "-fprofile-update=atomic", {force = true})
            target:add("mxflags", "--coverage", "-fprofile-update=atomic", {force = true})
            target:add("ldflags", "--coverage", "-fprofile-update=atomic", {force = true})
            target:add("shflags", "--coverage", "-fprofile-update=atomic", {force = true})

            target:add("cxflags", "-fPIC", {force = true})

            target:add("ldflags", "-fuse-ld=lld")
            -- target:add("shflags", "-fuse-ld=lld")

            -- memory && address sanitizer
            target:add("cxxflags", "-fsanitize=address", "-fsanitize=memory")
            target:add("ldflags", "-fsanitize=address", "-fsanitize=memory")
        end
    end)
end)
