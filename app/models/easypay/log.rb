module Easypay
  class Log < ActiveRecord::Base
    self.table_name = 'easypay_logs'
    # attr accessible not used anymore in rails 4
    # attr_accessible :request_type, :request_url, :request_remote_ip, :raw
  end
end
