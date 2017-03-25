require 'rails_helper'

RSpec.describe VideoTutorial, type: :model do
  let(:link_url) { 'https://vimeo.com/208056324' }
  subject { VideoTutorial.new(link_url: link_url) }
  
  context 'thumbnail_iframe' do
    it { expect(subject.thumbnail_iframe).to eq(
      '<iframe src="https://player.vimeo.com/video/208056324" width="90" height="90" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>'
    )}
  end
  
  context 'iframe' do
    it { expect(subject.iframe).to eq(
      '<iframe src="https://player.vimeo.com/video/208056324" width="570" height="380" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>'
    )}
  end
  
  context 'private vimeo link' do
    let(:link_url) { 'https://vimeo.com/208056324/607c549a71' }
   
    context 'thumbnail_iframe' do
      it { expect(subject.thumbnail_iframe).to eq(
        '<iframe src="https://player.vimeo.com/video/208056324" width="90" height="90" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>'
      )}
    end
  end
  
end


