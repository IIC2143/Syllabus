# ¿Cómo testear mi tarea? 📚
1. Copia y pega en la raíz de tu el repositorio de tu tarea la carpeta `test` que se encuentra aquí. En caso de ya existir, reemplazala. 
2. Ejecuta el comanda `rails t` sobre el repositorio de tu tarea (luego de haber hecho `bundle install` y migrar la base de datos)
3. Debiese crearse un archivo `test_report.html` en la carpeta `public` donde podrás ver tu puntaje más claramente y los test cases que aún no pasan.

* Ignora mensajes como `[DEPRECATION] 'iic2143_reporter' is deprecated and ...`. Esta es una gema que usamos para generar el reporte de los tests.
 