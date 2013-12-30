require 'subwrap'

module Dandelion
  module Svn
    class Repo
      attr_reader :dir
      def initialize(dir)
        @dir = dir
      end
    end
  
    class Diff
      attr_reader :from_revision, :to_revision
    
      @files = nil
  
      def initialize(repo, from_revision, to_revision)
        @repo = repo
        @from_revision = from_revision
        @to_revision = to_revision
        begin
          @files = parse(diff)
        rescue StandardError
          raise SCM::DiffError
        end
      end

      def changed
        @files.to_a.select { |f| ['A', 'C', 'M'].include?(f.last) }.map { |f| f.first }
      end

      def deleted
        @files.to_a.select { |f| 'D' == f.last }.map { |f| f.first }
      end

      private
      
      def diff
        Subversion.diff(%Q{"#{@repo.dir}" --summary -r #{@from_revision}:#{@to_revision}})
      end
    
      def parse(diff)
        files = {}
        diff.split("\n").each do |line|
          status, file = line.split("\t")
          files[file] = status
        end
        files
      end
    end

    class Tree
      def initialize(repo, revision)
        @repo = repo
        @revision = revision
        raise SCM::RevisionError if @revision.nil?
        @tree = @commit.tree
      end
    
      def files
        @repo.git.native(:ls_tree, {:name_only => true, :r => true}, revision).split("\n")
      end

      def show(file)
        (@tree / file).data
      end
  
      def revision
        @commit.sha
      end
    end
  end
end