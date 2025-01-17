defmodule SolucionadorSAT do
  @csv_file "resultados.csv"

  def main() do
    # Registrar tiempo de inicio
    inicio = :os.system_time(:millisecond)

    # Obtener la lista de archivos en la carpeta "uf-20-01"
    "./uf-20-01"
    |> File.ls!()
    |> Enum.map(&"./uf-20-01/#{&1}")
    |> Enum.map(&procesar_archivo_async/1)
    |> Enum.each(&Task.await/1)

    # Registrar tiempo de fin y calcular tiempo total
    duracion_total = :os.system_time(:millisecond) - inicio
    IO.puts("Tiempo total de ejecución: #{duracion_total} ms")

    # Guardar el tiempo de ejecución en el CSV
    guardar_en_csv("Paralela", duracion_total)
  end

  # Guardar los datos en un archivo CSV
  defp guardar_en_csv(algoritmo, tiempo) do
    # Leer contenido existente del archivo
    contenido_actual =
      if File.exists?(@csv_file) do
        File.read!(@csv_file)
        |> String.split("\n", trim: true)
      else
        []
      end

    # Actualizar o agregar la nueva entrada
    contenido_actualizado =
      contenido_actual
      |> Enum.reject(fn linea -> String.starts_with?(linea, "#{algoritmo},") end)
      |> Kernel.++(["#{algoritmo},#{tiempo}"])

    # Escribir el contenido actualizado al archivo
    File.write!(@csv_file, Enum.join(contenido_actualizado, "\n"))
    end

  # Procesar cada archivo de forma asíncrona
  defp procesar_archivo_async(ruta_archivo) do
    Task.async(fn -> procesar_archivo(ruta_archivo) end)
  end

  # Procesar un archivo individual
  defp procesar_archivo(ruta_archivo) do
    # Leer y resolver el archivo
    resultado =
      ruta_archivo
      |> leer_cnf()
      |> resolver()

    # Pasar el resultado a la impresora
    ImpresoraResultados.imprimir(ruta_archivo, resultado)
  end

  # Leer y procesar el archivo CNF
  defp leer_cnf(ruta_archivo) do
    File.read!(ruta_archivo)
    |> String.split("\n")
    |> Enum.filter(&linea_valida?/1)
    |> Enum.map(&convertir_a_clausula/1)
  end

  # Filtrar líneas válidas
  defp linea_valida?(linea) do
    not (String.starts_with?(linea, "c") or
         String.starts_with?(linea, "p") or
         linea in ["%", "", "0"])
  end

  # Convertir una línea en una lista de enteros, eliminando el 0 final
  defp convertir_a_clausula(linea) do
    linea
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.reject(&(&1 == 0))
  end

  # Resolver el problema SAT usando DPLL
  def resolver(clausulas) do
    case dpll(clausulas, []) do
      [] -> {:insatisfactible, []}
      soluciones -> {:satisfactible, soluciones}
    end
  end

  # Algoritmo DPLL
  defp dpll(clausulas, asignacion) do
    cond do
      Enum.all?(clausulas, &clausula_satisfecha?(&1, asignacion)) ->
        [asignacion]

      Enum.any?(clausulas, &(&1 == [])) ->
        []

      true ->
        variable = seleccionar_variable(clausulas, asignacion)

        dpll(simplificar(clausulas, variable), [variable | asignacion]) ++
        dpll(simplificar(clausulas, -variable), [-variable | asignacion])
    end
  end

  # Simplificar cláusulas
  defp simplificar(clausulas, variable) do
    Enum.map(clausulas, fn clausula ->
      cond do
        variable in clausula -> nil
        -variable in clausula -> List.delete(clausula, -variable)
        true -> clausula
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  # Verificar si una cláusula está satisfecha
  defp clausula_satisfecha?(clausula, asignacion) do
    Enum.any?(clausula, &(&1 in asignacion))
  end

  # Seleccionar la próxima variable no asignada
  defp seleccionar_variable(clausulas, asignacion) do
    Enum.find_value(clausulas, fn clausula ->
      Enum.find(clausula, fn variable ->
        variable not in asignacion and -variable not in asignacion
      end)
    end)
  end
end

SolucionadorSAT.main()
