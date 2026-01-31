#include <stdio.h>
#include "platform.h"
#include <xgpio.h>
#include "xparameters.h"
#include "sleep.h"

typedef union {
    float f;
    u32 i;
} FloatIntConverter;

XGpio inputButon;
XGpio inputX, inputY, inputOp, inputStart, inputReset, outputZ, outputGata;
FloatIntConverter dataX, dataY, dataZ; 

void init_calc(){
    printf("Introduceti valoarea lui X: \n");
    scanf("%f", &dataX.f);
    printf("Am primit x!\n");
    printf("Introduceti valoarea lui Y: \n");
    scanf("%f", &dataY.f);
     printf("Am primit y!\n");

    XGpio_DiscreteWrite(&inputX, 1, dataX.i);
    XGpio_DiscreteWrite(&inputY, 1, dataY.i);

    XGpio_DiscreteWrite(&inputReset, 1, 1); 
    XGpio_DiscreteWrite(&inputStart, 1, 0);
    usleep(1000); 
    XGpio_DiscreteWrite(&inputReset, 1, 0); 
}

int main() {

    int button_data = 0;
    int button_prev = 0;

    init_platform();
    printf("Incepem procesarea ALU\n");

    XGpio_Initialize(&inputButon, XPAR_AXI_GPIO_BTN_BASEADDR);
    XGpio_Initialize(&inputX, XPAR_AXI_GPIO_X_BASEADDR);
    XGpio_Initialize(&inputY, XPAR_AXI_GPIO_Y_BASEADDR);
    XGpio_Initialize(&inputStart, XPAR_AXI_GPIO_START_BASEADDR);
    XGpio_Initialize(&inputOp, XPAR_AXI_GPIO_OP_BASEADDR);
    XGpio_Initialize(&inputReset, XPAR_AXI_GPIO_RESETARE_BASEADDR);
    XGpio_Initialize(&outputZ, XPAR_AXI_GPIO_Z_BASEADDR);
    XGpio_Initialize(&outputGata, XPAR_AXI_GPIO_GATA_BASEADDR);

    XGpio_SetDataDirection(&inputButon, 1, 0xF); 
    
    XGpio_SetDataDirection(&inputX, 1, 0x0);
    XGpio_SetDataDirection(&inputY, 1, 0x0);
    XGpio_SetDataDirection(&inputOp, 1, 0x0);
    XGpio_SetDataDirection(&inputStart, 1, 0x0);
    XGpio_SetDataDirection(&inputReset, 1, 0x0);
    
    XGpio_SetDataDirection(&outputZ, 1, 0xF);
    XGpio_SetDataDirection(&outputGata, 1, 0x1);

    init_calc();
    
    printf("Operanzi setati: X = %f, Y = %f\n", dataX.f, dataY.f);

    while(1) {
        button_data = XGpio_DiscreteRead(&inputButon, 1);

        if(button_data != 0b00000 && button_prev == 0b00000){
            usleep(20000);
            if (button_data == 0b00001) { 
                printf("Efectuam adunarea \n");
                XGpio_DiscreteWrite(&inputOp, 1, 0b00); 
                
                dataZ.i = XGpio_DiscreteRead(&outputZ, 1);
                printf("Suma Obtinuta este %f \n", dataZ.f);
            } 
            else if (button_data == 0b00010) { 
                printf("Efectuam scaderea \n");
                XGpio_DiscreteWrite(&inputOp, 1, 0b01); 
                
                dataZ.i = XGpio_DiscreteRead(&outputZ, 1);
                printf("Diferenta Obtinuta este %f \n", dataZ.f);
            } 
            else if (button_data == 0b00100) { 
                printf("Efectuam inmultirea \n");
                
                XGpio_DiscreteWrite(&inputOp, 1, 0b10);
                
                XGpio_DiscreteWrite(&inputStart, 1, 1);
                
                int gataInmultire = 0;
                do{
                    
                    gataInmultire = XGpio_DiscreteRead(&outputGata, 1);

                }while(gataInmultire == 0);

                usleep(1000);


                if(XGpio_DiscreteRead(&outputGata, 1) == 1){
                    dataZ.i = XGpio_DiscreteRead(&outputZ, 1);
                    printf("Produsul Obtinut este %f \n", dataZ.f);
                }

                XGpio_DiscreteWrite(&inputStart, 1, 0); 
                
            } 
            else if (button_data == 0b01000) { 
                printf("Efectuam impartirea \n");
                
                XGpio_DiscreteWrite(&inputOp, 1, 0b11); 
                
                XGpio_DiscreteWrite(&inputStart, 1, 1);
                
                int gataImpartire = 0;
                do{
                    
                    gataImpartire = XGpio_DiscreteRead(&outputGata, 1);

                }while(gataImpartire == 0);

                usleep(1000);


                if(XGpio_DiscreteRead(&outputGata, 1) == 1){
                    dataZ.i = XGpio_DiscreteRead(&outputZ, 1);
                    printf("Rezultatul obtinut este %f \n", dataZ.f);
                }

                XGpio_DiscreteWrite(&inputStart, 1, 0);
            } 
            else {
                printf("Apasati pe butoanele 1, 2, 3 sau 4\n");
                usleep(200000);
            }
            
            usleep(50000); 
        }

        button_prev = button_data;
    }

    cleanup_platform();
    return 0;
}