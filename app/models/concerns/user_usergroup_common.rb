module UserUsergroupCommon
  class Jail < ::Safemode::Jail
    allow :ssh_keys, :ssh_authorized_keys
  end

  def ssh_authorized_keys
    ssh_keys.map(&:to_export)
  end
end
