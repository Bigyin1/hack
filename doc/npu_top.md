## Модуль верхнего уровня NPU

#### Список вложенных модулей:

> [npu_mac_top](npu_mac_top.md)
>>
>>[npu_cu](npu_cu.md)
>>
>>[npu_mac](npu_mac.md)
>>>
>>>[npu_zp_i](npu_zp_i.md)
>>>
>>>[npu_bias_o](npu_bias_o.md)
>>>
>>>[npu_scale_o](npu_scale_o.md)
>>>
>>>[npu_relu](npu_relu.md)
>>>
>>>[npu_zp_o](npu_zp_o.md)
>
> [npu_csr](npu_csr.md)
>
> [npu_lsu](npu_lsu.md)

---

#### Список портов:

```verilog
module npu_top
(
  input  logic clk_i,
  input  logic arstn_i,

  APB_BUS_SV.Slave csr_apb_slave, // CSR master side

  AXI4LITE_BUS_SV.Master lsu_axi_master [2:0] // LSU-0,1,2 master side
);
```

 APB_BUS_SV.Slave [csr_apb_slave](npu_apb_bus.md) — ***APB шина из CSR***

 AXI4LITE_BUS_SV.Master [lsu_axi_master](npu_axi4lite_bus.md) [2:0] — ***3 AXI4-Lite шины для 3-х LSU***

---

#### Создание экземпляров интерфейсов:

* Создание 3-х экземпляров шины [AXI4lite](npu_axi4lite_bus.md):

```verilog
  // ADDRDATA interface
  ADDRDATA_BUS_SV lsu_ad_slave [2:0] ();
```

* Создание экземпляра шины [APB](npu_apb_bus.md):

```verilog
  // CSR interface
  CSR_BUS_SV csr_slave ();
```

---

#### Подключение 3-х LSU:

* Создание 3-х экземпляров [LSU](npu_lsu.md)

```verilog
  // LSU-0,1,2
  npu_lsu lsu [2:0]   (
    .clk_i            ( clk_i                ),
    .arstn_i          ( arstn_i              ),

    .slave            ( lsu_ad_slave   [2:0] ),

    .master           ( lsu_axi_master [2:0] )
  );
```

* Посредством интерфейса [lsu_axi_master](npu_axi4lite_bus.md) [2:0] модуль [LSU](npu_lsu.md) подключаются наружу модуля npu_top (здесь LSU выступает в роли **MASTER** устройства).

* Посредством интерфейса [lsu_ad_slave](npu_addrdata_bus.md) [2:0] модуль [LSU](npu_lsu.md) подключается к модулю [npu_mac_top](npu_mac_top.md) (здесь LSU выступает в роли **SLAVE** устройства).

---

#### Подключение MAC:

```verilog
  // MAC
  npu_mac_top mac_top (
    .clk_i            ( clk_i                ),
    .arstn_i          ( arstn_i              ),

    .lsu_master       ( lsu_ad_slave [2:0]   ),

    .csr_master       ( csr_slave            )
  );
```

* Посредством интерфейса [lsu_ad_slave](npu_addrdata_bus.md) [2:0] модуль [npu_mac_top](npu_mac_top.md) подключается к модулю [LSU](npu_lsu.md) (здесь MAC выступает в роли **MASTER** устройства).

* Посредством интерфейса [csr_slave](npu_csr_bus.md) модуль [npu_mac_top](npu_mac_top.md) подключается к модулю [CSR](npu_csr.md) (здесь MAC выступает в роли **MASTER** устройства).

---

#### Подключение CSR:

```verilog
  // CSR
  npu_csr csr         (
    .clk_i            ( clk_i                ),
    .arstn_i          ( arstn_i              ),

    .slave_csr        ( csr_slave            ),

    .slave_apb        ( csr_apb_slave        )
  );
```

* Посредством интерфейса [csr_slave](npu_csr_bus.md) модуль [CSR](npu_csr.md) подключается к модулю [npu_mac_top](npu_mac_top.md) (здесь CSR выступает в роли **SLAVE** устройства).

* Посредством интерфейса [csr_apb_slave](npu_apb_bus.md) модуль [CSR](npu_csr.md) подключаются наружу модуля npu_top (здесь CSR выступает в роли **SLAVE** устройства).


---
---