class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def youbi(wday)
    "#{%w[日 月 火 水 木 金 土][wday]}"
  end

end
