# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do
  before  { @user = User.new(name: "Example User", email: "user@example.com",
                             password: "foobar", password_confirmation: "foobar") }
  subject { @user }
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should be_valid }

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when email is not valid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org 
                  example.user@fo. foo@fff_fff.com foo@bar+bbb.com]
      addresses.each do |address|
        @user.email = address
        @user.should_not be_valid
      end
    end
    it "should be valid" do
      addresses = %w[user@foo.com user_uu-fff@f.co.uk 111.222@foo.jp a+b@baz.cn]
      addresses.each do |address|
        @user.email = address
        @user.should be_valid
      end
    end   
  end

  describe "when an email address is already in use" do
    before do
      user_with_the_same_email = @user.dup
      user_with_the_same_email.email = @user.email.upcase
      user_with_the_same_email.save
    end
    it { should_not be_valid }
  end


  describe "when a password is blank" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end
  
  describe "when passwords do not match" do
    before do
      @user.password = "foobar"
      @user.password_confirmation = "foobaz"
    end
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end 
  
  describe "when a password is too short" do
    # at least 6 characters
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end
  
  # Methods
  it { should respond_to(:authenticate) }
  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }
    
    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end
    
    describe "with invalid password" do
      let(:user_for_invalid_password) {found_user.authenticate("invalid password") }
      # Both of the below should be false
      # specifiy is an rpsec synonym for it
      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false } 
    end
  end
  
  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end
  
end
