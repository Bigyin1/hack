## Модуль CSR шины

#### Список сигналов интерфейса:

```verilog
  ////////////////////////////////////////////////////////////
  //                     Status channel                     //
  ////////////////////////////////////////////////////////////

  logic               csr_status;    // "1" - calc active / "0" - waiting
  logic               csr_control;   // write to MAC activation

  ////////////////////////////////////////////////////////////
  //                  Read address channel                  //
  ////////////////////////////////////////////////////////////

  logic [APB_A_W-1:0] csr_addr_t0;   // TENSOR 0: ADDR
  logic [APB_A_W-1:0] csr_addr_t1;   // TENSOR 1: ADDR
  logic [APB_A_W-1:0] csr_addr_t2;   // TENSOR 2: ADDR

  ////////////////////////////////////////////////////////////
  //                    Read size channel                   //
  ////////////////////////////////////////////////////////////

  logic [T_LEN-1:0]   csr_addr_t0_0; // TENSOR 0: ROW
  logic [T_LEN-1:0]   csr_addr_t0_1; // TENSOR 0: COL
  logic [T_LEN-1:0]   csr_addr_t0_2; // TENSOR 0: DEPTH
  logic [T_LEN-1:0]   csr_addr_t1_0; // TENSOR 1: ROW
  logic [T_LEN-1:0]   csr_addr_t1_1; // TENSOR 1: COL
  logic [T_LEN-1:0]   csr_addr_t1_2; // TENSOR 1: DEPTH
  logic [T_LEN-1:0]   csr_addr_t2_0; // TENSOR 2: ROW
  logic [T_LEN-1:0]   csr_addr_t2_1; // TENSOR 2: COL
  logic [T_LEN-1:0]   csr_addr_t2_2; // TENSOR 2: DEPTH

  ////////////////////////////////////////////////////////////
  //                   Read param channel                   //
  ////////////////////////////////////////////////////////////

  // tensor param registers:
  logic [I_LEN-1:0]   csr_zp_t0;     // TENSOR 0: ZERO_POINT
  logic [I_LEN-1:0]   csr_zp_t1;     // TENSOR 1: ZERO_POINT
  logic [I_LEN-1:0]   csr_zp_t2;     // TENSOR 2: ZERO_POINT

  logic [I_LEN-1:0]   csr_bias_t2;   // TENSOR 2: BIAS
  logic [I_LEN-1:0]   csr_scale_t2;  // TENSOR 2: SCALE
  logic [I_LEN-1:0]   csr_shift_t2;  // TENSOR 2: SHIFT
```

---
---

#### Канал статуса:

  * csr_status — ***Статус работы MAC "1" — производится вычисление / "0" — ожидание csr_control == 1 от CSR***
  * csr_control — ***Запись 1 в данный ргеистр запускает вычисления в MAC***

#### Канал чтения адреса:

  * csr_addr_t0 — ***Адрес для чтения первого тензора из памяти (данные)***
  * csr_addr_t1 — ***Адрес для чтения второго тензора из памяти (ядро свёртки)***
  * csr_addr_t2 — ***Адрес для записи результата в память (свёрточная матрица)***

#### Канал чтения размера:

  * csr_addr_t0_0 — ***Количество строк в первом тензоре***
  * csr_addr_t0_1 — ***Количество столбцов в первом тензоре***
  * csr_addr_t0_2 — ***Глубина первого тензора***
  * csr_addr_t1_0 — ***Количество строк во втором тензоре***
  * csr_addr_t1_1 — ***Количество столбцов во втором тензоре***
  * csr_addr_t1_2 — ***Глубина второго тензора***
  * csr_addr_t2_0 — ***Количество строк тензора результата***
  * csr_addr_t2_1 — ***Количество столбцов тензора результата***
  * csr_addr_t2_2 — ***Глубина тензора результата***

#### Канал чтения параметров:

  * csr_zp_t0 — ***Zero-point для первого тензора***
  * csr_zp_t1 — ***Zero-point для второго тензора***
  * csr_zp_t2 — ***Zero-point для результата***

  * csr_bias_t2 — ***Bias для результата***
  * csr_scale_t2 — ***Scale для результата***
  * csr_shift_t2 — ***Shift для результата***

---
---

#### Временная диаграмма работы:

![](img/csr_bus_new.svg)

**Инициализация регистров CSR**

На первом этапе просходит инициализация регистров CSR по шине APB, в частности:

***Производится загрузка адресов тензоров***
 - csr_addr_t0 — Адрес для чтения первого тензора из памяти (данные);
 - csr_addr_t1 — Адрес для чтения второго тензора из памяти (ядро свёртки);
 - csr_addr_t2 — Адрес для записи результата в память (свёрточная матрица);

***Производится загрузка параметров тензоров***
  - csr_addr_t0_0 — Количество строк в первом тензоре;
  - csr_addr_t0_1 — Количество столбцов в первом тензоре;
  - csr_addr_t0_2 — Глубина первого тензора;
  - csr_addr_t1_0 — Количество строк во втором тензоре;
  - csr_addr_t1_1 — Количество столбцов во втором тензоре;
  - csr_addr_t1_2 — Глубина второго тензора;
  - csr_addr_t2_0 — Количество строк тензора результата;
  - csr_addr_t2_1 — Количество столбцов тензора результата;
  - csr_addr_t2_2 — Глубина тензора результата;

***Производится загрузка параметров квантования***
 - csr_zp_t0 — Zero-point для первого тензора;
 - csr_zp_t1 — Zero-point для второго тензора;
 - csr_zp_t2 — Zero-point для результата;

 - csr_bias_t2   — Bias для результата;
 - csr_scale_t2  — Scale для результата;
 - csr_shift_t2  — Shift для результата;

#### Запуск работы MAC посредством записи в CSR_CONTROL

Регистр CSR_CONTROL работает следующим образом:

При попытке записи по данному адресу ( 32'h04 ) значение младшего разряда, подаваемое по шине APB ( slave_apb.p_wdata[0]), будет комбинаторно установлено на CSR шине ( slave_csr.csr_control = CSR_CONTROL ), посредством чего попадёт в CU, управляющий блоком MAC.

Если в регистр будет записываться 1'b1, то MAC начнёт вычисления. На следующий такт, после записи 1'b1 в CSR_CONTROL, MAC должен выставить на CSR_STATUS статус "CALC = 1'b1", сигнализирующий о том, что вычисление начато. Если в CSR_CONTROL производится запись 1'b0, то MAC продолжит оставаться в режиме ожидания (определяется устройством конечного автомата, отвечающего за работу MAC).

В остальное время, когда запись в CSR_CONTROL не производится, его значения устанавливается в 1'b0.

Запись в CSR_CONTROL 1'b1 со стороны APB должна производиться после установки в регистре CSR_STATUS значения 0, что соответствует переходу MAC в состояние ожидания (готовность к началу нового вычисления).

---
---

#### Подключение со стороны MASTER устройства:

```verilog
  ////////////////////////////////////////////////////////////
  //                      Master Side                       //
  ////////////////////////////////////////////////////////////

  modport Master
  (

    // Status channel:
    output csr_status,
    input  csr_control,

    // Read address channel:
    input  csr_addr_t0,
    input  csr_addr_t1,
    input  csr_addr_t2,

    // Write response channel:
    input  csr_addr_t0_0,
    input  csr_addr_t0_1,
    input  csr_addr_t0_2,
    input  csr_addr_t1_0,
    input  csr_addr_t1_1,
    input  csr_addr_t1_2,
    input  csr_addr_t2_0,
    input  csr_addr_t2_1,
    input  csr_addr_t2_2,

    // Read param channel:
    input  csr_zp_t0,
    input  csr_zp_t1,
    input  csr_zp_t2,

    input  csr_bias_t2,
    input  csr_scale_t2,
    input  csr_shift_t2

  );
```

---

#### Подключение со стороны SLAVE устройства:

```verilog
  ////////////////////////////////////////////////////////////
  //                       Slave Side                       //
  ////////////////////////////////////////////////////////////

  modport Slave
  (

    // Status channel:
    input  csr_status,
    output csr_control,

    // Read address channel:
    output csr_addr_t0,
    output csr_addr_t1,
    output csr_addr_t2,

    // Write response channel:
    output csr_addr_t0_0,
    output csr_addr_t0_1,
    output csr_addr_t0_2,
    output csr_addr_t1_0,
    output csr_addr_t1_1,
    output csr_addr_t1_2,
    output csr_addr_t2_0,
    output csr_addr_t2_1,
    output csr_addr_t2_2,

    // Read param channel:
    output csr_zp_t0,
    output csr_zp_t1,
    output csr_zp_t2,

    output csr_bias_t2,
    output csr_scale_t2,
    output csr_shift_t2

  );
```

---
---