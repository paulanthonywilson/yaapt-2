module ReleasesHelper
  def submit_text(release)
    return "Add release" if release.new_record?
    "Update release"
  end
end
