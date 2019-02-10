# Rumbl

A video-watching application where each video added has it's own chatroom using websockets, each message is saved to the database at that timestamp and also broadcasted to anyone else also watching that video live.

When posting an annotation the server sends out API calls to wolfram alpha which will then try to get info on what is being talked about, for example:

```
[51:22] steve: When was elixir created?
[51:22] wolfram: 2011
```

These wolfram replies are cached, so replies will be stored in an ETS table and wiped after a little while.

#### Elixir version 1.8

#### Phoenix version 1.4

in `prod.secret.exs` add `config :rumbl, :wolfram, app_id: "Wolfram app_id here"` at the bottom.

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `cd assets && npm install`
- Migrate the database with `mix ecto.migrate`
- Add the wolfram user to the database `mix run priv/repo/backend_seeds.exs`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).
