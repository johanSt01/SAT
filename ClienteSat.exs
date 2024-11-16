defmodule ClienteSAT do
  def start() do
    IO.puts("[#{Node.self()}] Cliente activo y esperando tareas...")
    :timer.sleep(:infinity) # Mantener el nodo activo indefinidamente
  end

  def procesar_archivos(nodo_servidor, archivos) do
    for archivo <- archivos do
      resultado =
        archivo
        |> leer_cnf()
        |> resolver()

      # Enviar el resultado al nodo maestro
      send(nodo_servidor, {:resultado, archivo, resultado})
    end
  end

  defp leer_cnf(ruta_archivo) do
    File.read!(ruta_archivo)
    |> String.split("\n")
    |> Enum.filter(&linea_valida?/1)
    |> Enum.map(&convertir_a_clausula/1)
  end

  defp linea_valida?(linea) do
    not (String.starts_with?(linea, "c") or
         String.starts_with?(linea, "p") or
         linea in ["%", "", "0"])
  end

  defp convertir_a_clausula(linea) do
    linea
    |> String.split()
    |> Enum.map(&String.to_integer/1)
    |> Enum.reject(&(&1 == 0))
  end

  def resolver(clausulas) do
    case dpll(clausulas, []) do
      [] -> {:insatisfactible, []}
      soluciones -> {:satisfactible, soluciones}
    end
  end

  defp dpll(clausulas, asignacion) do
    cond do
      Enum.all?(clausulas, &clausula_satisfecha?(&1, asignacion)) -> [asignacion]
      Enum.any?(clausulas, &(&1 == [])) -> []
      true ->
        variable = seleccionar_variable(clausulas, asignacion)
        dpll(simplificar(clausulas, variable), [variable | asignacion]) ++
          dpll(simplificar(clausulas, -variable), [-variable | asignacion])
    end
  end

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

  defp clausula_satisfecha?(clausula, asignacion) do
    Enum.any?(clausula, &(&1 in asignacion))
  end

  defp seleccionar_variable(clausulas, asignacion) do
    Enum.find_value(clausulas, fn clausula ->
      Enum.find(clausula, fn variable ->
        variable not in asignacion and -variable not in asignacion
      end)
    end)
  end
end

ClienteSAT.start()
