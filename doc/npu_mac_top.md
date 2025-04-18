## Модуль верхнего уровня MAC

#### Список вложенных модулей:

>
>[npu_cu](npu_cu.md)
>
>[npu_mac](npu_mac.md)
>>
>>[npu_zp_i](npu_zp_i.md)
>>
>>[npu_bias_o](npu_bias_o.md)
>>
>>[npu_scale_o](npu_scale_o.md)
>>
>>[npu_relu](npu_relu.md)
>>
>>[npu_zp_o](npu_zp_o.md)

---

#### Список портов:

```verilog
module npu_mac_top
  import npu_pkg::*;
(
  input  logic            clk_i,
  input  logic            arstn_i,

  // LSU interface
  ADDRDATA_BUS_SV.Master  lsu_master [2:0],

  // CSR interface
  CSR_BUS_SV.Master       csr_master
);
```

 CSR_BUS_SV.Master [csr_master](npu_csr_bus.md) — ***комбинаторная шина из CSR***

 ADDRDATA_BUS_SV.Master [lsu_master](npu_addrdata_bus.md) [2:0] — ***3 ADDR-DATA шины для 3-х LSU***

---

#### Подключение CU:

```verilog
  // CU
  npu_cu cu (
    .clk_i        ( clk_i              ),
    .arstn_i      ( arstn_i            ),

    .clear_o      ( clear              ),

    // LSU 0,1,2
    .lsu_master   ( lsu_master [2:0]   ),

    // CSR interface
    .csr_master   ( csr_master         ),

    // MAC
    .t0_v_o       ( t0_valid           ),
    .t0_o         ( t0_data            ),
    .t1_v_o       ( t1_valid           ),
    .t1_o         ( t1_data            ),

    .t2_v_i       ( t2_valid           ),
    .t2_i         ( t2_data            )
  );

```

* Через сигнал **clear** [CU](npu_cu.md) управляет очисткой внутреннего регистра частичных сумм — sum_ff, который расположен в MAC.

---

* Посредством интерфейса [lsu_master](npu_addrdata_bus.md) [2:0] модуль [npu_cu](npu_cu.md) подключается к модулю [LSU](npu_lsu.md) (здесь CU выступает в роли **MASTER** устройства).

* Посредством интерфейса [csr_master](npu_csr_bus.md) модуль [npu_cu](npu_cu.md) подключается к модулю [CSR](npu_csr.md) (здесь CU выступает в роли **MASTER** устройства).

---

* t0_valid — Валидность байта тензора данных, выставляемого [CU](npu_cu.md) на [MAC](npu_mac.md).
* t0_data — Байт тензора данных, выставляемый [CU](npu_cu.md) на [MAC](npu_mac.md).
* t1_valid — Валидность байта ядра свёртки, выставляемого [CU](npu_cu.md) на [MAC](npu_mac.md).
* t1_data — Байт ядра свёртки, выставляемый [CU](npu_cu.md) на [MAC](npu_mac.md).

---

* t2_valid — Валидность байта результата свёртки, выставляемого [MAC](npu_mac.md) на [CU](npu_cu.md).
* t2_data — Байт результата свёртки, выставляемый [MAC](npu_mac.md) на [CU](npu_cu.md).

---

#### Подключение MAC:

```verilog
  // MAC
  npu_mac mac (
    .clk_i   ( clk_i                   ),
    .arstn_i ( arstn_i                 ),

    .clear_i ( clear                   ),

    // for input data (t0,t1):
    .zp_t0_i ( csr_master.csr_zp_t0    ),
    .zp_t1_i ( csr_master.csr_zp_t1    ),

    .t0_v_i  ( t0_valid                ),
    .t0_i    ( t0_data                 ),
    .t1_v_i  ( t1_valid                ),
    .t1_i    ( t1_data                 ),

    // for output data (t2):
    .zp_t2_i ( csr_master.csr_zp_t2    ),

    .bi_t2_i ( csr_master.csr_bias_t2  ),

    .sc_t2_i ( csr_master.csr_scale_t2 ),
    .sc_sh_i ( csr_master.csr_shift_t2 ),

    .t2_v_o  ( t2_valid                ),
    .t2_o    ( t2_data                 )
  );
```

* Через сигнал **clear** [CU](npu_cu.md) управляет очисткой внутреннего регистра частичных сумм — sum_ff, который расположен в MAC.

---

* Посредством интерфейса [csr_master](npu_csr_bus.md) значения следующих параметров передаются в MAC:
  * csr_master.csr_zp_t0 — Zero-point для тензора данных.
  * csr_master.csr_zp_t1 — Zero-point для ядра свёртки.
  * csr_master.csr_zp_t2 — Zero-point для результата свёртки.
  * csr_master.csr_bias_t2 — Bias для результата свёртки.
  * csr_master.csr_scale_t2 — Scale для результата свёртки.
  * csr_master.csr_shift_t2 — Shift для результата свёртки.

---

* t0_valid — Валидность байта тензора данных, выставляемого [CU](npu_cu.md) на [MAC](npu_mac.md).
* t0_data — Байт тензора данных, выставляемый [CU](npu_cu.md) на [MAC](npu_mac.md).
* t1_valid — Валидность байта ядра свёртки, выставляемого [CU](npu_cu.md) на [MAC](npu_mac.md).
* t1_data — Байт ядра свёртки, выставляемый [CU](npu_cu.md) на [MAC](npu_mac.md).

---

* t2_valid — Валидность байта результата свёртки, выставляемого [MAC](npu_mac.md) на [CU](npu_cu.md).
* t2_data — Байт результата свёртки, выставляемый [MAC](npu_mac.md) на [CU](npu_cu.md).

---
---