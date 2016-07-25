module PxeLoaderValidator
  extend ActiveSupport::Concern

  included do
    validates :pxe_loader, :presence => true, :allow_blank => true
    validate :validate_pxe_loader
  end

  def validate_pxe_loader
    if operatingsystem && pxe_loader.present?
      loaders = operatingsystem.available_loaders
      errors.add(:pxe_loader, _("'%{loader}' is not one of %{loaders}") % {:loader => pxe_loader, :loaders => loaders.join(', ')}) unless loaders.include?(pxe_loader)
    end
  end
end
