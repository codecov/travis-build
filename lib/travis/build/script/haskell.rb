module Travis
  module Build
    class Script
      class Haskell < Script
        DEFAULTS = {}

        def setup
          super
          sh.export 'PATH', "#{path}:$PATH", assert: true, timing: true
          sh.cmd 'cabal update', fold: 'cabal', retry: true
        end

        def announce
          super
          sh.cmd 'ghc --version', timing: true
          sh.cmd 'cabal --version', timing: true
        end

        def install
          sh.cmd 'cabal install --only-dependencies --enable-tests', fold: 'install', retry: true
        end

        def script
          sh.cmd 'cabal configure --enable-tests && cabal build && cabal test'
        end

        def path
          "/usr/local/ghc/$(ghc_find #{version})/bin/"
        end

        def version
          config[:ghc].to_s
        end
      end
    end
  end
end