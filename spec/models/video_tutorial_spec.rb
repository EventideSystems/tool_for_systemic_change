require 'rails_helper'

RSpec.describe VideoTutorial, type: :model do
  let(:link_url) { '<iframe src="https://player.vimeo.com/video/208056324" width="90" height="68" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>' }
  subject { VideoTutorial.new(link_url: link_url) }
  
  context "iframe dimensions" do
    it { expect(subject.iframe_width).to eq(90) }
    it { expect(subject.iframe_height).to eq(68) }
  end
  
  context 'thumbnail_iframe' do
    it { expect(subject.thumbnail_iframe).to eq(
      '<iframe src="https://player.vimeo.com/video/208056324" width="90" height="90" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>'
    )}
  end
end


