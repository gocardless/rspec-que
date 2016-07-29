# RSpec Que matchers

This gem defines a matcher for checking that Que jobs have been enqueued,
in the style of [rspec-activejob](https://github.com/gocardless/rspec-activejob).

## Usage
The matcher expects a block of code, and will expect that code to enqueue a job
in Que. The matcher can take a class for the job as its arguments. It can also
expect the job to be queued with arguments via `.with(arg1, arg2)` or at a
specific time via `.at(time)`.

If the matcher does not match, it will display informations about jobs queued
at the last stage of the matcher which did match. (For instance, if you specify
a job class, arguments, and a time, the matcher will display information about
jobs of the right class and arguments but at the wrong time.)

```ruby
# spec/spec_helper.rb
require 'rspec/que'

RSpec.configure do |config|
  config.include(RSpec::Que)

  # clean out the queue after each spec
  config.after(:each) do
    RSpec::Que.purge_jobs
  end
end

# spec/controllers/my_controller_spec.rb
RSpec.describe MyController do
  let(:user) { create(:user) }
  let(:params) { { user_id: user.id } }
  let(:later_time) { DateTime.parse("2038-01-01T01:02:03+00:00").utc }
  subject(:make_request) { described_class.make_request(params) }

  specify { expect { make_request }.to queue_up(RequestMaker).with(user) }
  specify { expect { make_request }.to queue_up(DelayedRequest).at(later_time) }
end
```

## Development

Setup:
``` shell
bundle install
```

Run tests:

``` shell
bundle exec rake

```
