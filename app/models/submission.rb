class Submission < ApplicationRecord
  belongs_to :form

  validates :payload, presence: true
  validates :headers, presence: true

  def self.to_csv
    CSV.generate do |csv|
      headers = [ :submitted ]
      rows = []      
      all.each do |submission|
        row = [ submission.submitted ]
        submission.payload.each do |key, value|
          headers << key unless headers.include? key
          index = headers.index key
          row[index] = value
        end
        rows << row
      end
      csv << headers
      rows.each do |row|
        csv << row
      end
    end
  end

  def submitted
    self.created_at
  end
  
  def preview
    self.payload.values.first
  end

  def ham?
    self.spam == false
  end

  def user_ip
    self.headers['REMOTE_ADDR'] || '127.0.0.1'
  end

  def user_agent
    self.headers['HTTP_USER_AGENT']    
  end

  def referrer
    self.headers['HTTP_REFERER']
  end
  
  def check!
    akismet = URI.parse("https://#{ENV['AKISMET_API_KEY']}.rest.akismet.com/1.1/comment-check")
    request_headers = { 'Content-Type': 'application/x-www-form-urlencoded' }
    request_params = {}
    request_params['blog'] = ENV['AKISMET_API_HOST'];
    request_params['user_ip'] = self.user_ip
    request_params['user_agent'] = self.user_agent
    request_params['referrer'] = self.referrer if self.referrer.present?
    request_params.merge!(self.headers)

    response = Net::HTTP.start(akismet.host, akismet.port) do |http|
      http.post(akismet.path, request_params.map { |k,v| "#{k}=#{CGI.escape(v)}" }.join('&'))      
    end
    self.update!(spam: response.body == 'true')
  end
end
