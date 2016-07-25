module PxeLoaderSupport
  extend ActiveSupport::Concern

  class_methods do
    def all_loaders_map(suffix = '64')
      {
        "None" => "NONE",
        "PXELinux BIOS" => "pxelinux.0",
        "PXELinux UEFI" => "pxelinux.efi",
        "Grub UEFI" => "grub/bootx#{suffix}.efi",
        "Grub UEFI SecureBoot" => "grub/shim.efi",
        "Grub2 UEFI" => "grub2/grubx#{suffix}.efi",
        "Grub2 UEFI SecureBoot" => "grub2/shim.efi"
      }.freeze
    end

    def all_loaders
      all_loaders_map.keys.freeze
    end
  end

  def available_loaders
    self.class.all_loaders
  end

  def default_boot_filename
    "pxelinux.0"
  end

  PXE_KINDS = {
    :PXELinux => /^(pxelinux|PXELinux).*/,
    :PXEGrub => /^(grub\/|Grub ).*/,
    :PXEGrub2 => /^(grub2|Grub2).*/
  }.freeze

  # Finds template kind for given loader filename or name or nil for "None" or ""
  def pxe_loader_kind(host)
    PXE_KINDS.find{|k, v| v.match(host.pxe_loader)}.try(:first)
  end

  PREFERRED_KINDS = {
    "PXEGrub2" => "Grub2 UEFI",
    "PXELinux" => "PXELinux BIOS",
    "PXEGrub" => "Grub UEFI"
  }.with_indifferent_access.freeze

  # Suggested PXE loader when template kind is available (PXEGrub2, then PXELinux, then PXEGrub in this order)
  def preferred_loader
    associated_templates = os_default_templates.map(&:template_kind).compact.map(&:name)
    template_kinds.each do |loader|
      return PREFERRED_KINDS[loader] if associated_templates.include? loader
    end
    nil
  end
end
