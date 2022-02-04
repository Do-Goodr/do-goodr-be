class Event < ApplicationRecord
  belongs_to :organization

  validates_presence_of :name, :category, :address, :description, :vols_required, :organization_id

  enum category: {"Nursing Home" => 0, "Grounds Cleanup" => 1, "Animal Care" => 2, "Campaigning" => 3, "Food Service" => 4, "Youth Mentorship" => 5, "Community Development" => 6, "Healthcare" => 7, "Other" => 8}

end