# p2
Practica 3 para la asignatura de Informatica II de GISAM-URJC realizada por Juan Antonio Cejudo Ventura

# BST #
Se implementa un BST generico para guardar los clientes activos. Se usa como key el nick de cada cliente recibido que nos apunta a una tupla del tipo (Socket.Address?, Date) para guardar asi los datos de cada cliente. Para acceder a cada uno de los valores es facil ya que solo tendriamos que invocar value.0 para su direccion y value.1 para su fecha.

Si se recibe un cliente del cual ya existe el nick lo rechazamos. 

Si un cliente nuevo quiere conectarse pero esta el server lleno escogemos el cliente que lleve mas inactivo comparando sus fechas y quedandonos con el mas antiguo, este ultimo cliente se ira al array ordenado con el motivo de "idle" y el cliente que queria entrar puede acceder.

Para la funcion broadcast usamos a su vez la funcion <traverse> para asi acceder a todos los clientes, con una condicion if para no reenviar el mensaje al cliente que envia. Usando <traverse> igualmente es como enseñamos los clientes por pantalla.

<remove> el codigo que ejecuta la accion de borrado en esta funcion esta localizado en la rama if else, para borra nodos sin o con un hijo.
Si se trata de un nodo con dos hijos  tenemos que buscar el valor minimo y lo asignamos a nuestra variable local. Seguido borramos el minimo del sub-arbol de la derecha y lo asignamos.

Las funciones que vienen en la extension <Extra...> son funciones puestas para mi practica personal y no son necesarias para el funcionamiento general de la practica.

# Array de busqueda binaria  #
En este vamos a colocar a todos los clientes que se hayan desconectado. Un cliente se puede haber desconectado por dos motivos, porque estaba <idle> o porque ha hecho <logout>, este motivo queda reflejado en el array con la variable <reason> que indica porque se desconecta cada cliente.

El array se ordena llamando a la funcion <sorting> que ordena el array de forma alfabetica en minusculas, esta funcion se llama cada vez que se recibe un cliente nuevo.

Impelemntacion de <binarySearch>: partimos de dos variables high y low que usamos para encontrar el medio del array. Sabemos el total del  array porque cada vez que se añade un cliente la cuenta suma 1 y esta suma es loo que recibe la variable <highIndex>. Despues de haber encontrado el medio comprobamos si ese valor es el que buscamos, si es menor del que se busca se elimina de la busqueda la mitad mayor que ese valor del array y si es mayor se elimina la mitad menor.

Como en esta practica para lo unico que se va a llamar <binarySearch> es para comprobar si existe un cliente con ese nick guardado y si existe hacer que se reconecte, decidi implementar directamente un remove en esta funcion para simplificar el codigo.

# REJOINS #
Si un cliente se desconecto, por el motivo que sea, se guarda en el array de <offClients> que se comprueba cada vez que se conecta un nuevo cliente.
La comprobacion se lleva a cabo en <newConnection> en los if else, si llamamos a la funcion a <binarySearch> y esta devuelve "true" se elmina el cliente del array offline y se llama a la funcion <toTree> con el valor de returning "true" para poder enviar al resto de clientes "\(nick) rejoins the chat", si la llamada devuelve "false" el valor de returning seria "false" por lo que el cliente es "nuevo" y no se esta reconectando.

# CLIENTES MAXIMOS SERVER #
Los clientes deben ser de 2 a 50, este numero se da al lanzar el server por linea de comandos, si el valor introducido no esta comprendido entre esos dos valores el programa pedira introducir por teclado un valor que este entre ellos. No se lanzara el servidor hasta que se introduzca un numero valido.

Una vez introducido este valor se pasara al arbol para que cuando se llegue al limite y un cliente nuevo desee conectarse al server poder borrar el cliente que lleve mas tiempo inactivo.

# CLIENTES MAXIMOS EN ARRAY #
En la ultima clase se que algun compañero dijo que el estaba limitando la cantidad de clientes que tenia en su array de clientes offline, pero como en el pdf de la practica no vi que en ningun momento se hablara del asunto decidi no implementarlo.

A description of this package.
