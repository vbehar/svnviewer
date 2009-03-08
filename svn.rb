#!/usr/bin/env ruby

require 'time'
require 'xml-object'

module SVN
  class Repository
    attr_reader :id, :name, :url
    
    def initialize(id, name, url)
      @id = id
      @name = name
      @url = url
    end
  end

  class ModifiedFile
    attr_reader :path, :action
    
    def initialize(path, action)
      @path = path
      @action = action
    end
  end

  class LogEntry
    attr_reader :revision, :date, :author, :message, :files
    
    def initialize(entry)
      @revision = entry.revision.to_i
      @date = Time.parse(entry.date) + 3600
      @author = entry.author
      @message = entry.msg
      @files = []
      if entry.paths.is_a?(Array)
        entry.paths.each do |path|
          @files << ModifiedFile.new(path, path.action)
        end
      else
       @files << ModifiedFile.new(entry.paths.path, entry.paths.path.action)
      end
    end
  end
  
  def self.retrieve_entries(svn_url, batch_size, start_rev='HEAD')
    svnlogxml = `svn log #{svn_url} -r #{start_rev}:1 -l #{batch_size} -v --xml`
    log = XMLObject.new(svnlogxml)
    entries = log.logentrys rescue [log.logentry]
    entries.collect { |entry| LogEntry.new(entry) }
  end
end

