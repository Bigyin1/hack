## Модуль c параметрами NPU

#### Список параметров:

```verilog
package npu_pkg;

  parameter I_LEN   = 8;         // 8-bit  data input
  parameter O_LEN   = 8;         // 8-bit  data output
  parameter Z_LEN   = 16;        // 16-bit data after zeropoint
  parameter M_LEN   = 32;        // 32-bit data after multiply

  parameter AXI_A_W = 32;        // AXI ADDRESS width
  parameter AXI_D_W = 256;       // AXI DATA    width
  parameter AXI_S_W = AXI_D_W/8; // STRB        width

  // for CSR:
  parameter T_LEN   = 11;        // 11-bit for tensor size

  parameter APB_A_W = 32;        // APB ADDRESS width
  parameter APB_D_W = 32;        // APB DATA    width

  parameter CSRR_OP = 1'b0;      // APB READ
  parameter CSRW_OP = 1'b1;      // APB WRITE

endpackage
```

#### Общие параметры для модулей:

* I_LEN — ***Ширина входных данных***
* O_LEN — ***Ширина выходных данных***
* Z_LEN — ***Ширина данных после сложения на входе MAC с ZEROPOINT***
* M_LEN — ***Ширина данных после перемножения в MAC***

---

* AXI_A_W — ***Ширина адреса в шине AXI_S_W***
* AXI_D_W — ***Ширина данных в шине AXI_S_W***
* AXI_S_W — ***Ширина строба в шине AXI_S_W***

---

#### Параметры для CSR:

* T_LEN   — ***Размер данных тензора***

---

* APB_A_W — ***Ширина адреса в шине APB***
* APB_D_W — ***Ширина данных в шине APB***

---

* CSRR_OP — ***Кодирование операции чтения по APB***
* CSRW_OP — ***Кодирование операции записи по APB***

---
---