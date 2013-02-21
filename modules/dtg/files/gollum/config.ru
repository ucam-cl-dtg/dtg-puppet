#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'gollum/frontend/app'
require 'gitolite-dtg'

system("which git") or raise "Looks like I can't find the git CLI in your path.\nYour path is: #{ENV['PATH']}"

git_repos_path = '/srv/git/repositories' # CHANGE THIS TO POINT TO YOUR GITOLITE BASE REPO PATH
wiki_repos_pattern = 'wiki/'
wikis_breadcrumb_url = 'https://wiki.dtg.cl.cam.ac.uk/list'

disable :run

configure :development, :staging, :production do
 set :raise_errors, true
 set :show_exceptions, true
 set :dump_errors, true
 set :clean_trace, true
end

ga_repo = Gitolite::Dtg::GitoliteAdmin.new(File.join(git_repos_path , "gitolite-admin.git"))

Precious::App.set(:repos_path, git_repos_path)
Precious::App.set(:gitolite_repo, ga_repo)
Precious::App.set(:wiki_repos_pattern, wiki_repos_pattern)
Precious::App.set(:wiki_bcrumb, wikis_breadcrumb_url)
Precious::App.set(:wiki_options, {:mathjax => true})

run Precious::App
