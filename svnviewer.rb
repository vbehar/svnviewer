#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'

require 'svn.rb'

configure do
  set :svn_repositories, [SVN::Repository.new(1, "repo 1", "http://www.example.com/repo1"), 
                          SVN::Repository.new(2, "repo 2", "http://www.example.com/repo2")]
  set :batch_size, 10
end

helpers do
  def get_repo(repo_id)
    options.svn_repositories.find {|repo| repo.id == repo_id.to_i }
  end
  def load_repo_data(repo_id, rev)
     @repo = get_repo(repo_id)
     @entries = SVN::retrieve_entries(@repo.url, options.batch_size, rev)
     @batch_size = options.batch_size
  end
end

get '/' do
  @repositories = options.svn_repositories
  erb :index
end

get %r{/(\d+)/(\d+)} do |repo_id, rev|
  load_repo_data(repo_id, rev)
  view = erb :repo_entries_list, :layout => false
  view += "@@extraReplacement@@"
  view += erb :repo_entries_details, :layout => false
  view
end

get %r{/(\d+)} do |repo_id|
  load_repo_data(repo_id, 'HEAD')
  erb :repo
end

