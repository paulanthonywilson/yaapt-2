require 'pathname'
class Pathname
  def self.relative_to(outer_path, inner_path)
    Pathname.new(inner_path).realpath.to_s.sub(
      %r{^#{Pathname.new(outer_path).realpath}/}, '')
  end
end
