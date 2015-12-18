#!/usr/bin/env ruby

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'upload_detector/app_config'

env = ENV['UPLOAD_DETECTOR_ENV'] || 'development'
config = AppConfig.new filename: 'import_trigger.yml', env: env

sftp_root = config.root_import_path
socket = "#{sftp_root}/dev/log"
hard_links_to_log = Dir.glob("#{sftp_root}/**/dev/log").reject{ |dir| dir == "#{sftp_root}/dev/log" }

puts "Re-create hardlinks to socket for sftp logging"
if hard_links_to_log.any?
  hard_links_to_log.each do |link|
    puts "  #{link} -> #{socket}"
    `rm #{link} && ln #{socket} #{link}`
  end
else
  puts "No hardlinks found. Something's fishy?"
end



