class PublisherUser < ActiveRecord::Base
  belongs_to              :publisher
  has_many                :stories
end

