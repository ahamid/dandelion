module Dandelion
  module SCM
    class DiffError < StandardError; end
    class RevisionError < StandardError; end
  end
end

require 'dandelion/scm/git'
require 'dandelion/scm/svn'
