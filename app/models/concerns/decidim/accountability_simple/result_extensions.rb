# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module ResultExtensions
      extend ActiveSupport::Concern

      include Decidim::HasAttachments
      include Decidim::HasAttachmentCollections

      included do
        mount_uploader :main_image, Decidim::AccountabilitySimple::MainImageUploader
        mount_uploader :list_image, Decidim::AccountabilitySimple::ListImageUploader

        has_many :result_details, -> { order(:position) }, as: :accountability_result_detailable,
                                                           class_name: "Decidim::AccountabilitySimple::ResultDetail"

        def result_default_details
          Decidim::AccountabilitySimple::ResultDetail.where(
            accountability_result_detailable: component
          ).order(:position)
        end

        # Gets the default details and result specific details
        def result_all_details
          return result_details unless use_default_details?

          Decidim::AccountabilitySimple::ResultDetail.where(
            "(accountability_result_detailable_type = ? AND accountability_result_detailable_id = ?)"\
            " OR "\
            "(accountability_result_detailable_type = ? AND accountability_result_detailable_id = ?)",
            Decidim::Accountability::Result.name,
            id,
            Decidim::Component.name,
            component.id
          ).order(
            accountability_result_detailable_type: :desc,
            position: :asc
          )
        end
      end
    end
  end
end
