## Модуль zero point (for input data)

Zero point — смещение, обеспечивающее корректное представление нуля в целочисленном формате.

---

#### Реализация:

```verilog
module npu_zp_i
  import npu_pkg::I_LEN;
  import npu_pkg::Z_LEN;
(
  input  logic signed [I_LEN-1:0] zp_i,

  input  logic signed [I_LEN-1:0] data_i,
  output logic signed [Z_LEN-1:0] data_o,

  input  logic                    valid_i,
  output logic                    valid_o
);

  assign valid_o = valid_i;

  assign data_o = $signed(data_i) + $signed(zp_i);

endmodule
```

Вся суть модуля сводится к **знаковому сложению входных данных с** соответствующим данному тензору значением **zero point**, которое хранится в CSR.

---

#### Сигналы:

* zp_i   — ***Значение zero point***

* data_i — ***Входные данные***
* data_o — ***Выходные данные***

---

* valid_i — ***Валидность входных данных***
* valid_o — ***Валидность выходных данных***

---
---