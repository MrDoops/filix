# Filix

Flexible File Management capabilities designed for modern event-driven systems.

Filix is a stateful OTP application that supports runtime configuration of dependencies for
persistence, storage providers (S3, GCS, etc), query and event messaging capabilities.

The goal is that you can plug Filix into any Elixir application where you want to upload and manage
static files. Filix emits a variety of events to the event messaging adapter you configure to support
live monitoring of upload progress with presigned url uploads so long as the client notifies of progress.

Files can be tagged in Filix either to start when Requesting an Upload, or afterward. Events are emitted to the 
configured event_messaging adapter, so when a file is successfully uploaded or tagged your custom event handler can 
do things like associate that file to other records in your database. Additionally since you can send Filix 
upload progression messages, your client-side upload code can ensure live server-side monitoring of an upload even when
using a pre-signed url method.

I've run into many situations where I wanted a reference to an uploaded file in a variety of places for some business requirement and I've found this event-driven approach to be a maintainable pattern for file management.

For example if you have some business workflow such as in Sales where you shouldn't proceed until someone uploads the signed contract 
to your system you can use Filix to Request an Upload, then handle the Upload Completed event tagged with some id in your
system.

## Installation

Add Filix to your application's `mix.exs` dependencies:

```elixir
def deps do
  [
    {:filix, "~> 0.1.0"}
  ]
end
```

Next we need to add Filix as a child in a Supervision tree such as the generated default in `mix new --sup`'s `application.ex` file:

```elixir
defmodule MyApp.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      {Filix, [
        query: MyApp.FilixQuery,
        persistence: MyApp.FilixPersistence,
        event_messaging: MyApp.FilixEventForwarder,
      ]}
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

The options Filix requires are your startup defaults. During each call to Request Upload you can still override
the behaviour implementations for Query, Peristence, and Event Messaging. Additionally since all the configuration is
runtime modifiable you could always spawn an new Filix application ad-hoc.

### Work In Progress Software

Filix is still a work in progress. While I had needs for Filix's featureset for many different applications
this is mostly an experiment for how one can properly compose a stateful capabilities like file & upload management.

I first started working on Filix when I was still new to Elixir, but have since picked the project up again to implement with 
newer conventions.

Some things I'm still working out:

[ ] - Multi-node configuration. Filix currently depend's on Elixir's Registry when spawning UploadProcess under a DynamicSupervisor.
  This makes Filix's runtime single node, however since the query, persistence, and event_messaging are configurable the implementation itself can be multi-node to monitor uploads. I still need to think more about the best way to tackle distribution.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `filix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:filix, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/filix](https://hexdocs.pm/filix).