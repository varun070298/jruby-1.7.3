require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../shared/to_hash.rb', __FILE__)

ruby_version_is "2.0" do
  describe "ENV.to_hash" do
    it_behaves_like(:env_to_hash, :to_h)
  end
end
