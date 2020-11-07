class Report < ApplicationRecord
    has_many :connections, inverse_of: :report
end
