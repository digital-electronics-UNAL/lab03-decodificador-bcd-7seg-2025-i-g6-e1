[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=19715005&assignment_repo_type=AssignmentRepo)
# Lab03: Decodificador BCD a 7segmentos


## Integrantes 

[Duván Alejandro Hernández Muñoz](https://github.com/rustam1012)

[Nixon Sebastian Escarpeta Duran](https://github.com/NixonSebastian13)

[Juan Andres Sierra Miranda](https://github.com/jusierram)

[Karen Alejandra cardenas](https://github.com/alejandraUN1208)


## Informe

Indice:

1. [Diseño implementado](#1-diseño-implementado)
2. [Simulaciones](#2-descripción)
3. [Implementación](#3-diagramas)
4. [Simulaciones](#4-simulaciones)
5. [Implementación](#5-implementación)
6. [Conclusiones](#conclusiones)

## 1. Diseño implementado

### 2. Descripción

En esta práctica de laboratorio se diseñó, simuló e implementó un sistema digital completo para calcular y visualizar los resultados de operaciones aritméticas en una tarjeta de desarrollo FPGA. El proyecto consistió en un sumador/restador de 8 bits cuyos resultados, tanto positivos como negativos, se muestran en cuatro displays de 7 segmentos. Para lograrlo, se implementó un sistema de visualización dinámica (multiplexación) controlado por un divisor de frecuencia y una lógica de separación decimal. El diseño se describió en Verilog, se validó mediante análisis de simulación y se verificó su funcionamiento en el montaje físico con la tarjeta FPGA.

## 2. Fundamento Teórico
### 2.1. Decimal Codificado en Binario (BCD)
El sistema BCD (Binary Coded Decimal) representa cada dígito decimal (0-9) con un número binario de 4 bits. Esta codificación es ideal para la interfaz entre la lógica binaria de un procesador y los displays numéricos.

### 2.2. Display de 7 Segmentos
Es un dispositivo compuesto por siete LEDs que, al activarse en combinaciones específicas, forman números y algunos caracteres. Para este proyecto, se utilizó un display de ánodo común, donde todos los ánodos están conectados a VCC. Para encender un segmento, se debe aplicar un nivel lógico bajo ('0') a su cátodo correspondiente.

### 2.3. Visualización Dinámica (Multiplexación)
Para controlar múltiples displays con un número reducido de pines, se utiliza la multiplexación. Esta técnica consiste en encender un solo display a la vez, mostrando su dígito correspondiente, y luego pasar al siguiente rápidamente. Si la frecuencia de refresco es lo suficientemente alta (típicamente > 60 Hz), la persistencia de la visión del ojo humano integra las imágenes individuales, percibiendo un número estable y sin parpadeos. Esto se logra controlando secuencialmente tanto los cátodos de los segmentos como los ánodos de habilitación de cada display.

### 2.4. Representación de Números Negativos
En la aritmética binaria, los resultados negativos de una resta se expresan en complemento a 2. Para mostrar este resultado en un formato decimal legible, se debe:
* Detectar el signo negativo (generalmente, cuando el acarreo de salida de la resta es 0).
* Calcular la magnitud del número aplicando nuevamente el complemento a 2 (magnitud = (~resultado) + 1).
* Mostrar la magnitud en los displays y usar un display adicional para encender el signo "-".

---

## 3. Metodología y Diseño
El sistema se diseñó de manera modular en Verilog, culminando en un módulo principal (top_module) que integra toda la funcionalidad.

### 3.1. Flujo de Diseño
* **Entrada de Datos:** Se utilizan switches externos para introducir dos operandos de 8 bits (A, B) y un bit de selección de operación (op).
* **Cálculo Aritmético:** El módulo `sumres_8b` realiza la suma o resta según el valor de `op`.
* **Control de Visualización:**
    * Un divisor de frecuencia (`cf_divider`) reduce el reloj de 50 MHz de la FPGA a una frecuencia baja (`fdiv`) para controlar la multiplexación.
    * El módulo separador decimal (`separador_decimal`) recibe el resultado del cálculo y, sincronizado por `fdiv`, selecciona secuencialmente qué dígito mostrar (unidades, decenas, centenas o signo).
* **Decodificación y Salida:** El módulo `BCDtoSSeg` traduce el dígito BCD seleccionado al patrón de 7 segmentos correspondiente y activa el ánodo del display correcto.

### 3.2. Descripción Código Final (top_module)
El siguiente es el código del módulo principal que conecta todos los componentes lógicos del sistema.

/```verilog
module top_module (
    input clk_50,       // Reloj de 50 MHz
    input rst,          // Reset
    input [7:0] A,      // Operando A
    input [7:0] B,      // Operando B
    input op,           // Operación: 0 = suma, 1 = resta
    output [0:6] SSeg,  // Segmentos del display
    output [3:0] an     // Habilitación de ánodos
);
    wire [7:0] result;  // Resultado de A ± B
    wire fdiv;          // Reloj lento para multiplexar
    wire [3:0] BCD;     // Dígito BCD a mostrar
    wire [3:0] select;  // Señal de activación del display
    wire Cout;          // Acarreo de salida para detectar signo

/    // 1. Instancia del sumador/restador de 8 bits
    sumres_8b sr (
        .A(A),
        .B(B),
        .selec(op),
        .S(result),
        .Cout(Cout)
    );

  /  // 2. Instancia del divisor de frecuencia para el display
    cf_divider div (
        .clk_50(clk_50),
        .rst(rst),
        .fdiv(fdiv)
    );
    
  /  // 3. Separador que descompone el resultado y controla la multiplexación
    separador_decimal sep (
        .clk(fdiv),                 // Sincronizado con el reloj lento
        .input_val({Cout, result}), // Valor de entrada de 9 bits (incluye acarreo)
        .BCD(BCD),                  // Salida BCD del dígito actual
        .an(select)                 // Selección de display activo
    );

/    // 4. Decodificador que convierte el BCD a 7 segmentos
    BCDtoSSeg decod (
        .BCD(BCD),
        .select(select),
        .SSeg(SSeg),
        .an(an)
    );
Endmodule

### Explicación del Código y sus Módulos
El funcionamiento se basa en la interconexión de cuatro bloques lógicos principales que trabajan en secuencia:

**sumres_8b (Sumador/Restador):**
* **Función:** Este es el cerebro del sistema. Recibe dos números de 8 bits (A y B) y una señal de control `op`.
* **Operación:** Si `op` es 0, calcula A + B. Si `op` es 1, calcula A - B. El resultado de 8 bits se envía a la señal `result` y el acarreo de salida (`Cout`) se usa para determinar si un resultado de resta es negativo.

**cf_divider (Divisor de Frecuencia):**
* **Función:** Toma el reloj principal de la tarjeta de 50 MHz (`clk_50`) y lo reduce a una frecuencia mucho más baja (aprox. 1 kHz), generando la señal `fdiv`.
* **Propósito:** Esta señal lenta es crucial para la visualización dinámica. Permite encender y apagar cada uno de los cuatro displays de 7 segmentos lo suficientemente rápido para que el ojo humano no perciba el parpadeo, sino que vea un número estable.

**separador_decimal (Separador Decimal y Multiplexor):**
* **Función:** Este módulo es el corazón de la lógica de visualización. Recibe el resultado de la operación (`result` y `Cout`) y, usando el reloj lento `fdiv`, lo descompone para mostrarlo.
* **Operación:** En cada pulso del reloj `fdiv`, este bloque selecciona un dígito del resultado (unidades, decenas, etc.), lo convierte a BCD y activa el ánodo del display correspondiente.

**BCDtoSSeg (Decodificador BCD a 7 Segmentos):**
* **Función:** Es el traductor final. Recibe el valor BCD del dígito que está activo en ese instante.
* **Operación:** Convierte ese código BCD de 4 bits al patrón de 7 bits (`SSeg`) necesario para encender los segmentos correctos en el display y formar el número visible.

En resumen, el flujo de datos es: **Entrada Numérica → Cálculo Aritmético → Separación de Dígitos → Decodificación → Visualización en Display.**

---
## 4. Resultados y Análisis
### 4.1. Montaje Físico
El diseño se implementó exitosamente en una tarjeta FPGA Altera Cyclone IV.

![WhatsApp Image 2025-07-21 at 12 25 51 PM](https://github.com/user-attachments/assets/3e05ed9f-c2ce-4083-bd1f-875d5c2e1482)


* **FPGA y Displays:** La tarjeta verde ejecuta el código. Los displays de 7 segmentos integrados en ella muestran el resultado final.
* **Protoboard y Switches:** Los interruptores DIP en la protoboard sirven como interfaz de usuario para ingresar los operandos A y B y la selección de operación `op`.
* **Conexiones:** Los cables conectan las entradas físicas (switches) a los pines GPIO de la FPGA, alimentando el sistema con los datos para el cálculo.

### 4.2. Simulación
* **Lógica Aritmética:** Se fijarían valores en las entradas A, B y `op`, y se observaría la señal `result` para confirmar que el cálculo es correcto.
* **Lógica de Visualización:** Se observaría cómo las señales `an` y `BCD` cambian en cada pulso del reloj lento `fdiv`. Por ejemplo, para un resultado de 25, se vería a la señal `an` alternar entre `...0001` y `...0010`, mientras que `BCD` mostraría 5 y 2 respectivamente, confirmando el funcionamiento de la multiplexación.
![WhatsApp Image 2025-07-21 at 4 59 54 PM](https://github.com/user-attachments/assets/10ae77c7-bc72-4a43-a8eb-a18c5dd744ff)

---
## 5. Conclusiones
Se cumplieron todos los objetivos de la práctica, logrando implementar un sistema aritmético funcional con visualización en hardware.

* El diseño modular en Verilog demostró ser una estrategia eficaz, permitiendo desarrollar y probar cada parte del sistema (sumador, divisor, separador, decodificador) de forma independiente antes de su integración final.
* La implementación de la visualización dinámica fue exitosa. La técnica de multiplexación, controlada por un divisor de frecuencia, permitió manejar cuatro displays de 7 segmentos de manera eficiente, ahorrando recursos de hardware y logrando una visualización estable y clara.
* El sistema fue capaz de manejar y mostrar correctamente resultados con signo, interpretando el acarreo de salida del restador para mostrar números negativos en un formato legible para el usuario. Esto valida la correcta implementación de la lógica de complemento a 2 para la visualización.
