require 'spec_helper'
require 'monkeypatches'

describe Hash do
  subject { {a:1, b:2, c:3} }

  it { subject.hash_from(:a, :b).should eq({a:1, b:2}) }
end
