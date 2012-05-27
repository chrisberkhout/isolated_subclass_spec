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

end

