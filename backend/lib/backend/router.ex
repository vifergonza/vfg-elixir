defmodule Backend.Router do

    require Logger

    use Plug.Router
    use Plug.ErrorHandler

    plug(:match)

    plug Plug.Parsers, parsers: [:json], pass:  ["application/json"], json_decoder: Jason

    plug(:dispatch)

    get "/about" do

        Logger.debug "This is a debug msg"
        Logger.info "This is a info msg"
        Logger.warn "This is a warn msg"
        Logger.error "This is a error msg"

        conn 
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(%{:message => Application.get_env(:backend, :about_msg), :version => version(), :environment => Application.get_env(:backend, :env)}))

    end

    @version Mix.Project.config[:version]
    def version(), do: @version

end