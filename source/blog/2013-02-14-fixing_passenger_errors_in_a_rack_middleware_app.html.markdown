---
title: Fixing Passenger errors in a Middleware app
date: 2013-02-14 22:44 +01:00
subtitle: 'Fix an annoying issue when using a Middleware in Passenger'
---

Every now and then i notice a "Cannot read response from backend process: Connection reset by peer (104)" exception in my Nginx error log. Time to fix that puppy!

READMORE

For an app i'm working on i had an issue with one of the middleware i used to authenticate users for an api. The middleware looks like this:


```ruby
module Authenticator
  class Authentication

    def initialize(app, options = {})
      @app, @options = app, options
    end

    def call(env)
      if authenticated?
        @app.call(env)
      else
        [
          401,
          {
            'Content-Type'=>'text/plain',
            'Content-Length' => '0',
            'WWW-Authenticate' => 'Basic realm="App"'
          },
          []
        ]
      end
    end

    def authenticated?
    false
    end
  end
end
```

Every time someone posted data to the app but wasn't allowed in i'd see the following error in my Nginx logs:

```ruby

[ pid=26064 thr=139830692140800 file=ext/nginx/HelperAgent.cpp:933 time=2013-02-01 12:27:57.713 ]: Uncaught exception in PassengerServer client thread:
  exception: Cannot read response from backend process: Connection reset by peer (104)
  backtrace:
    in 'void Client::forwardResponse(Passenger::SessionPtr&, Passenger::FileDescriptor&, const AnalyticsLogPtr&)' (HelperAgent.cpp:698)
    in 'void Client::handleRequest(Passenger::FileDescriptor&)' (HelperAgent.cpp:859)
    in 'void Client::threadMain()' (HelperAgent.cpp:952)

```

First i thought it was because i was returning a 401 and passenger was expecting some headers i didn't send. But even with the 'WWW-Authenticate' and 'Content-Length' headers it still raised the error.

Turns out that before you can return a response to passenger you need to get all the data passenger sends you. In this case the return came before i read the POST data from the request.

The solution is pretty simple, read the post data first before you return your own data.

```ruby
env['rack.input'].read(1)
env['rack.input'].rewind
```

This way passenger will accept your response and doesn't trow any errors.

```ruby
module Authenticator
  class Authentication

    def initialize(app, options = {})
      @app, @options = app, options
    end

    def call(env)
      if authenticated?
        @app.call(env)
      else

        # Read the body before returning data to passenger
        env['rack.input'].read(1)
        env['rack.input'].rewind

        [
          401,
          {
            'Content-Type'=>'text/plain',
            'Content-Length' => '0',
            'WWW-Authenticate' => 'Basic realm="App"'
          },
          []
        ]
      end
    end

    def authenticated?
    false
    end
  end
end
```
