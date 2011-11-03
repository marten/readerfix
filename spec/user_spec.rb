require 'spec_helper'
require 'user'
describe User do
  context "creation" do
    it "should be possible to create a user" do
      user = User.create(username: "marten", token: "asdf")
      User.by_username("marten").should == user
    end

    it "should not be possible to create duplicate users" do
      user = User.create(username: "marten", token: "asdf")
      another_user = User.create(username: "marten", token: "qwert")
      another_user.valid?.should be_false
    end
  end

  context "with a user" do
    subject { User.create(username: "marten", token: "asdf") }

    it "should validate a correct token" do
      subject.validate_token("asdf").should be_true
    end

    it "should validate a incorrect token" do
      subject.validate_token("aoeu").should be_false
    end

    it "should be possible to add a shared item" do
      subject.share!(url: "http://hiero.com")
      subject.shared_items.all[0].url.should == "http://hiero.com"
    end

    it "should rememeber last share time" do
      share = subject.share!(url: "http://hiero.com")
      subject.last_update.should == share.updated_at
    end
  end

end
