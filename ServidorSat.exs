defmodule ServidorSAT do
  @nodo_remoto :nodo_cliente@localhost

  def iniciar() do
    # Registrar el tiempo de inicio
    inicio = :os.system_time(:millisecond)

    # Obtener la lista de archivos
    archivos = "./uf-20-01" |> File.ls!() |> Enum.map(&"./uf-20-01/#{&1}")

    # Obtener nodos disponibles
    nodos_disponibles = [@nodo_remoto | Node.list()]
    IO.puts("Nodos disponibles: #{inspect(nodos_disponibles)}")

    if length(nodos_disponibles) == 0 do
      IO.puts("No hay nodos disponibles.")
      :exit
    end

    # Dividir tareas entre nodos
    archivos
    |> Enum.chunk_every(div(length(archivos), length(nodos_disponibles)))
    |> Enum.zip(nodos_disponibles)
    |> Enum.each(fn {archivos_chunk, nodo} ->
      Node.spawn(nodo, ClienteSAT, :procesar_archivos, [self(), archivos_chunk])
    end)

    # Esperar resultados
    recibir_resultados(length(archivos))

    # Calcular el tiempo total de ejecución
    duracion_total = :os.system_time(:millisecond) - inicio
    IO.puts("Tiempo total de ejecución distribuida: #{duracion_total} ms")
  end

  defp recibir_resultados(0), do: :ok

  defp recibir_resultados(pendientes) do
    receive do
      {:resultado, archivo, resultado} ->
        ImpresoraResultados.imprimir(archivo, resultado)
        recibir_resultados(pendientes - 1)
    end
  end
end

ServidorSAT.iniciar()
