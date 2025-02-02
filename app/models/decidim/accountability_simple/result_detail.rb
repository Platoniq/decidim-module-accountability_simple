# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    # The data store for a Result in the Decidim::Accountability component. It stores a
    # title, description and any other useful information to render a custom result.
    class ResultDetail < Accountability::ApplicationRecord
      belongs_to :accountability_result_detailable, foreign_key: "accountability_result_detailable_id",
                                                    foreign_type: "accountability_result_detailable_type",
                                                    polymorphic: true
      has_many :values, foreign_key: "decidim_accountability_result_detail_id",
                        class_name: "Decidim::AccountabilitySimple::ResultDetailValue",
                        inverse_of: :detail,
                        dependent: :destroy

      def value_for(result)
        values.find_by(decidim_accountability_result_id: result.id)
      end

      def description_for(result)
        value_for(result).try(:description)
      end
    end
  end
end
