# frozen_string_literal: true

namespace :que do
  desc "Process Que's jobs using a forking worker pool"
  task fork_and_work: :environment do
    Que.logger.level = Logger.const_get((ENV['QUE_LOG_LEVEL'] || 'INFO').upcase)
    worker_count     = (ENV['QUE_WORKER_COUNT'] || 1).to_i
    wake_interval    = (ENV['QUE_WAKE_INTERVAL'] || 0.1).to_f
    queue            = ENV['QUE_QUEUE'] || ''

    parent_pid = Process.pid
    worker_pid = nil
    stop = false

    %w( INT TERM ).each do |signal|
      trap(signal) do
        $stderr.puts "Asking worker process(es) to stop..." if Process.pid == parent_pid
        stop = true
        Process.kill(signal, worker_pid) if worker_pid
      end
    end

    if defined?(ActiveRecord::Base)
      ActiveRecord::Base.connection.disconnect!
    end
    pids = []
    worker_count.times do
      pid = fork do
        loop do
          break if stop
          worker_pid = fork do
            if defined?(ActiveRecord::Base)
              ActiveRecord::Base.establish_connection
            end
            stop = false
            %w( INT TERM ).each do |signal|
              trap(signal) {stop = true}
            end

            loop do
              break if stop
              result = Que::Job.work(queue)
              if result && result[:event] == :job_unavailable
                # No jobs worked, check again in a bit.
                break if stop
                sleep wake_interval
              else
                # Job worked, fork new worker process.
                break
              end
            end
          end
          Process.wait(worker_pid)
        end
      end
      pids << pid
    end
    pids.each { |pid| Process.wait(pid) }  
  end
end
