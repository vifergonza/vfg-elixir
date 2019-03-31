defmodule Backend.Router do

    require Logger

    use Plug.Router
    use Plug.ErrorHandler

    plug(:match)

    plug Plug.Parsers, parsers: [:json], pass:  ["application/json"], json_decoder: Jason

    plug(:dispatch)

    get "/about" do
        conn 
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(%{:message => "Elvis is alive!", :version => version()}))

    end

    @version Mix.Project.config[:version]
    def version(), do: @version

end