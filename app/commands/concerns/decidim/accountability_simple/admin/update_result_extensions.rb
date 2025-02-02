# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      module UpdateResultExtensions
        extend ActiveSupport::Concern

        included do
          private

          def update_result
            Decidim.traceability.update!(
              result,
              @form.current_user,
              scope: @form.scope,
              category: @form.category,
              parent_id: @form.parent_id,
              title: @form.title,
              description: @form.description,
              start_date: @form.start_date,
              end_date: @form.end_date,
              progress: @form.progress,
              decidim_accountability_status_id: @form.decidim_accountability_status_id,
              external_id: @form.external_id.presence,
              weight: @form.weight,
              main_image: @form.main_image,
              list_image: @form.list_image,
              theme_color: @form.theme_color,
              use_default_details: @form.use_default_details
            )

            update_result_default_details
            update_result_details
          end
        end

        def update_result_default_details
          @form.result_default_details.each do |form_default_detail|
            update_result_default_detail(form_default_detail)
          end
        end

        def update_result_details
          @form.result_details.each do |form_result_detail|
            update_result_detail(form_result_detail)
          end
        end

        def update_result_default_detail(form_default_detail)
          record = Decidim::AccountabilitySimple::ResultDetail.find(
            form_default_detail.id
          )

          value = record.value_for(@result) || record.values.build(result: @result)
          value.attributes = { description: form_default_detail.description }
          value.save!
        end

        def update_result_detail(form_result_detail)
          result_detail_attributes = {
            title: form_result_detail.title,
            icon: form_result_detail.icon,
            position: form_result_detail.position
          }

          record = @result.result_details.find_by(id: form_result_detail.id) ||
                   @result.result_details.build(result_detail_attributes)

          if record.persisted?
            if form_result_detail.deleted?
              record.destroy!
            else
              record.update!(result_detail_attributes)
            end
          else
            record.save!
          end

          value = record.value_for(@result) || record.values.build(result: @result)
          value.attributes = { description: form_result_detail.description }
          value.save!

          record
        end
      end
    end
  end
end
