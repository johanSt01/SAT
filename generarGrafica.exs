defmodule GeneradorGrafica do
  def generar_grafica() do
    # Leer datos del CSV
    datos =
      "resultados.csv"
      |> File.stream!()
      |> Enum.map(fn linea ->
        [algoritmo, tiempo] = String.split(linea, ",")
        {algoritmo, String.to_integer(String.trim(tiempo))}
      end)

    titulos_y_datos = """
    ['Algoritmo', 'Tiempo (ms)'],
    #{Enum.map(datos, fn {algoritmo, tiempo} -> "['#{algoritmo}', #{tiempo}]" end) |> Enum.join(",\n")}
    """

    html_base =
      """
      <html>
        <head>
          <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
          <script type="text/javascript">
            google.charts.load('current', {'packages':['bar']});
            google.charts.setOnLoadCallback(drawChart);

            function drawChart() {
              var data = google.visualization.arrayToDataTable([
                <TITULOS_y_DATOS>
              ]);

              var options = {
                chart: {
                  title: 'Comparación de Algoritmos SAT',
                  subtitle: 'Tiempos de ejecución (ms)',
                }
              };

              var chart = new google.charts.Bar(document.getElementById('columnchart_material'));

              chart.draw(data, google.charts.Bar.convertOptions(options));
            }
          </script>
        </head>
        <body>
          <div id="columnchart_material" style="width: 800px; height: 500px;"></div>
        </body>
      </html>
      """

    html_final = String.replace(html_base, "<TITULOS_y_DATOS>", titulos_y_datos)
    File.write!("grafica.html", html_final)
    IO.puts("Gráfica generada en grafica.html")
  end
end

# Llama a esta función después de ejecutar las tres soluciones
GeneradorGrafica.generar_grafica()
