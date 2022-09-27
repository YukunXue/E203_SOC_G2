// See LICENSE for license details.
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include "hbird_sdk_soc.h"
#include "hbirdv2_gpio.h"

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
void plic_btn_handler(void)
{
    int mask;

    printf("Enter PLIC GPIOA Interrupt\n");
    mask = gpio_clear_interrupt(GPIOA);
    switch (mask) {
        case SOC_BUTTON1_GPIO_MASK:
            printf("Cause: Button U \n");
            gpio_toggle(GPIOA, SOC_LED_0_MASK);
            printf("LED 0 Toggled \n");
            break;
        default:
            break;
    }
}

void board_gpio_init(void)
{

    gpio_enable_input(GPIOA, SOC_BUTTON1_GPIO_MASK);
    gpio_enable_output(GPIOA, SOC_LED_0_MASK);
    gpio_write(GPIOA, SOC_LED_0_MASK, GPIO_BIT_ALL_ZERO);
    // Initialize the button as rising interrupt enabled
    gpio_enable_interrupt(GPIOA, SOC_BUTTON1_GPIO_MASK, GPIO_INT_RISE);
}

void delayms( uint z )          /* 毫秒 */
{
	uint x, y;
	for ( x = z; x > 0; x-- )
		for ( y = 300; y > 0; y-- );
}

int main(void)
{
	int32_t returnCode;
	board_gpio_init();

	// inital plic GPIOA interrupt
	returnCode = PLIC_Register_IRQ(PLIC_GPIOA_IRQn, 1, plic_btn_handler);

    for (int i = 0; i < 20; i ++) {
        printf("%d: Hello World From RISC-V Processor!\r\n", i);
      //  gpio_toggle(GPIOA,SOC_LED_1_MASK);
        delayms(2000);
    }
    // Enable interrupts in general.
    __enable_irq();

    printf("Wait for Interrupt \n");
    // Wait button 1 and button 2 pressed to trigger interrupt
    while (1);
    return 0;
}

