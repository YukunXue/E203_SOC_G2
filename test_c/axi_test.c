#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include "hbird_sdk_soc.h"
#include "hbirdv2_gpio.h"

#define PWM_LED_BASE  0x40000000
#define PWM_LED_REG0  0
#define PWM_LED_REG1  4
#define PWM_LED_REG2  8

//GPIO Bit offset
#define SOC_LED_0	0
#define SOC_LED_1	1
#define SOC_LED_2	2
#define SOC_LED_3 	3
#define SOC_BUTTON_1 4
#define SOC_BUTTON_2 5

//GPIO Bit Mask
#define SOC_LED_0_MASK	BIT(SOC_LED_0)
#define SOC_LED_1_MASK	BIT(SOC_LED_1)
#define SOC_LED_2_MASK	BIT(SOC_LED_2)
#define SOC_LED_3_MASK	BIT(SOC_LED_3)
// LED pin low is light




//GPIO Button Mask
#define SOC_BUTTON1_GPIO_MASK BIT(SOC_BUTTON_1)
#define SOC_BUTTON2_GPIO_MASK BIT(SOC_BUTTON_2)

int main(void)
{


    int wrvalue = 1;
    int rdvalue = 0;

    int rdled = 0;
    unsigned int *led_base;


    led_base =(unsigned int *)PWM_LED_BASE;
    rdvalue = *led_base;
    //delay_1ms(100);
    delay_1ms(100);
    *led_base = 0x00000000;

    printf("the old number is %d \n ",rdvalue);
    delay_1ms(1);

    *led_base = 0xffffffff;
    delay_1ms(100);
    rdvalue = *led_base;
    printf("the new number is %d \n  ",rdvalue);


    //*((int*)PWM_LED_BASE)=rdled;
    gpio_enable_output(GPIOA, SOC_LED_0_MASK);
    gpio_write(GPIOA, SOC_LED_0_MASK, GPIO_BIT_ALL_ZERO);
    delay_1ms(100);
    gpio_toggle(GPIOA,SOC_LED_0_MASK);
    for (int i = 0; i < 20; i ++) {
        printf("%d and %d: Hello World From RISC-V Processor!\r\n", rdvalue,rdled);
    }
    return 0;
}
