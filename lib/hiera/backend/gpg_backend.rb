class Hiera
  module Backend
    class Gpg_backend

      require 'gpgme'

      def lookup(key, scope, order_override, resolution_type)
        Hiera.debug("loaded gpg_backend")
        answer = Backend.empty_answer(resolution_type)

        Backend.datasources(scope, order_override) do |source|
          gpgfile = Backend.datafile(:gpg, scope, source, "gpg") || next


          ## Homedir is the location of our GPG private keys
          ## default: ~/.gnupg
          homedir = Config[:gpg][:homedir] || ""
          key_id = Config[:gpg][:key_id] || nil

          key_check(key_id) unless key_id.nil?

          decrypt(gpgfile) do |plain|
            data = YAML.load(plain)

            case resolution_type
            when :array
              answer << Backend.parse_answer(data[key], scope)
            else
              answer = Backend.parse_answer(data[key], scope)
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
      def key_check(id)
        raise ArgumentError, "No id passed to key_check method." if id.empty?
        raise StandardError, "No match for GPG key id: #{id}" if GPGME::list_keys(id, true).empty?
      end
    end
  end
end


