defmodule Enmark.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Enmark.Tasks}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Enmark.Supervisor)
  end
end
