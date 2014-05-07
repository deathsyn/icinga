#!/usr/bin/env ruby

=begin

Depends on redis gem

Check a resque queue count and return a status for Icinga.  There
is an options hash that can be passed into the count method to
define the various warning levels.  The defaults are:

- WARN: 2000
- CRITICAL : 6000

require "lib/icinga_redis_queue_count.rb"
IcingaRedisQueueCount.count('calamp_outbound_message')

IcingaRedisQueueCount.count('telemetry', {'warn' => 2500, 'critical' => 10000})

=end

require 'rubygems'
require 'redis'

module Icinga
  EXIT_OK        = 0
  EXIT_WARNING   = 1
  EXIT_CRITICAL  = 2
  EXIT_UNKNOWN   = 3
  LEVEL_WARN     = 2000
  LEVEL_CRITICAL = LEVEL_WARN * 3
  STATUS = {
    EXIT_OK       => 'OK',
    EXIT_WARNING  => 'WARNING',
    EXIT_CRITICAL => 'CRITICAL',
    EXIT_UNKNOWN  => 'UNKNOWN'
  }
end

class IcingaRedisQueueCount
  include Icinga

  def self.count(queue, warn_levels = {})
    warn_levels[:warn]     ||= LEVEL_WARN
    warn_levels[:critical] ||= LEVEL_CRITICAL
    r = Redis.new
    name = queue == 'failed' ? "resque:#{queue}" : "resque:queue:#{queue}"
    count = r.lrange(name, 0, -1).size
    rval = if count > warn_levels[:critical]
      EXIT_CRITICAL
    elsif count > warn_levels[:warn]
      EXIT_WARNING
    else
      EXIT_OK
    end
    puts "#{STATUS[rval]}: #{queue}, COUNT = #{count}"
    return rval
  rescue
    return EXIT_UNKNOWN
  end
end

if $0 == __FILE__
  if ARGV.size >1
    counter =  IcingaRedisQueueCount.count(ARGV[0], {:warn => ARGV[1].to_i, :critical => ARGV[2].to_i})
    exit Icinga.const_get("EXIT_#{Icinga::STATUS[counter]}".to_sym)
  elsif ARGV.size == 1
    counter =  IcingaRedisQueueCount.count(ARGV[0])
    exit Icinga.const_get("EXIT_#{Icinga::STATUS[counter]}".to_sym)
  else
    puts 'Need to tell me which queue you want'
    exit Icinga::EXIT_UNKNOWN
  end
end
