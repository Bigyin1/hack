## Модуль zero point (for output data)

Zero point — смещение, обеспечивающее корректное представление нуля в целочисленном формате.

---

#### Реализация:

```verilog
 module npu_zp_o
  import npu_pkg::I_LEN;
  import npu_pkg::M_LEN;
  import npu_pkg::O_LEN;
(
  input  logic signed [I_LEN-1:0] zp_i,

  input  logic signed [M_LEN-1:0] data_i,
  output logic signed [O_LEN-1:0] data_o,

  input  logic                    valid_i,
  output logic                    valid_o
);

  logic signed [M_LEN-1:0] data;

  assign valid_o = valid_i;

  assign data = $signed(data_i) + $signed(zp_i);

  assign data_o = ( $signed(data[M_LEN-1:0]) > $signed( 32'sd127) ) ?  8'sd127 :
                  ( $signed(data[M_LEN-1:0]) < $signed(-32'sd128) ) ? -8'sd128 : $signed(data[M_LEN-1:0]);

endmodule
```

Вся суть модуля сводится к **знаковому сложению входных данных с** соответствующим данному тензору значением **zero point**, которое хранится в CSR. После этого производится (clamp) **приведение полученного значения к диапазону** [-128:127] (приводим значение к int8).

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