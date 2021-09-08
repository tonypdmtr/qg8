#include <hidef.h> /* for EnableInterrupts macro */
#include "derivative.h" /* include peripheral declarations */

void retardo(unsigned long delay);

void main(void) {
  /* include your code here */
  SOPT1 = 0x052;
  PTADD=0b00111100;
  PTASE=0b00000011;
  PTBDD=0b11110001;
  PTBSE=0b00001110;

  PTBD_PTBD0=1;
  PTAD_PTAD3=1;

  if(PTBD_PTBD3==1){ 	//leer segun retardo
  	PTBD_PTBD0=1;
  	PTAD_PTAD3=1;
  	do{
  		retardo(0xFF);

  	}while(PTBD_PTBD2==0);	/*espera a que se seleccione modo A*/
  	do{
  		retardo(0xFF);

  	}while(PTBD_PTBD1==0);		/*espera a que se seleccione input enable*/
  	PTBD_PTBD6=PTAD_PTAD0;		/*escribe en a0*/
  	PTBD_PTBD7=PTAD_PTAD1;		/*escribe en a1*/
  	retardo(0xFF);
  	PTBD_PTBD0=0;		/*CE*/
  	PTAD_PTAD3=0;		/*OE*/
  	retardo(0xFF);
  	PTBD_PTBD0=1;		/*CE*/
  	PTAD_PTAD3=1;		/*OE*/

  }
  else{					/*se selecicono modo w*/
	  PTBD_PTBD0=1;		/*CE*/
	  PTAD_PTAD3=0;		/*OE*/
	  PTAD_PTAD2=1;		/*WE*/
  	do{
  		retardo(0xFF);

  	}while(PTBD_PTBD2==0);		/*espera a que se seleccione modo A*/
  	do{
  		retardo(0xFF);

  	}while(PTBD_PTBD1==0);		/*espera a que se seleccione input enable*/
  	PTAD_PTAD3=1;		/*OE*/
  	PTBD_PTBD0=0;		/*CE*/
  	PTBD_PTBD6=PTAD_PTAD0;		/*escribe en a0*/
  	PTBD_PTBD7=PTAD_PTAD1;		/*escribe en a1*/
  	retardo(0xFF);

  	do{
  		retardo(0xFF);

  	}while(PTBD_PTBD2==1);		/*espera a que se seleccione modo D*/

  	do{
  		retardo(0xFF);

  	}while(PTBD_PTBD1==0);		/*espera a que se seleccione input enable*/

  	PTBD_PTBD4=PTAD_PTAD0;			/*escribe en I/O0*/
  	PTBD_PTBD5=PTAD_PTAD1;			/*escribe en I/O1*/
  	retardo(0xFF);

  	PTAD_PTAD2=1;		/*WE*/
  	retardo(0xFF);
  	PTBD_PTBD0=1;		/*CE*/
  	PTAD_PTAD3=0;		/*OE*/
  }
}

void retardo(unsigned long i){
	for(i; i>0; i--){
	}
}
