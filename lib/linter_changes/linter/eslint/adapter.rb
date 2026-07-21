# typed: true

module LinterChanges
  module Linter
    module Eslint
      class Adapter < Base
        extend T::Sig

        # ESLint no ofrece un equivalente a `bin/rubocop --list-target-files`,
        # asi que derivamos los archivos objetivo filtrando los cambiados por
        # extension. `Base#run` los intersecta con los archivos del diff, de
        # modo que solo se linteara lo modificado. Los archivos en `.eslintignore`
        # que pasen este filtro son descartados por el propio ESLint.
        EXTENSIONS = T.let(%w[.js .jsx .ts .tsx .vue .mjs .cjs].freeze, T::Array[String])

        sig { returns(T::Array[String]) }
        def list_target_files
          changed_files.select { |file| EXTENSIONS.include?(File.extname(file)) }
        end
      end
    end
  end
end
