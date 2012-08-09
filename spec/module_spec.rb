require "sequel"
require "sequel/adapters/mysql"

module Sequel
  module MySQLPreviewMod
    class Database < Sequel::MySQL::Database

      def execute(sql, opts={})
        if sql.match(/^SELECT/) || sql.match(/^DESCRIBE/)
          puts "RUNNING: #{sql}"
          super(sql, opts)
        else
          puts "PREVIEW: #{sql}"
        end
      end

    end
  end
end

describe Sequel::MySQLPreviewMod::Database do

  module FakeMySQLAdapter
    class << self
      attr_accessor :last_execute
    end
    def execute(*args)
      FakeMySQLAdapter.last_execute = args
    end
  end

  before :all do
    subject.class.instance_eval { include FakeMySQLAdapter }
  end

  before :each do
    FakeMySQLAdapter.last_execute = nil
  end

  it "should allow SELECTs" do
    sql = "SELECT * FROM sometable"
    subject.should_receive(:puts).with(/^RUNNING:/)
    subject.execute(sql)
    FakeMySQLAdapter.last_execute.should == [sql, {}]
  end

  it "should not allow DELETEs" do
    sql = "DELETE FROM sometable"
    subject.should_receive(:puts).with(/^PREVIEW:/)
    subject.execute(sql)
    FakeMySQLAdapter.last_execute.should == nil
  end

  it "should not allow DROPs" do
    sql = "DROP TABLE sometable"
    subject.should_receive(:puts).with(/^PREVIEW:/)
    subject.execute(sql)
    FakeMySQLAdapter.last_execute.should == nil
  end

end

