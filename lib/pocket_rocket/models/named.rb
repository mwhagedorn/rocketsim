require 'couchbase/model'

class Named < Couchbase::Model

    attribute :name
    attribute :created_at
    attribute :updated_at

end

