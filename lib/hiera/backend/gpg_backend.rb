class Hiera
  module Backend
    class Gpg_backend

      require 'gpgme'

      def lookup(key, scope, order_override, resolution_type)
        Hiera.debug("loaded gpg_backend")
        Hiera.debug("resolution_type is #{resolution_type}")
        answer = Backend.empty_answer(resolution_type)
        Hiera.debug("answer is #{answer.class}")

        Backend.datasources(scope, order_override) do |source|
          gpgfile = Backend.datafile(:gpg, scope, source, "gpg") || next

          # This should compute ~ on both *nix and *doze
          homes = ["HOME", "HOMEPATH"]
          real_home = homes.detect { |h| ENV[h] != nil }

          ## key_dir is the location of our GPG private keys
          ## default: ~/.gnupg
          key_dir = Config[:gpg][:key_dir] || "#{ENV[real_home]}/.gnupg"
          key_id = Config[:gpg][:key_id] || nil
          key_check(key_id, key_dir) unless key_id.nil?

          decrypt(gpgfile) do |plain|
            data = YAML.load(plain)
            Hiera.debug(data[key])

            case resolution_type
            when :array
              Hiera.debug("array is used")
              answer << Backend.parse_answer(data[key], scope)
            else
              Hiera.debug("array is not used")
              answer = Backend.parse_answer(data[key], scope)
              Hiera.debug("answer is #{answer.class}")
            end

          end

          answer

        end
      end

      def decrypt(file)
        abort "No file: #{file}" unless File.file? file
        open(file) do |cipher|
          Hiera.debug("loaded cipher: #{file}")
          yield GPGME.decrypt(cipher)
        end
      end

      # How valuable is this? - AK
      def key_check(id, gnupghome)
        raise ArgumentError, "No id passed to key_check method." if id.empty?
        ENV["GNUPGHOME"]=gnupghome
        Hiera.debug("GNUPGHOME is #{ENV['GNUPGHOME']}")
        raise StandardError, "No match for GPG key id: #{id}" if GPGME::list_keys(id, true).empty?
      end
    end
  end
end


