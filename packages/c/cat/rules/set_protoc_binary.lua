rule("set_protoc_binary", function()
    on_config(function(target)
        import("lib.detect.find_tool")
        local protoc = target:data("protobuf.protoc")

        if not protoc then
            -- 优先从 target:pkgenvs() 中获取 protoc
            protoc = find_tool("protoc", {envs = target:pkgenvs()})
            if not (protoc and protoc.program) then
                -- 其次从系统环境中获取 protoc
                protoc = find_tool("protoc", {envs = os.getenvs()})
                if not (protoc and protoc.program) then
                    cprint(
                        "${bright red}[rule@cat/set_protoc_binary][error]${clear} protoc not found!")
                    raise("protoc not found!")
                end
            end
            local protoc_version = string.trim(
                                       os.iorunv(protoc.program, {"--version"}))
            cprint(
                "${bright blue}[rule@zelos/protobuf_cpp][info]${clear} find protoc [" ..
                    protoc_version .. "] binary in path " .. protoc.program)
            target:data_set("protobuf.protoc", protoc.program)
        end

        -- local pb_version = "21.7"
        -- local home = os.getenv("HOME")
        -- local search_dir = path.join(home, ".xmake/packages/p/protobuf",
        --                              pb_version, "**")

        -- for _, filepath in ipairs(os.files(search_dir)) do
        --     local basename = path.basename(filepath)
        --     if basename:trim() == "protoc" then
        --         local errors = nil
        --         check_ok = try {
        --             function()
        --                 os.runv(filepath, {"--version"})
        --                 return true
        --             end, catch {function(errs) errors = errs end}
        --         }

        --         if not check_ok then
        --             cprint(
        --                 "${bright yellow}[rule@cat/set_protoc_binary][warning]${clear} " ..
        --                     errors)
        --         else
        --             cprint(
        --                 "${bright blue}[rule@cat/set_protoc_binary][warning]${clear} find protoc binary in path " ..
        --                     filepath)
        --             target:data_set("protobuf.protoc", filepath)
        --             break
        --         end
        --     end
        -- end
        -- return assert(target:data("protobuf.protoc"), "protoc not found!")

    end)
end)
