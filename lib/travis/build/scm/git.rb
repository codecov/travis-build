require 'base64'
require 'shellwords'

module Travis
  class Build
    module Scm
      class Git
        extend Assertions

        attr_reader :shell, :config

        def initialize(shell, config = {})
          @shell = shell
          @config = config
        end

        def fetch(source, target, sha, branch, ref)
          clone(source, target, branch, ref)
          chdir(target)
          checkout(sha, ref)
          submodules if shell.file_exists?('.gitmodules')
          true
        end

        protected

          def clone(source, target, branch, ref)
            shell.export('GIT_ASKPASS', 'echo', :echo => false) # this makes git interactive auth fail
            shell.execute("git clone #{clone_args(branch, ref)} #{source} #{target}")
          ensure
            shell.execute('rm -f ~/.ssh/source_rsa', :echo => false)
          end
          assert :clone

          def clone_args(branch, ref)
            args = ["--depth=100", "--quiet"]
            args.unshift("--branch=#{branch}") unless ref
            args.join(' ')
          end

          def chdir(target)
            shell.chdir(target)
          end

          def submodules
            shell.execute('echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config', :echo => false)
            shell.execute("git submodule init")
            shell.execute("git submodule update")
          end
          assert :submodules

          def checkout(sha, ref)
            if ref
              shell.execute("git fetch origin +#{ref}:")
              shell.execute("git checkout -qf FETCH_HEAD")
            else
              shell.execute("git checkout -qf #{sha}")
            end
          end
          assert :checkout
      end
    end
  end
end
