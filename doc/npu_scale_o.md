## Модуль scale

Scale — коэффициент масштаба, определяющий шаг квантования.

---

#### Реализация:

```verilog
module npu_sc_o
  import npu_pkg::M_LEN;
  import npu_pkg::T_LEN;
(
  input  logic        [T_LEN-7:0] shift_i,
  input  logic signed [M_LEN-1:0] scale_i,

  input  logic signed [M_LEN-1:0] data_i,
  output logic signed [M_LEN-1:0] data_o,

  input  logic                    valid_i,
  output logic                    valid_o
);

  logic signed [M_LEN*2-1:0] p_m_f;

  assign valid_o = valid_i;

  assign p_m_f = ( $signed(data_i) * $signed(scale_i) ) >>> 'd31 >>> shift_i;

  assign data_o = p_m_f[M_LEN-1:0];

endmodule
```

Вся суть модуля сводится к **знаковому перемножению входных данных на масштабирующий коэффициент**, соответствующий данному тензору. Произведение подвергается фиксированному сдвигу на 31 и сдвигу на заданный параметр shift. На выход подаётся младшая (32-битная) часть 64-битного произведения.

---

#### Сигналы:

* shift_i — ***Значение сдвига***
* scale_i — ***Масштабирующий коэффициент***

* data_i — ***Входные данные***
* data_o — ***Выходные данные***

---

* valid_i — ***Валидность входных данных***
* valid_o — ***Валидность выходных данных***

---
---
