use Mix.Config
     config :backend, about_msg: "Elvis is alive!"
     config :logger, backends: [{LoggerFileBackend, :error_log}]
     config :logger, :error_log, path: "logs/prod_error.log", level: :error
