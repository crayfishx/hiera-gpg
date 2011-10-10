class Hiera
    module Backend
        class Gpg_backend
            def lookup(key, scope, order_override, resolution_type)
                Hiera.debug("loaded gpg_backend")
                answer = Backend.empty_answer(resolution_type)

                Backend.datasources(scope, order_override) do |source|
                    gpgfile = Backend.datafile(:gpg, scope, source, "gpg") || next
                
                    
                    Hiera.debug("Loading file #{gpgfile}")

                    ## Homedir is the location of our GPG private keys
                    ## default: ~/.gnupg
                    homedir = Config[:gpg][:homedir] || ""

                    plain = decrypt(gpgfile, homedir)

                    if plain.empty?
                        Hiera.debug("GPG decrypt returned empty string")
                        next
                    end

                    data = YAML.load(plain)

                    next if data.empty?
                    next unless data.include?(key)


                    case resolution_type
                        when :array
                            answer << Backend.parse_answer(data[key], scope)
                        else
                            answer = Backend.parse_answer(data[key], scope)
                            break
                        end
                    end
                    return answer
                
            end
         

            def decrypt (file, homedir)
                # This should be tied in with the gpgme API, but for now
                # we just shell this out to the gpg command, a future todo
                # is to replace this.
                #

                opts = ["--decrypt"]
                if !homedir.empty?
                    opts << "--homedir #{homedir}"
                end

                data = `/usr/bin/env gpg #{opts.join(" ")} < #{file} 2> /dev/null`
                Hiera.debug("Return code of gpg command was #{$?}")
                return data
            end
        end
    end
end


