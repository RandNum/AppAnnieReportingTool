class Connection < ApplicationRecord
  belongs_to :report, inverse_of: :connections
end
