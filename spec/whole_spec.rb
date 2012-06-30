require "sequel"
require "sequel/adapters/mysql"

module Sequel
  module MySQLPreview
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

describe Sequel::MySQLPreview::Database do

  let(:connection) { stub("connection") }
  before { subject.stub(:synchronize).and_yield(connection) }

  it "should allow SELECTs" do
    sql = "SELECT * FROM sometable"
    subject.should_receive(:puts).with(/^RUNNING:/)
    subject.should_receive(:_execute).with(connection, sql, anything)
    subject.execute(sql)
  end

  it "should not allow DELETEs" do
    sql = "DELETE FROM sometable"
    subject.should_receive(:puts).with(/^PREVIEW:/)
    subject.should_not_receive(:_execute)
    subject.execute(sql)
  end

  it "should not allow DROPs" do
    sql = "DROP TABLE sometable"
    subject.should_receive(:puts).with(/^PREVIEW:/)
    subject.should_not_receive(:_execute)
    subject.execute(sql)
  end

end

