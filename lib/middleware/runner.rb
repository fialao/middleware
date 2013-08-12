module Middleware

  # This is a basic runner for middleware stacks. This runner does
  # the default expected behavior of running the middleware stacks
  # in order, then reversing the order.
  class Runner

    # A middleware which does nothing.
    EMPTY_MIDDLEWARE = lambda { |env| }


    # Build a new middleware runner with the given middleware stack.
    #
    # @note: This class usually doesn't need to be used directly.
    #   Instead, take a look at using the {Builder} class, which is
    #   a much friendlier way to build up a middleware stack.
    #
    # @param stack [Array] An array of the middleware to run.
    def initialize(stack)
      @kickoff = build_call_chain(stack)                              # we need to take the stack of middleware and initialize them
                                                                      # all so they call the proper next middleware
    end

    # Run the middleware stack with the given state bag.
    #
    # @param env [Object] The state to pass into as the initial
    #   environment data. This is usual a hash of some sort.
    def call(env)
      @kickoff.call env                                               # we just call the kickoff middleware, which is responsible
                                                                      # for properly calling the next middleware, and so on and so forth
    end


    protected

      # This takes a stack of middlewares and initializes them in a way
      # that each middleware properly calls the next middleware.
      #
      # @note We need to instantiate the middleware stack in reverse
      #   order so that each middleware can have a reference to
      #   the next middleware it has to call. The final middleware
      #   is always the empty middleware, which does nothing but return.
      #
      # @param stack [Array] An array of the middleware to run.
      def build_call_chain(stack)
        stack.reverse.inject(EMPTY_MIDDLEWARE) do |next_middleware, current_middleware|
          klass, args, block  = current_middleware                    # unpack the actual item
          args              ||= []                                    # default the arguments to an empty array (otherwise in Ruby 1.8
                                                                      # a `nil` args will actually pass `nil` into the class)
          if klass.is_a? Class                                        # if the klass actually is a class, then instantiate it with
            klass.new next_middleware, *args, &block                  # the app and any other arguments given
          elsif klass.respond_to? :call
            lambda do |env|                                           # make it a lambda which calls the item then forwards up the chain
              klass.call env
              next_middleware.call env
            end
          else
            raise "Invalid middleware, doesn't respond to `call`: #{action.inspect}"
          end
        end
      end

  end
end
