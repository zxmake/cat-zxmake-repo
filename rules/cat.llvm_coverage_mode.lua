rule("cat.llvm_coverage_mode", function()
    on_config(function(target)
        if is_mode("llvm_coverage") then
            target:add("cuflags", "-g", "-lineinfo")
            target:add("cxflags", "-g")

            if not target:get("optimize") then
                target:set("optimize", "none")
            end

            -- llvm-cov 依赖的编译参数
            target:add("cxflags", "-fprofile-instr-generate", "-fcoverage-mapping", {force = true})
            target:add("ldflags", "-fprofile-instr-generate", "-fcoverage-mapping", {force = true})

            target:add("cxflags", "-fPIC", {force = true})

            target:add("ldflags", "-fuse-ld=lld")
            -- target:add("shflags", "-fuse-ld=lld")

            -- memory && address sanitizer
            target:add("cxxflags", "-fsanitize=address", "-fsanitize=memory")
            target:add("ldflags", "-fsanitize=address", "-fsanitize=memory")
        end
    end)
end)
