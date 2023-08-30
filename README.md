# SubwaysideUi

Basic UI for the [Subwayside](https://github.com/mbta/subwayside) data.

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


## Show Car At

You'll need to set the `KINESIS_STREAM_NAME` environment variable with the stream to use, as well as either `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` or `AWS_PROFILE`
``` shell
export KINESIS_STREAM_NAME=<...>
export AWS_PROFILE=<...>
mix show_car_at <car number> <ISO timestamp>
```
