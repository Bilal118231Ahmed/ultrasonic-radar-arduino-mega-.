# ultrasonic-radar-arduino-mega-.
OBJECTIVES:
HC-SR04 ultrasonic sensor

Servo motor (for scanning)

16×2 LCD (optional)



🧰 Hardware Setup
Ultrasonic Sensor (HC-SR04):

Trigger → PD2

Echo → PD3

Servo Motor:

PWM signal → PB5 (OC1A - Timer1)

Optional: 16×2 LCD:

RS → PA0, EN → PA1, D4–D7 → PA2–PA5

CODE FOR:
#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

#define TRIG_PIN PD2
#define ECHO_PIN PD3

volatile uint16_t pulse_width = 0;
volatile uint8_t capture_done = 0;

void ultrasonic_init() {
    DDRD |= (1 << TRIG_PIN);  // TRIG as output
    DDRD &= ~(1 << ECHO_PIN); // ECHO as input

    // Timer1 setup for Input Capture
    TCCR1A = 0;
    TCCR1B = (1 << ICES1) | (1 << CS11); // Rising edge, prescaler 8
    TIMSK1 = (1 << ICIE1);               // Enable input capture interrupt
    sei();
}

void trigger_ultrasonic() {
    PORTD &= ~(1 << TRIG_PIN);
    _delay_us(2);
    PORTD |= (1 << TRIG_PIN);
    _delay_us(10);
    PORTD &= ~(1 << TRIG_PIN);
}

ISR(TIMER1_CAPT_vect) {
    static uint16_t rising_edge = 0;
    static uint8_t edge = 0;

    if (edge == 0) {
        rising_edge = ICR1;
        TCCR1B &= ~(1 << ICES1);  // Switch to falling edge
        edge = 1;
    } else {
        uint16_t falling_edge = ICR1;
        pulse_width = falling_edge - rising_edge;
        edge = 0;
        capture_done = 1;
        TCCR1B |= (1 << ICES1);   // Switch back to rising edge
    }
}

uint16_t get_distance_cm() {
    capture_done = 0;
    trigger_ultrasonic();

    // Wait until capture is complete
    while (!capture_done);

    uint16_t distance = (pulse_width / 58); // Convert to cm
    return distance;
}

void pwm_servo_init() {
    DDRB |= (1 << PB5); // OC1A as output
    TCCR1A |= (1 << COM1A1) | (1 << WGM11); // Fast PWM, ICR1 top
    TCCR1B |= (1 << WGM13) | (1 << WGM12) | (1 << CS11); // Prescaler 8
    ICR1 = 40000; // 20ms period (50Hz)
}

void set_servo_angle(uint8_t angle) {
    uint16_t pulse = ((angle * 11) + 500); // ~500 to 2500us
    OCR1A = (pulse * 2); // Scale for 16MHz/8
}

int main(void) {
    ultrasonic_init();
    pwm_servo_init();

    while (1) {
        for (uint8_t angle = 0; angle <= 180; angle += 10) {
            set_servo_angle(angle);
            _delay_ms(500);

            uint16_t distance = get_distance_cm();
            // You can send `angle` and `distance` via UART or display on LCD

            _delay_ms(100);
        }
    }
}

