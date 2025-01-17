Proyecto SAT
Este proyecto resuelve problemas de satisfacción booleana (SAT) utilizando tres enfoques diferentes: secuencial, paralelo, y distribuido. Cada solución mide el tiempo total de ejecución para resolver un conjunto de archivos en formato CNF y genera un archivo CSV con los resultados. Finalmente, se crea una gráfica comparativa de los tiempos de ejecución de las tres soluciones.

Soluciones Implementadas
Solución Secuencial:
Resuelve los problemas SAT uno por uno de manera secuencial.
Ejecución:
elixir .\SolucionSecuencial.exs

Solución Paralela:
Divide los problemas SAT entre múltiples procesos para ejecutarlos en paralelo, aprovechando el rendimiento de múltiples núcleos de CPU.
Ejecución:
elixir .\SolucionParalela.exs

Solución Distribuida:
Divide la carga entre nodos distribuidos en diferentes máquinas (o instancias de Elixir) para resolver los problemas colaborativamente.
Ejecución:

Iniciar el cliente:
elixir --sname nodo_cliente@localhost --cookie my_cookie ClienteSAT.exs

Iniciar el servidor:
elixir --sname nodo_servidor@localhost --cookie my_cookie ServidorSAT.exs

Salida y Gráfica
Cada solución escribe el tiempo de ejecución en un archivo resultados.csv. Al finalizar las tres ejecuciones, se genera un archivo grafica.html que muestra una gráfica comparativa de los tiempos utilizando Google Charts.

Ejecutar el archivo generarGrafica.exs para generar la grafica a partir de los datos del archivo csv
elixir generarGrafica.exs

Nota: Abre grafica.html en un navegador para visualizar la comparación.