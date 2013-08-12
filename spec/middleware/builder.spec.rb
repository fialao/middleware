require File.join(File.dirname(__FILE__), '../', 'spec_helper')

describe Middleware::Builder do
  let(:data)    { { data: [] } }
  subject       { described_class.new }

  # This returns a proc that can be used with the builder
  # that simply appends data to an array in the env.
  def appender_proc(data)
    Proc.new { |env| env[:data] << data }
  end

  describe "#use" do
    it "adds items to the stack and make them callable" do
      data = {}
      proc = Proc.new { |env| env[:data] = true }

      subject.use proc
      subject.call data

      data[:data].should == true
    end

    it "adds multiple items" do
      data = {}
      proc1 = Proc.new { |env| env[:one] = true }
      proc2 = Proc.new { |env| env[:two] = true }

      subject.use proc1
      subject.use proc2
      subject.call data

      data[:one].should == true
      data[:two].should == true
    end

    it "adds another builder" do
      data  = {}
      proc1 = Proc.new { |env| env[:one] = true }

      one = described_class.new                                       # build the first builder
      one.use proc1
      two = described_class.new                                       # add it to this builder
      two.use one

      two.call data                                                   # call the 2nd and verify results
      data[:one].should == true
    end

    it "defaults the env to `nil` if not given" do
      result  = false
      proc    = Proc.new { |env| result = env.nil? }

      subject.use proc
      subject.call

      result.should be
     end
  end

  describe "#insert" do
    it "can insert at an index" do
      subject.use appender_proc(1)
      subject.insert 0, appender_proc(2)
      subject.call data

      data[:data].should == [2, 1]
    end

    it "can insert next to a previous object" do
      proc2 = appender_proc(2)

      subject.use appender_proc(1)
      subject.use proc2
      subject.insert proc2, appender_proc(3)
      subject.call data

      data[:data].should == [1, 3, 2]
    end

    it "raises an exception if attempting to insert before an invalid object" do
      expect { subject.insert 'object', appender_proc(1) }.to raise_error(RuntimeError)
    end
  end

  describe "#insert_before" do
    it "can insert before" do
      subject.use appender_proc(1)
      subject.insert_before 0, appender_proc(2)
      subject.call data

      data[:data].should == [2, 1]
    end
  end

  describe "#insert_after" do
    it "can insert after" do
      subject.use appender_proc(1)
      subject.use appender_proc(3)
      subject.insert_after 0, appender_proc(2)
      subject.call data

      data[:data].should == [1, 2, 3]
    end

    it "raises an exception if attempting to insert after an invalid object" do
      expect { subject.insert_after 'object', appender_proc(1) }.to raise_error(RuntimeError)
    end
  end

  describe "#replace" do
    it "can replace an object" do
      proc1 = appender_proc(1)
      proc2 = appender_proc(2)

      subject.use proc1
      subject.replace proc1, proc2
      subject.call data

      data[:data].should == [2]
    end

    it "can replace by index" do
      proc1 = appender_proc(1)
      proc2 = appender_proc(2)

      subject.use proc1
      subject.replace 0, proc2
      subject.call data

      data[:data].should == [2]
    end
  end

  describe "#delete" do
    it "can delete by object" do
      proc1 = appender_proc(1)

      subject.use proc1
      subject.use appender_proc(2)
      subject.delete proc1
      subject.call data

      data[:data].should == [2]
    end

    it "can delete by index" do
      proc1 = appender_proc(1)

      subject.use proc1
      subject.use appender_proc(2)
      subject.delete 0
      subject.call(data)

      data[:data].should == [2]
    end
  end
end
