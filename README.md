# RSpec Que matchers

This gem defines a matcher for checking that Que jobs have been enqueued.  It is a more
 specific, less featured, clone of
 [rspec-activejob](https://github.com/gocardless/rspec-activejob).

It expects a block or proc to enqueue a job in Que. Optionally takes the job class as its
argument, and can be modified with a `.with(*args)` call to expect specific arguments.
This will use the same argument list matcher as rspec-mocks' `receive(:message).with(*args)` matcher.

```ruby
# spec/spec_helper.rb
require 'rspec/que'

RSpec.configure do |config|
  config.include(RSpec::ActiveJob)

  # clean out the queue after each spec
  config.after(:each) do
    RSpec::Que.purge_jobs
  end
end

# spec/controllers/my_controller_spec.rb
RSpec.describe MyController do
  let(:user) { create(:user) }
  let(:params) { { user_id: user.id } }
  subject(:make_request) { described_class.make_request(params) }

  specify { expect { make_request }.to queue_up(RequestMaker).with(user) }
end
```


