class Project < ActiveRecord::Base
  attr_accessible :git_url, :picture_url, :summary, :title, :url, :slug
end
 