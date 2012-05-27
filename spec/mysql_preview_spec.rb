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
  it "shouldn't work" do
    pending "super is not a method, it's a keyword"
    # see David Chelimsky's response: http://rubyforge.org/pipermail/rspec-users/2009-May/014656.html
    #
    # not possible to wrap rather than inherit (because #execute is invoked internally)
  end

  it "should work" do
    pending "ERROR: SystemStackError: stack level too deep"
    query = "SELECT * FROM atable;"
    Sequel::MySQL::Database.any_instance.should_receive(:execute).with(query, {})
    subject.execute(query)
  end

  describe "mocking super" do
    it "does not sork" do
      pending "super: no superclass method 'foo' for '':MyString"
      class MyString < String
        def foo
          super("arg")
        end
      end
      MyString.any_instance.stub(:super).and_return(nil)
      MyString.new.foo
    end
  end

  describe "it" do
    it "does not work" do
      pending "doesn't work"
      class MyString < String; end
      class MyStringSub < MyString; end
      MyString.any_instance.stub(:foo).and_return("yes")
      MyString.stub(:foo).and_return("yes class")
      puts "instance => " + MyString.new.foo
      puts "sub instance => " + MyStringSub.new.foo # => stack level too deep
      puts "class => " + MyString.foo
    end
  end

end

describe "module super" do
  it "should work" do
    pending "ERROR: undefined method `any_instance' for Kernel:Module (NoMethodError)"
    module M
      def puts(msg)
        super("myputs "+msg)
      end
    end
    class C < Object
      include M
    end
    puts C.ancestors.inspect
    c = C.new
    Kernel.any_instance.should_receive(:puts).with("myputs hello")
    c.puts "hello"
  end
  it "should work now" do
    pending "ERROR: various.. don't really understand it."
    module M
      def puts(msg)
        super("myputs "+msg)
      end
    end
    class C
      include M
    end
    c = C.new
    puts C.ancestors.inspect
    module Kernel
      should_receive(:puts)
    end
    c.puts "hello"
  end
end

