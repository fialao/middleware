require File.join(File.dirname(__FILE__), '../', 'spec_helper')

describe Middleware::Runner do

  it "works with an empty stack" do
    subject = described_class.new []
    expect { subject.call Hash.new }.to_not raise_error
  end

  context "with classes" do
    let(:env) { { result: [] } }
    let(:a)   { Class.new { def initialize(app); @app = app; end
                            def call(env); env[:result] << 'A'; @app.call env; env[:result] << 'A'; end } }
    let(:b)   { Class.new { def initialize(app); @app = app; end
                            def call(env); env[:result] << 'B'; @app.call env; env[:result] << 'B'; end } }
    subject   { described_class.new [a, b] }

    it "calls classes in the proper order" do
      subject.call env
      env[:result].should == ['A', 'B', 'B', 'A']
    end
  end

  context "with lambdas" do
    let(:data)  { Array.new }
    let(:a)     { lambda { |env| data << 'A' } }
    let(:b)     { lambda { |env| data << 'B' } }
    subject     { described_class.new [a, b] }

    it "calls lambdas in the proper order" do
      subject.call Hash.new
      data.should == ['A', 'B']
    end
  end

  context "with middleware argument or block" do
    let(:env)             { Hash.new }
    let(:with_argument)   { Class.new { def initialize(app, value); @app = app; @value = value; end
                                        def call(env); env[:result] = @value; end } }
    let(:with_block )     { Class.new { def initialize(app, &block); @app = app; @block = block; end
                                        def call(env); env[:result] = @block.call; end } }

    it "passes in arguments if given" do
      subject = described_class.new([[with_argument, 42]])
      subject.call env
      env[:result].should == 42
    end

    it "passes in a block if given" do
      block = Proc.new { 42 }
      subject = described_class.new([[with_block, nil, block]])
      subject.call env
      env[:result].should == 42
    end
  end

  it "raises an error if an invalid middleware is given" do
    expect { described_class.new [27] }.to raise_error
  end

  it "doesn't call middlewares which aren't called" do
    data  = []
    env   = {}

    # A does not call B, so B should never execute
    a = Class.new { def initialize(app); @app = app; end
                    define_method :call do |env| data << 'A' end }
    b = lambda    { |env| data << 'B' }

    subject = described_class.new([a, b])
    subject.call env
    data.should == ['A']
  end

  describe "exceptions" do
    it "propagates the exception up the middleware chain" do
      # This tests a few important properties:
      # * Exceptions propagate multiple middlewares
      #   - C raises an exception, which raises through B to A.
      # * Rescuing exceptions works
      data  = []
      env   = {}

      a = Class.new { def initialize(app); @app = app; end
                      define_method :call do |env| data << 'A'; begin; @app.call(env); data << 'NEVER'; rescue Exception => e; data << 'E'; raise; end; end }
      b = Class.new { def initialize(app); @app = app; end
                      define_method :call do |env| data << 'B'; @app.call(env); end }
      c = lambda { |env| raise "ERROR" }

      subject = described_class.new([a, b, c])
      expect { subject.call env }.to raise_error
      data.should == ['A', 'B', 'E']
    end

    it "stops propagation if rescued" do
      # This test mainly tests that if there is a sequence A, B, C, and
      # an exception is raised in C, that if B rescues this, then the chain
      # continues fine backwards.
      data  = []
      env   = {}

      a = Class.new { def initialize(app); @app = app; end
                      define_method :call do |env| data << 'IN_A'; @app.call(env); data << 'OUT_A' end }
      b = Class.new { def initialize(app); @app = app; end
                      define_method :call do |env| data << 'IN_B'; @app.call(env) rescue nil; data << 'OUT_B' end }
      c = lambda { |env| data << 'IN_C'; raise 'BAD'; }

      subject = described_class.new([a, b, c])
      subject.call env
      data.should == ['IN_A', 'IN_B', 'IN_C', 'OUT_B', 'OUT_A']
    end
  end
end
