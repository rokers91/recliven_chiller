/*
cuando estoy desvinculado y luego me vuelvo a vincular el settings no se muestra, porque en el init state es que se envia el comando

Notas:
7-temperatura en la vista del main
*/

//TODO: tengo que incorporar en un label el tipo de fallo y boton para atenderla

//al presionar salir si se esta conectado hay que darle dos veces al boton para que salga d la app, resolver esto

/*
para el caso de la ventana principal
se debe mostrar 
-circuito valor entero (byte)
-estado byte tratarlo como binario (convertirlo a binario) bit 0 (on/off) bit(0-3) estado de los fallos bit(3aceite, 2presion de alta, 1presion de baja)
-tiempo byte en funcion de dias 255/24 hace 10 dias(muy poco) por lo que me va enviar es dias entonces 255 es 255 dias
poner timeout para el caso de que se tarde en recibir la trama


**configuracion 
//solicitud para 
setpointTemp 7-15----5 alarma
difTotal 5-10
numeroEsclavos 1-8
anticicloTime tiempo apagado antes de volverlo a encender (5min)


**eventos
poner dos botones cargar(L), exportar(X), limpiar(E) (para evitar )



configuracion:  tempSP, deltaTemp, #sclavos, tCorto,  (U)
ventana principal: circuito, estado, tiempoTrabajado  (R)
eventos:                          (L)



 */