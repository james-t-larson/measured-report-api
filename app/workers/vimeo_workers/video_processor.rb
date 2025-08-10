module VimeoWorkers
  class VideoProcessor
    include Sidekiq::Worker
    sidekiq_options queue: :default, retry: false

    def perform
      Rails.logger.info(
        Sidekiq::ScheduledSet.new.each do |job|
          puts "Job class: #{job.klass}"
          puts "Args: #{job.args}"
          puts "Runs at: #{job.at}"
          puts "Current Time: #{Time.zone.now}"
        end
      )

      if future_job_already_scheduled?
        Rails.logger.info("[VimeoWorkers::VideoProcessor] Jobs already scheduled Halting.")
        return
      end

      @pending_videos ||= Video.pending
      @active_video ||= @pending_videos.first

      unless @active_video.present?
        Rails.logger.info("[VimeoWorkers::VideoProcessor] No pending videos. Halting.")
        return
      end

      VimeoServices::IngestContent.video(@active_video)
      @active_video.success!
      remaining_count = @pending_videos.count - 1
      Rails.logger.info(
        "[VimeoWorkers::VideoProcessor] " \
        "Video #{@active_video.id} (#{@active_video.title}) completed. " \
        "#{remaining_count} videos remaining."
      )

      Sidekiq::ScheduledSet.new.each do |job|
        puts "Job class: #{job.klass}"
        puts "Args: #{job.args}"
        puts "Runs at: #{job.at}"
      end
      VimeoWorkers::VideoProcessor.perform_in(30.seconds)
      Sidekiq::ScheduledSet.new.each do |job|
        puts "Job class: #{job.klass}"
        puts "Args: #{job.args}"
        puts "Runs at: #{job.at}"
      end
    end

    def self.future_job_already_scheduled?
      Rails.logger.info("Checking for future jobs")
      Sidekiq::ScheduledSet.new.any? { |j| j.klass == self.class.name }
    end
  end
end
