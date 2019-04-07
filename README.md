# Backend en Elixir

El entorno básico requiere tener instalado Earlang y Elixir. Por defecto se instala **mix** que será la herramienta principal para instalar librerias y paquetes en nuestro proyecto.
Con [**mix**](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html#exploring) también podremos lanzar tareas como la compilacion y los test.

## Step 1: Creacion del proyecto

Nos colocamos dentro del directorio donde queremos nuestro proyecto y ejecutamos el siguiente comando:

`mix new backend --sup`

Este comando nos crea un nuevo proyecto llamado **backend** con un módulo supervisor (determinado por el parámetro _--sup_). Este módulo tiene un comportamiento especial ya que se encarga de orquestar y vigilar otros procesos (child process). Un supervisor se encarga de arrancar sus procesos hijo y en el caso de que se caigan los lvantará automáticamente.

Tras ejecutar el comando tenemos la siguiente estructura:
- **mix.exs** este es el fichero de configuración de las tareas de mix. Entre otras cosas aqui definiremos las dependencias que necesite nuestra aplicación.
- **config/config.exs** este fichero contendrá todas las configuraciones que necesite nuesta aplicación.
- **lib** aqui estará el código de nuestra aplicación. Veámos que tenemos en este momento:
    - **lib/backend/application.ex** Este es el punto de partida de nuestra aplicación: el módulo supervisor. Aqui definimos los procesos hijo que se arrancarán cuando levantemos nuestro proyecto.
    - **backend.ex** módulo en blanco para que empecemos a desarrollar nuestro código en él.
- **test** aqui deberemos implementar los test de nuestra aplicación.

## Step 2: Añadir el servidor web

Vamos a añadir un par de paquetes a nuestra aplicación. Para ello añadiremos un par de líneas en el fichero **mix.exs**:

`
defp deps do
    [
      {:plug_cowboy, "~> 2.0" },
      {:jason, "~> 1.1" }
    ]
end
`

[**Cowboy**](https://github.com/ninenines/cowboy) es un servidor Http con un core minímo y optimizado para minimizar el consumo de recursos.

[**Jason**](https://github.com/michalmuskala/jason) es una libreria para parsear objetos a Json.

Ejecutamos el siguiente comando de **mix** para descargarnos estas nuevas dependencias.

`
mix deps.get
`

Vamos ahora a indicarle a nuestro supervisor que levante el servidor http Cowboy. Para ello vamos al fichero *lib/backend/application.ex* y añadimos las siguientes líneas dentro de la tupla _children_:

`
Plug.Cowboy.child_spec(
  scheme: :http,
  plug: Backend.Router,
  options: [port: 4000]
)
`

Lo que acabamos de hacer es decirle a nuestro supervisor que levante un proceso de Cowboy que atienda a peticiones *http* en el puerto *4000*. Tambien le hemos indicado que tenemos un módulo que se encarga del enrutamiento: **Backend.Router**

### Plug

El enrutamiento lo implementaremos en el módulo **Backend.Router** que implementamos en el el fichero **router.ex**. En este fichero usaremos [**Plug.Router**](https://hexdocs.pm/plug/Plug.Router.html#content). Esta macro nos provee de todos los métodos que necesitamos para atender las peticiones que lleguen a nuestra aplicación.

Inicialmente añadimos un método *get* que atienda a la url */about*.

### Arrancando la aplicación.

Para lanzar nuestra aplicación ejecutamos el siguiente comando:

`
mix run --no-halt
`

Si lanzamos una peticion a _http://localhost:4000/about_ nuestra aplicación debería responder con la version que definimos en el fichero *mix.exs*.

## Step 3: Entornos y configuración

Generalmente nos interesa tener diferentes configuraciones para cada entorno de ejecución (desarrollo, test, producción...). 
Todas las configuraciónes de _Elixir_ se especifican en el fichero _config.exc_ y en este fichero podemos ver la siguiente línea (al final del fichero):

`
import_config "#{Mix.env()}.exs"
`

Lo que hace esa línea es sobreescribir lo que hayamos especificado en _config.exs_ con el fichero correspondiente al entorno en el que estemos ejecutando. Por ejemplo si hemos especificado que el entrorno de ejecución es **prod** nos cargará el fichero **config/prod.exs** y las configuraciones de este reemplazarán a las de **config/config.exs**.

> La función _Mix.env()_ por defecto retorna el valor _dev_ por tanto intentará cargar el fichero **dev.exs**. Si este fichero no existe tendremos un error.

Cuando arrancamos la aplicacion podemos especificar el entorno en el comado de arranque:

`
MIX_ENV=prod mix run --no-halt
`

`
mix run --no-halt
`

En primer comando arranca la aplicación en el modo producción por tanto cual lancemos la petición a nuestro endpoint _/about_ recibiremos esta respuesta:

`
{
    "environment": "prod",
    "message": "Elvis is alive!",
    "version": "0.1.0"
}
`

En el segundo caso:

`
{
    "environment": "dev",
    "message": "Elvis is alive! (rehearsal time)",
    "version": "0.1.0"
}
`


## Step 3: Looger

Cuando creamos la aplicación mediante el comando _mix_, automáticamente se añade **Looger** a nuestro proyecto. Para usarlo debemos añadir **require Logger** en los módulos donde lo necesitemos. _Logger_ soporta los niveles clásicos (debug, info, warn y error). En el fichero de configuraciones (_config.exs_) podemos especificar a partir de que nivel queremos que _Logger_ nos imprima trazas. Por ejemplo, si añadimos la línea:

`
config :logger, level: :info
`

Logger imprimirá los niveles _info_, _warn_ y _error_, pero no _debug_

Podemos configurar infinidad de parámetros para _Logger_. Por ejemplo el parámetro _:backend_ nos permite especificar donde se imprimirán los mensajes. El valor por defecto es _:console_ (la clásica consola) pero podemos instalar módulos que nos persistan los mensajes en otras salidas.

Para desviar las trazas a un fichero deberemos instalar algun paquete adicional. En este caso usaremos [LoggerFileBackend](https://github.com/onkel-dirtus/logger_file_backend).

Añadimos la dependecia a Mix (_mix.exs_):

`
{:logger_file_backend, "~> 0.0.10"}
`

Vamos a configurarlo para que sólo nos escriba las trazas de error en el entorno de producción. Para ello abrimos el fichero de _prod.exs_ y añadimos:

`
config :logger, backends: [{LoggerFileBackend, :error_log}]
`

Con esa línea indicamos que se cree un log con el nombre _:error_log_ (podemos especificar varios para loggear, por ejemplo, diferentes niveles a diferentes ficheros).

`
config :logger, :error_log, path: "logs/prod_error.log", level: :error
`

Por último configuramos _:error_log_ y le indicamos el nivel de los errores a guardar y la ruta al fichero.

<!--
## Step 4: Autenticación

_Próximamente_

## Step 5: Persistencia

_Próximamente_

## Step 6: Test

_Próximamente_

!-->