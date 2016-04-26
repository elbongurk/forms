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
    request_params = {}
    request_params['blog'] = ENV['AKISMET_API_HOST'];
    request_params['user_ip'] = self.user_ip
    request_params['user_agent'] = self.user_agent
    request_params['referrer'] = self.referrer if self.referrer.present?
    request_params.merge!(self.headers)

    akismet = URI.parse("https://#{ENV['AKISMET_API_KEY']}.rest.akismet.com/1.1/comment-check")

    http = Net::HTTP.new(akismet.hostname, akismet.port)
    http.use_ssl = akismet.is_a?(URI::HTTPS)

    request = Net::HTTP::Post.new(akismet.path)
    request.set_form_data(request_params)

    response = http.request(request)

    self.update!(spam: response.body == 'true')
  end
end
