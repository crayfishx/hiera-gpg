class Hiera
    module Backend
        class Gpg_backend

        def initialize 
            require 'gpgme'
            debug ("Loaded gpg_backend")
        end

        def debug (msg)
            Hiera.debug("[gpg_backend]: #{msg}")
        end

        def warn (msg)
            Hiera.warn("[gpg_backend]:  #{msg}")
        end


        def lookup(key, scope, order_override, resolution_type)

            debug("Lookup called, key #{key} resolution type is #{resolution_type}")
            answer = nil

            # This should compute ~ on both *nix and *doze
            homes = ["HOME", "HOMEPATH"]
            real_home = homes.detect { |h| ENV[h] != nil }

            ## key_dir is the location of our GPG private keys
            ## default: ~/.gnupg
            key_dir = Config[:gpg][:key_dir] || "#{ENV[real_home]}/.gnupg"


            Backend.datasources(scope, order_override) do |source|
                gpgfile = Backend.datafile(:gpg, scope, source, "gpg") || next

                plain = decrypt(gpgfile, key_dir)
                next if !plain
                next if plain.empty?
                debug("GPG decrypt returned valid data")

                data = YAML.load(plain)
                next if !data
                next if data.empty?
                debug ("Data contains valid YAML")

                next unless data.include?(key)
                debug ("Key #{key} found in YAML document, Passing answer to hiera")

                parsed_answer = Backend.parse_answer(data[key], scope)

                begin
	                case resolution_type
	                when :array
	                    debug("Appending answer array")
                            answer ||= []
	                    answer << parsed_answer
	                when :hash
	                    debug("Merging answer hash")
                            answer ||= {}
	                    answer = parsed_answer.merge answer
	                else
	                    debug("Assigning answer variable")
	                    answer = parsed_answer
	                    break
	                end
                rescue NoMethodError
                    raise Exception, "Resolution type is #{resolution_type} but parsed_answer is a #{parsed_answer.class}"
                end

            end
            return answer
        end

        def decrypt(file, gnupghome)

            ENV["GNUPGHOME"]=gnupghome
            debug("GNUPGHOME is #{ENV['GNUPGHOME']}")

            ctx = GPGME::Ctx.new

            open(file) do |cipher|
                debug("loaded cipher: #{file}")

                ctx = GPGME::Ctx.new

                    if !ctx.keys.empty?
                        raw = GPGME::Data.new(cipher)
                        txt = GPGME::Data.new

                        begin
                            txt = ctx.decrypt(raw)
                        rescue GPGME::Error::DecryptFailed
                            warn("Warning: GPG Decryption failed, check your GPG settings")
                        rescue
                            warn("Warning: General exception decrypting GPG file")
                        end
                        
                        txt.seek 0
                        result = txt.read

                        debug("result is a #{result.class} ctx #{ctx} txt #{txt}")
                        return result
                    else
                        warn("No usable keys found in #{gnupghome}. Check :key_dir value in hiera.yaml is correct")
                    end
                end
            end
        end
    end
end


