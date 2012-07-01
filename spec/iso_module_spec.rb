require "sequel"
require "sequel/adapters/mysql"

module Sequel
  module PreviewMySQL

    module MethodOverrides
      def execute(sql, opts={})
        if sql.match(/^SELECT/) || sql.match(/^DESCRIBE/)
          puts "RUNNING: #{sql}"
          super(sql, opts)
        else
          puts "PREVIEW: #{sql}"
        end
      end
    end

    class Database < Sequel::MySQL::Database
      include MethodOverrides
    end

  end
end

describe Sequel::PreviewMySQL::Database do
  it "should include the override methods" do
    subject.class.ancestors.should include(Sequel::PreviewMySQL::MethodOverrides)
  end
end

describe Sequel::PreviewMySQL::MethodOverrides do

  class FakeSuperClass
    attr_reader :last_super_call
    def method_missing(method, *args)
      @last_super_call = [method, args]
    end
  end

  subject do
    Class.new(FakeSuperClass).instance_eval do
      include Sequel::PreviewMySQL::MethodOverrides
    end.new
  end

  it "should allow SELECTs" do
    sql = "SELECT * FROM sometable"
    subject.should_receive(:puts).with(/^RUNNING:/)
    subject.execute(sql)
    subject.last_super_call.should == [:execute, [sql, {}]]
  end

  it "should not allow DELETEs" do
    sql = "DELETE FROM sometable"
    subject.should_receive(:puts).with(/^PREVIEW:/)
    subject.execute(sql)
    subject.last_super_call.should be_nil
  end

  it "should not allow DROPs" do
    sql = "DROP TABLE sometable"
    subject.should_receive(:puts).with(/^PREVIEW:/)
    subject.execute(sql)
    subject.last_super_call.should be_nil
  end

end

