defmodule ImpresoraResultados do
  def imprimir(ruta_archivo, {:satisfactible, soluciones}) do
    IO.puts("Archivo: #{ruta_archivo}")
    IO.puts("Resultado: Satisfactible")
    #IO.puts("Tiempo: #{duracion} ms")

    soluciones
    |> Enum.each(&IO.puts("Solución: #{inspect(formatear_como_binario(&1))}"))
  end

  def imprimir(ruta_archivo, {:insatisfactible, _}) do
    IO.puts("Archivo: #{ruta_archivo}")
    IO.puts("Resultado: Insatisfactible")
    #IO.puts("Tiempo: #{duracion} ms")
  end

  # Formatear solución como binario
  defp formatear_como_binario(solucion) do
    for i <- 1..20 do
      if i in solucion, do: 1, else: 0
    end
  end
end
